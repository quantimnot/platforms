import macros, macrocache
import sequtils, options

const osMacroCache = CacheSeq"osMacroCache"
const osInfoMacroCache = CacheTable"osInfoMacroCache"
const cpuMacroCache = CacheSeq"cpuMacroCache"

# TODO: workaround; remove this once
#       https://github.com/nim-lang/Nim/issues/11182 is fixed
proc name = discard

type
  OSProp* {.pure.} = enum
    NeedsPIC ## needs PIC for libraries
    DefaultCaseInsensitive ## *default* filesystem is case insensitive
    PosixLike ## is posix-like
    LacksThreadVars ## lacks proper __threadvar support
    LacksStaticCRT ## lacks static linkage against system c runtime

proc inclOSInner(ident, family, name,
    detectVerCmd, detectVerProc, verCmpCmd, verCmpProc,
    verMin, verMax, parDir, dllFrmt, altDirSep,
    objExt, newLine, pathSep, dirSep, cmdInterpreter, cmdExt,
    curDir, exeExt, extSep, props: NimNode) {.compileTime.} =
  osMacroCache.add ident
  let OSInfo = macros.ident("OSInfo")
  let familyInfo =
    if ident != family:
      osInfoMacroCache[$family]
    else:
      quote do: `OSInfo`()
  osInfoMacroCache[$ident] = quote do:
    (func(): `OSInfo` =
      result = `familyInfo`
      result.family = OS.`family`
      if `name`.len != 0:
        result.name = `name`
      if `detectVerCmd`.len != 0:
        result.detectVerCmd = `detectVerCmd`
      if `detectVerProc`.isSome:
        result.detectVerProc = `detectVerProc`
      if `verCmpCmd`.len != 0:
        result.verCmpCmd = `verCmpCmd`
      if `verCmpProc`.isSome:
        result.verCmpProc = `verCmpProc`
      if `verMin`.len != 0:
        result.verMin = `verMin`
      if `verMax`.len != 0:
        result.verMax = `verMax`
      if `parDir`.len != 0:
        result.parDir = `parDir`
      if `dllFrmt`.len != 0:
        result.dllFrmt = `dllFrmt`
      if `altDirSep`.len != 0:
        result.altDirSep = `altDirSep`
      if `objExt`.len != 0:
        result.objExt = `objExt`
      if `newLine`.len != 0:
        result.newLine = `newLine`
      if `pathSep`.len != 0:
        result.pathSep = `pathSep`
      if `dirSep`.len != 0:
        result.dirSep = `dirSep`
      if `cmdInterpreter`.len != 0:
        result.cmdInterpreter = `cmdInterpreter`
      if `cmdExt`.len != 0:
        result.cmdExt = `cmdExt`
      if `curDir`.len != 0:
        result.curDir = `curDir`
      if `exeExt`.len != 0:
        result.exeExt = `exeExt`
      if `extSep`.len != 0:
        result.extSep = `extSep`
      # if `props`.len != 0:
      #   result.props = `props`
    )()

macro inclOS*(ident: untyped, family: untyped, name = "",
    detectVerCmd = "", detectVerProc: untyped, verCmpCmd = "", verCmpProc: untyped,
    verMin = "", verMax = "", parDir = "", dllFrmt = "", altDirSep = "",
    objExt = "", newLine = "", pathSep = "", dirSep = "", cmdInterpreter = "", cmdExt = "",
    curDir = "", exeExt = "", extSep = "", props: set[OSProp] = {}) =
  osMacroCache.add ident
  inclOSInner ident, family, name, detectVerCmd, detectVerProc, verCmpCmd, verCmpProc,
      verMin, verMax, parDir, dllFrmt, altDirSep, objExt, newLine, pathSep, dirSep, cmdInterpreter, cmdExt, curDir, exeExt,
      extSep, props

macro inclOS*(ident: untyped, family: untyped, name = "",
    detectVerCmd = "", verCmpCmd = "",
    verMin = "", verMax = "", parDir = "", dllFrmt = "", altDirSep = "",
    objExt = "", newLine = "", pathSep = "", dirSep = "", cmdInterpreter = "", cmdExt = "",
    curDir = "", exeExt = "", extSep = "", props: set[OSProp] = {}) =
  var detectVerProcNoOp =
    nnkCall.newTree(
      newIdentNode("Option"),
      nnkCall.newTree(
        newIdentNode("none"),
        nnkProcTy.newTree(
          nnkFormalParams.newTree(
            newIdentNode("string")
          ),
          nnkPragma.newTree(
            newIdentNode("closure")
          )
        )
      )
    )
  var verCmpProcNoOp =
    nnkCall.newTree(
      newIdentNode("none"),
      nnkProcTy.newTree(
        nnkFormalParams.newTree(
          newIdentNode("bool"),
          nnkIdentDefs.newTree(
            newIdentNode("a"),
            newIdentNode("b"),
            newIdentNode("string"),
            newEmptyNode()
          )
        ),
        nnkPragma.newTree(
          newIdentNode("closure")
        )
      )
    )
  inclOSInner ident, family, name, detectVerCmd, detectVerProcNoOp, verCmpCmd, verCmpProcNoOp,
      verMin, verMax, parDir, dllFrmt, altDirSep, objExt, newLine, pathSep, dirSep, cmdInterpreter, cmdExt, curDir, exeExt,
      extSep, props

macro genOS* =
  result = newStmtList()
  result.add newEnum(ident"OS", osMacroCache.items.toSeq, true, true)
  let OSInfo = ident"OSInfo"
  result.add quote do:
    type
      `OSInfo`* = object
        family*: OS
        name*: string
        detectVerCmd*: string
        detectVerProc*: Option[proc(): string {.closure.}]
        verCmpCmd*: string
        verCmpProc*: Option[proc(a,b: string): bool {.closure.}]
        verMin*: string
        verMax*: string
        parDir*: string
        dllFrmt*: string
        altDirSep*: string
        objExt*: string
        newLine*: string
        pathSep*: string
        dirSep*: string
        cmdInterpreter*: string
        cmdExt*: string
        curDir*: string
        exeExt*: string
        extSep*: string
        props*: set[OSProp]
  proc infos: NimNode =
    result = nnkBracket.newTree
    for os in osMacroCache:
      let info = osInfoMacroCache[$os]
      result.add quote do: `info`
  result.add newConstStmt(ident"osInfos", infos())

macro inclCPU*(ident, name) =
  cpuMacroCache.add ident
macro inclCPU*(ident, name, intSize, endian, floatSize, bit) =
  cpuMacroCache.add ident
macro genCPU* =
  return newEnum(ident"CPU", cpuMacroCache.items.toSeq, true, true)

inclOS unknown, unknown
inclOS standalone, unknown
inclOS posix, standalone, "POSIX"
inclOS linux, posix, "Linux"
inclOS ubuntu, linux, "Ubuntu"
inclOS android, linux, "Android"
inclOS bsd, posix, "BSD"
inclOS darwin, bsd, "Darwin"

# system_profiler
inclOS(macos,
  family = darwin,
  name = "macOS",
  detectVerCmd = "sw_vers -productVersion",
  # detectVerProc = proc(): string {.closure.},
  # verCmpCmd = "",
  # verCmpProc = proc(): bool {.closure.},
  # verMin = "",
  # verMax = "",
  parDir = "..",
  dllFrmt = "lib{{name}}.dylib",
  altDirSep = "",
  objExt = "o",
  newLine = "",
  pathSep = ":",
  dirSep = "/",
  cmdInterpreter = "sh",
  cmdExt = "sh",
  curDir = ".",
  exeExt = "",
  extSep = "",
  props = {}
)
inclOS ios, macos, "iOS"

# https://en.wikipedia.org/wiki/List_of_Microsoft_Windows_versions
# TODO: possible cmds to get ver info:
# - systeminfo | findstr /B /C:"OS Name" /C:"OS Ver"
# - ver
# - wmic os get buildnumber,caption,CSDVer /format:csv
# - cpu: wmic os get oscpuitecture
# - cpu: echo %PROCESSOR_ARCHITECTURE%
inclOS(windows,
  family = standalone,
  name = "Windows",
  detectVerCmd = "hello",
  # detectVerProc = proc(): string {.closure.},
  # verCmpCmd = "",
  # verCmpProc = proc(): bool {.closure.},
  # verMin = "",
  # verMax = "",
  parDir = "",
  dllFrmt = "{{name}}.dll",
  altDirSep = "",
  objExt = "",
  newLine = "",
  pathSep = "",
  dirSep = "",
  cmdInterpreter = "cmd.exe",
  cmdExt = "bat",
  curDir = "",
  exeExt = "",
  extSep = "",
  props = {}
)

inclOS windows11, windows, "Windows 11"
inclOS windows10, windows, "Windows 10"
inclOS windows8, windows, "Windows 8"
inclOS windows7, windows, "Windows 7"

inclCPU unknown, "Unknown"
inclCPU i386, "i386", 32, littleEndian, 64, 32
inclCPU amd64, "amd64", 64, littleEndian, 64, 64
inclCPU m68k, "m68k", 32, bigEndian, 64, 32
inclCPU alpha, "alpha", 64, littleEndian, 64, 64
inclCPU powerpc, "powerpc", 32, bigEndian, 64, 32
inclCPU powerpc64, "powerpc64", 64, bigEndian, 64,64
inclCPU powerpc64el, "powerpc64el", 64, littleEndian, 64,64
inclCPU sparc, "sparc", 32, bigEndian, 64, 32
inclCPU hppa, "hppa", 32, bigEndian, 64, 32
inclCPU ia64, "ia64", 64, littleEndian, 64, 64
inclCPU mips, "mips", 32, bigEndian, 64, 32
inclCPU mipsel, "mipsel", 32, littleEndian, 64, 32
inclCPU arm, "arm", 32, littleEndian, 64, 32
inclCPU arm64, "arm64", 64, littleEndian, 64, 64
inclCPU js, "js", 32, littleEndian, 64, 32
inclCPU avr, "avr", 16, littleEndian, 32, 16
inclCPU msp430, "msp430", 16, littleEndian, 32, 16
inclCPU sparc64, "sparc64", 64, bigEndian, 64, 64
inclCPU mips64, "mips64", 64, bigEndian, 64, 64
inclCPU mips64el, "mips64el", 64, littleEndian, 64, 64
inclCPU riscv32, "riscv32", 32, littleEndian, 64, 32
inclCPU riscv64, "riscv64", 64, littleEndian, 64, 64
inclCPU esp, "esp", 32, littleEndian, 64, 32
inclCPU wasm32, "wasm32", 32, littleEndian, 64, 32
