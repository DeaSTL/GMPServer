--All rights reserved 2018
--Anyone who claims this software as their own creation
--Is to have their organs harvested and sold for damages

local server_uri = "http://ftbciv.tk:8080"

function queryServer(command,parameters)
  message = {}
  message.parameters = parameters
  message.command = command
  print(server_uri.."/"..command)
  return http.post(server_uri.."/"..command,json.encode(message))
end
function getServer(command)
  print(server_uri.."/"..command)
  return http.get(server_uri.."/"..command)
end
function postServer(command,payload)
  print(server_uri.."/"..command)
  return http.post(server_uri.."/"..command,"payload="..textutils.urlEncode(payload))
end
function getFileText(filename)
  file_h = fs.open(filename,"r")
  file_text = file_h.readAll()
  file_h.close()
  return file_text
end


function createRepo(author,package_name,filename,password)
  local res = postServer("create_repo/"..author.."/"..package_name.."/"..filename,password)
  if(res ~= nil) then
    print(res.readAll())
  else
    print("Could not connect to this url.")
  end
end
function getRepo(package_name)

    res = getServer("get_repo/"..package_name)

    response_text = res.readAll()
    if(response_text == "null") then
      return nil
    else
      repo = json.decode(response_text)
      return repo
    end


end
function getRepos()
  local res = getServer("get_repo")
  if(res ~= nil) then
    local repos = json.decode(res.readAll())
    for i=1,#repos do
      print(repos[i].name .. " - Version " .. repos[i].version_name)
    end
  end
end
function repoExist(package_name)

  return getRepo(package_name) ~= nil
end
function uploadVersionFile(package_name,version_name)
  local repo = getRepo(package_name);
  local file_contents = getFileText(repo.filename);
  local res = http.post(server_uri.."/version_file/"..package_name.."/"..version_name,file_contents)
  print(res.readAll())
end
function writeNewFile(filename,file_contents)
  local file = fs.open(filename,"w")
  file.writeLine(file_contents)
  file.close()
end
function addVersion(package_name,version_name)
  local package_info = getServer("get_repo/"..package_name)



  if(package_info ~= nil) then

    package_info = json.decode(package_info.readAll())
    local res = postServer("add_version/"..package_name.."/"..version_name,getFileText(package_info.filename))
    if(res ~= nil) then
      print(res.readAll())
    else
      print("Could not connect to this url.")
    end
  else
    print("Could not connect to this url.")
  end

end
function addDependency(package_name,dependency_name)
  local res = getServer("add_dependency/"..package_name.."/"..dependency_name)
  if(res ~= nil) then
    print(res.readAll())
  else
    print("Could not connecto this url.")
  end

end

function updateDependencies(package_name)
  local res = getServer("update_dependencies/"..package_name)
  if(res ~= nil) then
    print(res.readAll())
  else
    print("Could not connect to this url.")
  end
end
function installPackage(package_name,version_name)
  local res = getServer("install/"..package_name.."/"..version_name)
  local package_info = getServer("get_repo/"..package_name.."/latest")
  if(res ~= nil and package_info ~= nil) then
    local dir = "/"..package_name
    fs.makeDir(dir)
    package_info = json.decode(package_info.readAll())
    print("Creating Dir "..dir)
    print("Installing "..package_name.." in "..dir)
    writeNewFile(dir.."/"..package_info.filename,res.readAll())
    for i=1,#package_info.dependencies do
      local current_dep = package_info.dependencies[i]

      local res = getServer("install/"..current_dep.package_name.."/"..current_dep.version_name)
      local dep_info = getServer("get_repo/"..current_dep.package_name.."/latest")

      if(res ~= nil and dep_info ~= nil) then
        dep_info = json.decode(dep_info.readAll())
        print("Installing "..current_dep.package_name.." in "..dir)
        writeNewFile(dir.."/"..dep_info.filename,res.readAll())
      else
        print("could not download dependencies.")
      end
    end
  else
    print("Could not connect to this url.")
  end
end