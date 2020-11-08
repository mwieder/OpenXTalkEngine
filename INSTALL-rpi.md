# Compiling LiveCode for Raspberry Pi

## Configuring LiveCode

To configure LiveCode, simply run:

    make config-linux-armv7

## Compiling LiveCode

    make compile-linux-armv7

## Standard build environments

The following additional packages are dependencies:

* libfontconfig1-dev
* libx11-dev
* libxv-dev
* libffi-dev
* libxft-dev
* libgtk2.0-dev
* libgnome2-dev
* liblcms1-dev
* flex
* bison
* zip

To install the dependencies run:

    sudo apt install libfontconfig1-dev libx11-dev libxv-dev libffi-dev libxft-dev libgtk2.0-dev libgnome2-dev liblcms1-dev flex bison zip

If xlocale.h is not on your system (Ubuntu) then
    sudo ln -s /usr/include/locale.h /usr/include/xlocale.h

