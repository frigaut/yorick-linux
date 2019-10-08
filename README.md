# yorick-linux

Yorick and yorick plugins installation scripts for linux. This should work for most distributions. The script downloads yorick, the yorick plugin sources and builds everything. It requires having installed the libraries needed by the plugins prior to running the script (and may need tweaking of the include and library paths in the various Makefiles depending on where your linux distro installs the libraries). **I strongly recommend to install the dependencies through your distro package manager** (apt-get or dpkg for debian/ubuntu, yum for Fedora/CentOS, pacman for archlinux), in which case the include files should be in /usr/include and the libraries in /usr/lib. Exception is for those libraries not available from your package manager (e.g. most likely epics, although there is a package for it in arch for instance).

The list of plugin target currently includes `yutils imutil soy yao ml4 opra spydr mpeg z svipc usleep yeti zeromq hdf5 syslog ca` . The list of Makefile targets include all of the above, as well as of course `yorick` and `plugins` which builds all plugins. If you don't want all plugins to be built, there is also a `myplugins` target which you can edit at will. You can also call each plugin individually with, e.g. `make imutil`.

## Installation

- Install dependencies:
  - for yorick-zeromq: you need the zeromq (zmq) libraries, e.g zeromq in arch, libzmq3-dev in ubuntu.
  - for yorick-yao: you need the fftw3 and fftw3-single packages
  - for yorick-hdf5: you need the hdf5 libraries, version 1.8 or 1.6
  - you will also need libpng and libjpeg, but these should be installed on regular linux installs
  - I have included yorick-ca, so you will need to install epics for this! If you don't need it, just remove ca from the list of packages in the Makefile
- Get yorick-linux:
  ```bash
  git clone https://github.com/frigaut/yorick-linux.git
  cd yorick-linux
  make yorick
  (note the comment about adding a line to your .bash_profile when this command is done)
  make plugins
  ```
  If you get an error message while building a plugin, it is probably because you need to modify the include or the library path in the plugin Makefile. You can cd to the plugin directory, edit the Makefile (add `-I/path/to/headers` to `PKG_CFLAGS` and/or `-L/path/to/libs` to `PKG_LDFLAGS`)
* You should be done. Now you can call yorick from a terminal (providing you have exported the PATH as above):
  ```bash
  yorick # for yorick
  yorick -i yao.i # for yao
  yao # to get the yao GUI
  ```
