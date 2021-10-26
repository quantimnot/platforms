import "."/platforms_define
inclOS other, windows
import "."/platforms_generate

proc detect() =
  echo "Compiletime OS: " & system.hostOS
  echo "Compiletime CPU: " & system.hostCPU
  echo "Runtime OS: " & $os()
  echo "Runtime CPU: " & $cpu()

detect()

echo repr os("other").info
