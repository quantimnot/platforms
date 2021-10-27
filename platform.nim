import "."/platforms_define
inclOS other, windows, "Some other Windows"
import "."/platforms_generate

proc detect() =
  echo "Compiletime OS: " & system.hostOS
  echo "Compiletime CPU: " & system.hostCPU
  echo "Runtime OS: " & $os()
  echo "Runtime CPU: " & $cpu()

detect()

echo other.info.name
echo windows.info.name
echo windows11.info.name
echo windows10.info.name
echo windows8.info.name
echo windows7.info.name
