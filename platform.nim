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
# import macros
# dumpAstGen:
#   none(proc(a, b: string): bool {.closure.})

# nnkBracketExpr.newTree(
#   newIdentNode("Option"),
#   nnkProcTy.newTree(
#     nnkFormalParams.newTree(
#       newEmptyNode()
#     ),
#     newEmptyNode()
#   )
# )

# nnkCall.newTree(
#   newIdentNode("none"),
#   nnkProcTy.newTree(
#     nnkFormalParams.newTree(
#       newEmptyNode()
#     ),
#     newEmptyNode()
#   )
# )
