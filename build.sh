 #
 # Copyright  2014, KiranAnto
 #
 # Custom build script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #
KERNEL_DIR=$PWD
MAIN_DIR=$KERNEL_DIR/..
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image
DTBTOOL=$KERNEL_DIR/tools/dtbToolCM
MODULES_DIR=$MAIN_DIR/RaZORBUILDOUTPUT/Common
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
# Modify the following variable if you want to build
export CROSS_COMPILE="$MAIN_DIR/TOOLCHAINS/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
export USE_CCACHE=1
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Kiran.Anto"
export KBUILD_BUILD_HOST="RaZor-Machine"
STRIP="$MAIN_DIR/TOOLCHAINS/aarch64-linux-android-4.9/bin/aarch64-linux-android-strip"


compile_kernel ()
{
rm -rf $MODULES_DIR/../Hydrogen/zImage
rm -rf $MODULES_DIR/../Hydrogen/modules/*
rm -rf $KERNEL_DIR/arch/arm64/boot/Image
find . -name '*.ko' -delete;
rm -rf $KERNEL_DIR/arch/arm64/boot/Image.gz
make hydrogen_user_defconfig
echo -e "                                        "
echo -e "****************************************"
echo -e "****************************************"
echo -e "                                        "
echo -e "                                        "
echo -e "    ________  ______  _____  ___  __    "
echo -e "   |___  ___|| _____||  _  ||   \/  |   "
echo -e "       | |   | |___  | /_\ ||       |   "
echo -e "       | |   |  ___| |  _  || |\ /| |   "
echo -e "       | |   | |____ | / \ || |   | |   "
echo -e "       |_|   |______||_| |_||_|   |_|   "
echo -e "  _____   _____  _______ _____  _____   "
echo -e " |  _  \ |  _  ||___   /|  _  ||  _  \  "
echo -e " | |_|  || /_\ |    / / | | | || |_|  | "
echo -e " |    _/ |  _  |   / /  | | | ||    _/  "
echo -e " | |\ \  | / \ |  / /   | | | || |\ \   "
echo -e " | | \ \ | | | | / /__  | |_| || | \ \  "
echo -e " |_|  \_\|_| |_|/_____| |_____||_|  \_\ "
echo -e "                                        "
echo -e "                                        "
echo -e "****************************************"
echo -e "****************************************"
make -j2
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
$DTBTOOL -2 -o $KERNEL_DIR/arch/arm64/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm64/boot/dts/
strip_modules
}


strip_modules ()
{
echo "Copying modules"
rm $MODULES_DIR/*
find . -name '*.ko' -exec cp {} $MODULES_DIR/ \;
cd $MODULES_DIR
echo "Stripping modules for size"
$STRIP --strip-unneeded *.ko
cd $KERNEL_DIR
}

case $1 in
clean)
make ARCH=arm64 -j8 clean mrproper
;;
*)
compile_kernel
;;
esac
cp $KERNEL_DIR/arch/arm64/boot/Image.gz  $MODULES_DIR/../Hydrogen/zImage
cp $KERNEL_DIR/arch/arm64/boot/dt.img  $MODULES_DIR/../Hydrogen/
cp $MODULES_DIR/* $MODULES_DIR/../Hydrogen/modules/
cd $MODULES_DIR/../Hydrogen
zipfile="RAZORTEST-MI_MAX-HYDROGEN.zip"
zip -r $zipfile etc modules patch ramdisk dt.img zImage anykernel.sh tools META-INF -x *kernel/.gitignore*
#dropbox_uploader -p upload $zipfile /test/
#dropbox_uploader share /$zipfile
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo "Enjoy RazorKernel"
