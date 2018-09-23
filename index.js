


'use strict';

const Hapi = require('hapi');
const fs = require('fs')
const uuid = require('uuid/v4')
const jsonic = require('jsonic')
const bcrypt = require('bcrypt-nodejs')
const compareVersions = require('compare-versions');


const server = Hapi.server({
    port: 8080,
    host: '0.0.0.0'
});
var repo_dir = './repos/'

server.route({
    method: 'POST',
    path: '/create_repo/{author}/{package_name}/{filename}',
    handler: (request, h) => {
        var s_time = new Date()
        var author = request.params.author;
        var package_name = request.params.package_name;
        var filename = request.params.filename;
        var password = bcrypt.hashSync(request.payload.payload);
        if(new Repo().new(author,package_name,filename,password)){
            return "repo was successfully created in "+((new Date() - s_time)/1000)+" seconds."
        }else{
            return "could not create this repo because it already exists"
        }

        return "test";
    }
});

server.route({
    method: 'GET',
    path: '/get_repo/{package_name}',
    handler: (request,h)=>{
        var package_name = request.params.package_name//cleanString(String(encodeURIComponent(request.params.package_name)))
        return new Repo(package_name).get()
    }
});
server.route({
    method: 'GET',
    path: '/repo_exists/{package_name}',
    handler: (request,h)=> {
        var package_name = request.params.package_name;
        return new Repo(package_name).exists();
    }
});
server.route({
    method: 'GET',
    path: '/get_repo',
    handler: (request, h)=> {
        var repos_versioned = [];
        var tmp = getRepos();
        for(var i in tmp){
            var package_inst = tmp[i];
            repos_versioned.push(
                {"name":package_inst.package_name,
                "version_name":new Repo(package_inst.package_name).getLatestVersion().version_name
                }
            )
        }
        console.log(repos_versioned)
        return repos_versioned;
    }
})
server.route({
    method: 'GET',
    path: '/get_repo/{package_name}/{key}',
    handler: (request, h)=>{
        var package_name = request.params.package_name;
        var key = request.params.package_name;
        var repo = new Repo(package_name).get();
        if(repo[key] != undefined){
            return repo[key];
        }else{
            return "undefined";
        }
        return "there was an error"

    }
});

server.route({
    method: 'POST',
    path: '/add_version/{package_name}/{version_name}',
    handler: (request,h)=>{
        var package_name = request.params.package_name;
        var version_name = request.params.version_name;
        var file_content = request.payload.payload;

        if(new Repo(package_name).exists()){
            if(!new Repo(package_name).versionExist(version_name)){
                new Repo(package_name).addVersion(version_name)
                var latest_version = new Repo(package_name).getLatestVersion()
                fs.writeFileSync(new Repo(package_name).getDirectory(version_name)+"/"+latest_version.filename,file_content)
                return "version successfully added."
            }else{
                return "package version already exist."
            }
        }else{
            return "package name specified does not exist."
        }
        return "there was an error";
    }
});
server.route({
    method: 'POST',
    path: '/version_file/{package_name}',
    handler: (request, h) => {


    }
});
server.route({
    method: 'GET',
    path: '/package_versions/{package_name}',
    handler: (request,h) => {
        var package_name = request.params.package_name
        return JSON.stringify(Repo.getVersions(package_name))
    }
})
server.route({
    method: 'GET',
    path: '/get_repo/{package_name}/latest',
    handler: (request,h) => {
        var package_name = request.params.package_name;
        return new Repo(package_name).getLatestVersion();
    }
});
server.route({
    method: 'GET',
    path: '/install/{package_name}/{version_name}',
    handler: (request, h) => {
        var package_name = request.params.package_name
        var version_name = request.params.version_name
        if(version_name == "L" || version_name == "l"){
            version_name = new Repo(package_name).getLatestVersion().version_name
        }
        var latest_version = new Repo(package_name).getLatestVersion()
        var file_dir = new Repo(package_name).getDirectory(version_name)+"/"+latest_version.filename

        return fs.readFileSync(file_dir,'utf8');

    }
})
server.route({
    method: 'GET',
    path: '/add_dependency/{package_name}/{dependency_name}',
    handler: (request, h) => {
        var package_name = request.params.package_name
        var dependency_name = request.params.dependency_name
        if(new Repo(package_name).exists() && new Repo(dependency_name).exists()){
            var latest_package = new Repo(package_name).getLatestVersion();
            var latest_dependency = new Repo(dependency_name).getLatestVersion();
            if(!latest_package.addDependency(latest_dependency.package_name,latest_dependency.version_name)){
                return "this dependency already exist in this version"
            }
            return "successfully added dependency"
        }else{
            return "One of the packages specified was not found"
        }
    }
});
server.route({
    method: 'GET',
    path: '/update_dependencies/{package_name}',
    handler: (request,h)=>{
        var package_name = request.params.package_name;
        if(new Repo(package_name).exists()){
            var latest = new Repo(package_name).getLatestVersion()
            latest.updateDependencies()
            return "Successfull updated all dependencies"
        }
        return "the package_specified does not exist"
    }
})




const init = async () => {

    await server.start();
    console.log(`Server running at: ${server.info.uri}`);
};

process.on('unhandledRejection', (err) => {

    console.log(err);
    process.exit(1);
});

function getRepos(){

    var file = fs.readFileSync('./repos_index.json','utf8')

    return jsonic(file)
}
function setRepos(repos){
    fs.writeFileSync('./repos_index.json',JSON.stringify(repos,null,4));
}


function cleanString(string){
    string.replace('/','')
    string.replace('\\','')
    string.replace('..','')
    string.replace('.','')
    return string
}




class Version{
    constructor(){
       this.package_name = undefined;
       this.version_name = undefined;
       this.filename = undefined;
       this.dependencies = []
    }
    fromObject(obj){
        var tmp = jsonic(obj)
        this.package_name = tmp.package_name
        this.version_name = tmp.version_name
        this.filename = tmp.filename
        
        for(var i = 0;i<tmp.dependencies.length;i++){
            var d = tmp.dependencies[i];
            //console.log(d)
            //if(!this.dependencyExists(d.package_name)){
                this.dependencies.push(new Dependency().fromObject(d))
            //}
        }
        this.dependencies = obj.dependencies
        return this
    }
    updateDependencies(){
        var new_deps = []
        //console.log(this.dependencies)
        for(var i = 0;i<this.dependencies.length;i++){
            var c = this.dependencies[i]
            var latest_version = new Repo(c.package_name).getLatestVersion()
            new_deps.push(new Dependency(latest_version.package_name,latest_version.version_name))
        }
        this.dependencies = new_deps;
        this.save()
    }
    //Creates a new instance of the repo object in the repo index
    new(package_name,version_name,filename){
        this.package_name = package_name;
        this.version_name = version_name;
        this.filename = filename;
        this.dependencies = []
        return this
    }
    dependencyExists(dependency_name){
        for(var i = 0;i<this.dependencies.length;i++){
            var d = this.dependencies[i]
            
            if(d.package_name == dependency_name){
                return true;
            }
        }
        return false;
    }

    addDependency(dependency_name,version_name){
        this.get()

        if(!this.dependencyExists(dependency_name)){
            this.dependencies.push(new Dependency(dependency_name,version_name))
            this.save()
            return true;
        }else{
            return false;
        }


    }
    save(){
        new Repo(this.package_name).updateVersion(this.version_name,this)
    }
    get(){
        var v = new Repo(this.package_name).getVersion(this.version_name)
        this.fromObject(v)

    }
    writeVersionFile(file_contents){

    }
}
class Repo{
    constructor(package_name){
        this.package_name = package_name
        this.versions = {};
        this.author;
        this.filename;
        this.password;
    }
    fromObject(obj){

        var tmp = jsonic(obj)

        for(var v in tmp.versions){
          //console.log(obj.versions[v])
          this.versions[v] = new Version().fromObject(tmp.versions[v]);

        }
        //console.log(this);
        this.author = obj.author;
        this.filename = obj.filename;
        this.password = obj.password;
    }
    new(author,package_name,filename,password){
        this.author = author;
        this.package_name = package_name;
        this.filename = filename;
        this.password = password;
        if(!this.exists()){
            this.save()
            this.createPackageDir()
            return true
        }else{
            return false
        }
        return this
    }
    getVersion(version_name){

        //console.log(version_name)
        this.get()
        if(this.versions[version_name] != undefined){
            return this.versions[version_name]
        }else{
            return undefined
        }
    }
    updateVersion(version_name,new_version){
        this.get()
        this.versions[version_name] = new_version;
        this.save()
    }
    getLatestVersion(){
      this.get()
      //console.log(this.versions)
      var versions = Object.keys(this.versions).sort(compareVersions)
      console.log(versions.length)
      return this.getVersion(versions[versions.length-1])
    }
    versionExist(version_name){

        if(this.getVersion(version_name) != undefined){
            return true
        }
        return false
    }
    addVersion(version_name){
        this.get()

        if(!this.versionExist(version_name)){
            var current_version = this.getLatestVersion()
            //console.log(current_version)
            this.versions[version_name] = new Version().new(this.package_name,version_name,this.filename)
            console.log(this.versions)
            if(Object.keys(this.versions).length != 1){
                this.versions[version_name].dependencies = this.versions[current_version.version_name].dependencies
            }
            this.save()
            this.createPackageDir()
            this.createVersionDir(version_name)
            return true
        }
        return false
    }
    getDirectory(version_name){
        return repo_dir + this.package_name + '/' + version_name
    }
    createPackageDir(){

        fs.mkdir(repo_dir + this.package_name,function(){});
    }
    createVersionDir(version_name){

        fs.mkdir(this.getDirectory(version_name)+'/',function(){});

    }
    save(){
        var repos = getRepos()
        repos[this.package_name] = this
        setRepos(repos)
    }
    get(){
        if(this.exists()){
            var repos = getRepos()
            this.fromObject(repos[this.package_name])
            return this
        }else{
            return false;
        }
    }
    exists(){
        return getRepos()[this.package_name] != undefined
    }

}
class Dependency{
    constructor(package_name,version_name){
        this.package_name = package_name;
        this.version_name = version_name;
    }
    fromObject(obj){
        this.package_name = obj.package_name;
        this.version_name = obj.version_name;
    }
}



init();
