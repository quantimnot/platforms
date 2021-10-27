import platforms_define
import strutils, options

genCPU
genOS

type
  Platform* = object
    os*: OS
    cpu*: CPU

func nimCpuToCPU*(): CPU {.compileTime.} =
  when defined i386: return i386
  elif defined m68k: return m68k
  elif defined alpha: return alpha
  elif defined powerpc: return powerpc
  elif defined powerpc64: return powerpc64
  elif defined powerpc64el: return powerpc64el
  elif defined sparc: return sparc
  elif defined sparc64: return sparc64
  elif defined hppa: return hppa
  elif defined ia64: return ia64
  elif defined amd64: return amd64
  elif defined mips: return mips
  elif defined mipsel: return mipsel
  elif defined mips64: return mips64
  elif defined mips64el: return mips64el
  elif defined arm: return arm
  elif defined arm64: return arm64
  elif defined avr: return avr
  elif defined msp430: return msp430
  elif defined riscv32: return riscv32
  elif defined riscv64: return riscv64
  elif defined wasm32: return wasm32

func nimOSToOS*(): OS {.compileTime.} =
  when defined(windows): OS.windows
  elif defined(dos): OS.dos
  elif defined(os2): OS.os2
  elif defined(linux): OS.linux
  elif defined(morphos): OS.morphos
  elif defined(skyos): OS.skyos
  elif defined(solaris): OS.solaris
  elif defined(irix): OS.irix
  elif defined(netbsd): OS.netbsd
  elif defined(freebsd): OS.freebsd
  elif defined(openbsd): OS.openbsd
  elif defined(aix): OS.aix
  elif defined(palmos): OS.palmos
  elif defined(qnx): OS.qnx
  elif defined(amiga): OS.amiga
  elif defined(atari): OS.atari
  elif defined(netware): OS.netware
  elif defined(macosx): OS.macos
  elif defined(macos): OS.macos
  elif defined(haiku): OS.haiku
  elif defined(android): OS.android
  elif defined(js): OS.js
  elif defined(standalone): OS.standalone
  elif defined(nintendoswitch): OS.nintendoswitch
  else: OS.unknown

const platform* =
  Platform(
    os: nimOSToOS(),
    cpu: nimCpuToCPU(),
  )

func os*(os: string): OS =
  parseEnum[OS](os)

func cpu*(cpu: string): CPU =
  parseEnum[CPU](cpu)

func info*(os: OS): OSInfo =
  osInfos[os.ord]

proc detectVer*(os: OS): string =
  let info = os.info
  if info.detectVerProc.isSome:
    # TODO: call detection proc
    discard
  elif info.detectVerCmd.len > 0:
    # TODO: call detection cmd
    discard

proc os*(): OS =
  for os in OS:
    let ver = detectVer os
    if ver.len > 0:
      return os
  OS.unknown

proc cpu*(): CPU =
  # TODO: implement CPU detection
  CPU.unknown
