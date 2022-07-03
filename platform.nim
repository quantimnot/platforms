import platforms

proc detect() =
  echo "Nim Compiletime OS: " & system.hostOS
  echo "Nim Compiletime CPU: " & system.hostCPU
  echo "Runtime OS: " & $os()
  echo "Runtime OS version: " & $os().detectVer()
  doAssert os().cmpVer(os().detectVer(), "10.13.4")
  echo "Runtime CPU: " & $cpu()
  # echo $platforms_generate.platform

detect()
