task test, "Run tests":
  exec"nim r -d:debug -d:test platforms.nim"
  exec"nim r -d:debug -d:test platform.nim"
