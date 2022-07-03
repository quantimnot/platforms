#* TODO
#*   - [ ] look into https://github.com/nim-lang/osinfo

import platforms_generate
export OS, OSInfo, CPU, platforms_generate


#======
# Tests
#======

import pkg/isolated_test

isolatedTest:
  import std/unittest
  import "."/platforms_define
  inclOS other, windows, "Some other Windows"
  import "."/platforms_generate
  check other.parents == {windows}
  check other.info.name == "Some other Windows"
