# -*- mode:sh -*-
exec >&2; set -x
set -- $1 ${1%.*} ${@:3}

case $(getconf LONG_BIT) in
  32) CPPFLAGS="$CPPFLAGS -D_M_IX86 -DASM_X86_V2" ;;
  64) CPPFLAGS="$CPPFLAGS -D_M_X64 -DASM_AMD64_C" ;;
esac
get_deps() {
  DEPS=""
  case $(getconf LONG_BIT) in
    32) DEPS="$DEPS aes_x86_v2.o" ;;
    64) DEPS="$DEPS aes_amd64.o" ;;
  esac
  echo "$DEPS aescrypt.o aeskey.o aestab.o aes_modes.o"
}

case $1 in
  all)
    redo-ifchange bgaes2.so bgaes2.a
    ;;
  clean)
    rm -f *.o *.d *.a *.so
    ;;
  distclean)
    redo clean
    rm -rf .redo
    ;;
  bgaes2.so)
    redo-ifchange $(get_deps)
    gcc $LDFLAGS $(get_deps) -shared -o $3
    ;;
  bgaes2.a)
    redo-ifchange $(get_deps)
    ar cr $3 $(get_deps)
    ;;
  *.o)
    if test -f $2.asm; then
      redo-ifchange $2.asm
      case $(getconf LONG_BIT) in
        32) yasm $CPPFLAGS -f elf32 -a x86 -m x86 -o $3 $2.asm ;;
        64) yasm $CPPFLAGS -f elf64 -a x86 -m amd64 -o $3 $2.asm ;;
      esac
    else
      redo-ifchange $2.c
      gcc -MD -MF $2.d -fPIC $CPPFLAGS $CFLAGS -c -o $3 $2.c
      read DEPS < $2.d
      redo-ifchange ${DEPS#*:}
    fi
    ;;
esac
