# yorick build system
# Translated from Makefile

YORICK_VERSION := "2.2"
PY_VERSION     := "2.7"
YORICK         := justfile_directory() + "/yorick/relocate/bin/yorick"
UNAME_M        := `uname -m`

# Show build environment info
env:
    @echo "yorick version     = {{YORICK_VERSION}}"
    @echo "yorick binary      = {{YORICK}}"
    @echo "arch               = {{UNAME_M}}"
    @sleep 1

# Build yorick and main plugins
all: env
    just yorick
    just myplugins

# Clone or update a github repo into plugins/
# Usage: just init_update_git <dir> <github_user>
init_update_git dir user:
    #!/usr/bin/env bash
    mkdir -p plugins && cd plugins
    if [ -d "{{dir}}" ]; then
        cd "{{dir}}"
        default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
        git reset --hard "$default_branch"
    else
        git clone git@github.com:{{user}}/{{dir}}.git
    fi

# Build and install a standard plugin from plugins/<dir>
make_plug plugin_dir:
    #!/usr/bin/env bash
    set -euo pipefail
    cd plugins/{{plugin_dir}}
    sed -i -E 's|/usr/bin/env python$|/usr/bin/env python{{PY_VERSION}}|' *.py 2>/dev/null || true
    {{YORICK}} -batch make.i
    make clean
    make
    make install

# Build yorick itself
yorick: env
    #!/usr/bin/env bash
    set -euo pipefail
    printf '\n>>> If "make config" hangs at "using FPU_GNU_FENV", you may be on Apple hardware\n'
    printf '>>> Try "export FPU_IGNORE=yes" before calling "just yorick"\n\n'
    if [ "{{UNAME_M}}" = "aarch64" ]; then
        export FPU_IGNORE=yes
        echo ">>> aarch64 detected: setting FPU_IGNORE=yes"
    fi
    if [ ! -d yorick ]; then
        git clone https://github.com/LLNL/yorick.git
        patch -d yorick -p1 < yorick-git-xft.patch
    fi
    cd yorick
    make config Y_HOME=relocate
    echo 'COPT_DEFAULT=-O2 -ffast-math' >> Make.cfg
    echo 'Y_CFLAGS=-DHAVE_XFT'          >> Make.cfg
    echo 'XINC=-I/usr/include/freetype2' >> Make.cfg
    echo 'XLIB=-lXft'                    >> Make.cfg
    echo "X11LIB=-lXft -lX11 -lfontconfig" >> Make.cfg
    make && make install
    printf '\nAdd this to your ~/.bash_profile:\n'
    printf 'export PATH="%s/yorick/relocate/bin:$PATH"\n' "{{justfile_directory()}}"

# Build my standard set of plugins
# myplugins: yutils imutil soy yao ml4 optimpack vmlmb vops spydr z usleep yeti
myplugins: z usleep yeti

# Build all supported plugins
plugins: yutils imutil soy yao ml4 optimpack vmlmb vops opra spydr z svipc usleep yeti zeromq hdf5

# --- Individual plugins ---

yutils: env
    @printf '\n>>> BUILDING yutils\n'
    just init_update_git yorick-yutils frigaut
    just make_plug yorick-yutils

imutil: env
    @printf '\n>>> BUILDING imutil\n'
    just init_update_git yorick-imutil frigaut
    cd plugins/yorick-imutil && {{YORICK}} -batch make.i && make clean && make install

zeromq: env
    @printf '\n>>> BUILDING zeromq\n'
    just init_update_git yorick-zeromq frigaut
    cd plugins/yorick-zeromq && {{YORICK}} -batch make.i && make clean && make install

soy: env
    @printf '\n>>> BUILDING soy\n'
    just init_update_git yorick-soy frigaut
    just make_plug yorick-soy

optimpack: env
    @printf '\n>>> BUILDING optimpack\n'
    just init_update_git yorick-optimpack frigaut
    cd plugins/yorick-optimpack && ./autogen.sh && ./configure --prefix="{{justfile_directory()}}/yorick/relocate"
    cd plugins/yorick-optimpack && make CFLAGS="-Wno-error=maybe-uninitialized"
    cd plugins/yorick-optimpack && make install

vmlmb: env
    @printf '\n>>> BUILDING vmlmb\n'
    just init_update_git yorick-vmlmb frigaut
    cd plugins/yorick-vmlmb/yorick && ./configure && make install

vops: env
    @printf '\n>>> BUILDING vops\n'
    just init_update_git yor-vops frigaut
    cd plugins/yor-vops && ./configure copt="-O3 -ffast-math" && make install

yao: env
    @printf '\n>>> BUILDING yao\n'
    just init_update_git yao frigaut
    cp plugins/yao/Makefile.template plugins/yao/Makefile
    just make_plug yao

ml4: env
    @printf '\n>>> BUILDING ml4\n'
    just init_update_git yorick-ml4 frigaut
    just make_plug yorick-ml4

ca: env
    @printf '\n>>> BUILDING ca\n'
    just init_update_git yorick-ca frigaut
    just make_plug yorick-ca

syslog: env
    @printf '\n>>> BUILDING syslog\n'
    just init_update_git yorick-syslog frigaut
    just make_plug yorick-syslog

opra: env
    @printf '\n>>> BUILDING opra\n'
    just init_update_git yorick-opra frigaut
    cd plugins/yorick-opra && git checkout opra-tomo
    rm -rf yorick/relocate/share/opra
    just make_plug yorick-opra

spydr: env
    @printf '\n>>> BUILDING spydr\n'
    just init_update_git yorick-spydr frigaut
    just make_plug yorick-spydr

hdf5: env
    @printf '\n>>> BUILDING hdf5\n'
    just init_update_git yorick-hdf5 frigaut
    just make_plug yorick-hdf5

mpeg: env
    @printf '\n>>> BUILDING mpeg\n'
    just init_update_git yorick-mpeg frigaut
    cd plugins/yorick-mpeg && {{YORICK}} -batch make.i
    just make_plug yorick-mpeg

z: env
    #!/usr/bin/env bash
    set -euo pipefail
    printf '\n>>> BUILDING z\n'
    just init_update_git yorick-z frigaut
    cd plugins/yorick-z
    ./configure
    { echo "PKG_I=zlib.i png.i jpeg.i"
      echo "OBJS=yzlib.o spng.o ypng.o yjpeg.o"
      echo "PKG_I_START=yorz.i"
      echo "ZLIB_INC="
      echo "PNG_INC="
      echo "JPEG_INC="
      echo "AVCODEC_INC="
    } > Makeyorz
    {{YORICK}} -batch make.i
    make
    make install

svipc: env
    @printf '\n>>> BUILDING svipc\n'
    just init_update_git yp-svipc frigaut
    cd plugins/yp-svipc/yorick && {{YORICK}} -batch make.i && make clean && make install

usleep: env
    @printf '\n>>> BUILDING usleep\n'
    just init_update_git yorick-usleep frigaut
    just make_plug yorick-usleep

yeti: env
    @printf '\n>>> BUILDING yeti\n'
    just init_update_git yorick-yeti frigaut
    cd plugins/yorick-yeti && ./configure --yorick={{YORICK}}
    cd plugins/yorick-yeti && make clean && make all && make install

# --- Maintenance ---

clean:
    rm -rf yorick plugins yorick-{{YORICK_VERSION}} yorick.pmdoc

cleaninstall:
    rm -i -rf ~/.yorick/relocate

install:
    cp -i -pr ./yorick/relocate/ ~/.yorick/.
