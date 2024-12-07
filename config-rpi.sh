#/bin/bash

case $(uname -m) in
	x86_64)
		HOST_ARCH=x86_64
		;;
	i*86)
		HOST_ARCH=i386
		;;
	arm*)
		HOST_ARCH=armv6hf
		;;
esac

if [ ${HOST_ARCH} == x86_64 ] ;
	./config.sh --cross --platform linux-armv6hf --cc-prefix ${HOME}/x-tools/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf- --sysroot ${HOME}/x-tools/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot --aux-sysroot /var/lib/schroot/chroots/jessie-armhf --triple arm-linux-gnueabihf
else
	./config.sh --cross --platform linux-armv6hf --cc-prefix ${HOME}/x-tools/arm-rpi-linux-gnueabihf/bin/arm-rpi-linux-gnueabihf- --sysroot ${HOME}/x-tools/arm-rpi-linux-gnueabihf/arm-rpi-linux-gnueabihf/sysroot --aux-sysroot /var/lib/schroot/chroots/jessie-armhf --triple arm-linux-gnueabihf
fi
