--All rights reserved 2018
--Anyone who claims this software as their own creation
--Is to have their organs harvested and sold for damages
gmplib_pastebin = "FuqtQwFD"
json_pastebin = "4nRg9CHU"
if(fs.exists("gmplib.lua") == false) then
   shell.run("pastebin get "..gmplib_pastebin.." gmplib.lua")
end
if(fs.exists("json.lua") == false) then
    shell.run("pastebin get "..json_pastebin.." json.lua")
end
os.loadAPI("json.lua")
os.loadAPI("gmplib.lua")

args = {...}




if(args[1] == "create" or args[1] == "+r" or args[1] == "-c") then
  if(#args == 1) then
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
elseif(args[1] == "+v" or args[1] == "-av" or args[1] == "addversion") then
  if(#args == 3) then
    gmplib.addVersion(args[2],args[3])

  else
    print("gmp "..args[1].." <package_name> <version_name>")
  end
elseif(args[1] == "+d" or args[1] == "-ad" or args[1] == "adddependency") then
  if(#args == 3) then
    gmplib.addDependency(args[2],args[3])
  else
    print("gmp "..args[1].." <package_name> <dependency_name>")
  end
elseif(args[1] == "^d" or args[1] == "-ud" or args[1] == "updatedependencies") then
  if(#args == 2) then
    gmplib.updateDependencies(args[2])
  else
    print("gmp "..args[1].." <package_name>")
  end
elseif(args[1] == "install") then
  if(#args == 3) then

    gmplib.installPackage(args[2],args[3])

  else
    print("gmp install <package_name> <version_name>")
  end
elseif(args[1] == "list" or args[1] == "ls") then
  if(#args == 1) then
    gmplib.getRepos()
  else
    print("gmp "..args[1])
  end
elseif(args[1] == "testcreate") then
  if(#args == 1) then
    local author = "DeaSTL"
    local package_name = "gmp"
    local filename = "gmp.lua"
    local password = "fuck"
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
elseif(args[1] == "toroot") then
  if(#args == 1)then

    if(fs.exists("/gmp.lua") or fs.exists("/gmplib.lua")) then
      if(shell.dir() == "gmp") then
        print("Are you sure you would like to replace the gmp.lua and gmplib.lua with the files in this directory")
        print("y/n")
        confirm = read()
        if(not fs.exists("/RECYCLEBIN")) then
          fs.makeDir("RECYCLEBIN")
        else
          if(confirm == "Y" or confirm == "y") then
            shell.run("mv /gmp.lua /RECYCLEBIN/")
            shell.run("mv /gmplib.lua /RECYCLEBIN/")
            shell.run("rename /RECYCLEBIN/gmp.lua gmp"..os.time()..".lua")
            shell.run("rename /RECYCLEBIN/gmplib.lua gmplib"..os.time()..".lua")
            shell.run("cp /gmp/gmp.lua /")
            shell.run("cp /gmp/gmplib /")
          else
            print("exiting...")
          end
        end
      else
        print("you must be in the gmp directory to use this command")
      end
    end
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