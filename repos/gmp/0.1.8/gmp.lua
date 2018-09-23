--All rights reserved 2018
--Anyone who claims this software as their own creation
--Is to have their organs harvested and sold for damages
gmplib_pastebin = "FuqtQwFD"
json_pastebin = "4nRg9CHU"
if(not fs.exists("/gmp/lib/gmplib.lua")) then
   shell.run("pastebin get "..gmplib_pastebin.." /gmp/lib/gmplib.lua")
end
if(not fs.exists("/gmp/lib/json.lua")) then
    shell.run("pastebin get "..json_pastebin.." /gmp/lib/json.lua")
end
os.loadAPI("/gmp/lib/json.lua")
os.loadAPI("/gmp/lib/gmplib.lua")


args = {...}
commands = {}
function registerCommand(name,parameter_count,command_function,usage_error)
  commands[name] = {}
  commands[name].name = name
  commands[name].parameter_count = parameter_count
  commands[name].command_function = command_function
  commands[name].usage_error = usage_error
end
function command_create(args)
    print("author:")
    local author       = read()
    print("package_name:")
    local package_name = read()
    print("filename:")
    local filename     = read()
    print("password:")
    local password     = read("*")
    if(fs.exists(filename)) then
      gmplib.createRepo(
        author,
        package_name,
        filename,
        password)

    else
      print("file doesn't exist")
    end
end
function command_add_version(args)
  gmplib.addVersion(args[2],args[3])
end
function command_add_dependency(args)
  gmplib.addDependency(args[2],args[3])
end
function command_update_dependencies(args)
  gmplib.updateDependencies(args[2])
end
function command_install(args)
  gmplib.installPackage(args[2],args[3])
end
function command_list(args)
  gmplib.getRepos()
end
function command_to_root(args)

	if(shell.dir() == "gmp") then
	  print("Are you sure you would like to install this")
	  if(fs.exists("gmp.lua")) then
	  	print("it seems you already have a instance of gmp installed, would you like to overwrite this?")
	  	print("y/n")
	  	confirm = read()
	  else
	  	confirm = "y"
	  end
	  
	  
	  
	  if(not fs.exists("/RECYCLE")) then
	  	print("Creating /RECYCLE")
	    fs.makeDir("RECYCLE")
	  end
	  if(confirm == "Y" or confirm == "y") then
	    --checks to see if gmp.lua exists before trying to move it
	    if(fs.exists("/gmp.lua")) then
	    	print("moving gmp.lua to /RECYCLE")
	    	shell.run("mv /gmp.lua /RECYCLE/")
	    	shell.run("rename /RECYCLE/gmp.lua /RECYCLE/gmp-"..os.time()..".lua")
	    end
	    print("copying gmp.lua to / ")
	    shell.run("cp /gmp/gmp.lua /")
	  else
	    print("exiting...")
	  end
	else
	  print("you must be in the gmp directory to use this command")
	end

end
registerCommand(
  "create",
  0,
  command_create,
  "gmp create"
  )
registerCommand("addversion",
  2,
  command_add_version,
  "gmp addversion <package_name> <version_name>"
  )
registerCommand("adddependency",
  2,
  command_add_dependency,
  "gmp adddependency <package_name> <dependency_name>"
  )
registerCommand("updatedependencies",
  1,
  command_update_dependencies,
  "gmp updatedependencies <package_name>"
  )
registerCommand("install",
  2,
  command_install,
  "gmp install <package_name> <version_name>"
  )
registerCommand("list",
  0,
  command_list,
  "gmp list"
  )
registerCommand("toroot",
  0,
  command_to_root,
  "gmp toroot"
  )





sub_command = args[1]
if(commands[sub_command] ~= nil) then
  current_command = commands[sub_command]
  if(current_command.parameter_count == #args-1) then
    current_command.command_function(args)

  else
    print(current_command.usage_error)
  end
else
  print("---------------------------------------------------")
  print("gmp create|+r|-c - runs a setup wizard to create a new repo")
  print("gmp addversion|+v|-av - adds a new version to a existing repo")
  print("gmp adddependecy|+d|-ad - adds a dependency to an existing repo")
  print("gmp install - installs a package to a seperate version directory")
  print("gmp ^d|-ud|updatedependencies - updates all dependencies to the latest version")
  print("---------------------------------------------------")
end


