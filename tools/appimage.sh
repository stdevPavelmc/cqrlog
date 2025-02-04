#!/bin/bash

# Fail early and fast
set -o errexit -o pipefail

# Simple recipe to generate an appimage for this app
#
# Requirements:
#   * VERSION as an ENV var, if not detected will use the values declared in
#     /src/uVersion.pas
#   * This must be run after a successfully docker build, and need to set the
#     APP var below to the path of the executable.
#   * Must be run on a Linux version as old as the far distro you need to
#     support, tested successfully on Ubuntu 20.04 LTS &  23.10
#
# If no parameter passed it's asumed to build as GTK2, if passed the parameter
# will be set as part of the name, for example QT5/QT6/GTK3, etc
#
# On any troubles invoke stdevPavelmc in github

# Tweak this please: this is the path of the cqrlog executable after a docker
# build in /usr/local/cqrlog-alpha
ROOTFOLDER=$(pwd)
APP="${ROOTFOLDER}/src/cqrlog"

# No need to tweak below unless you move files on the actual project
DESKTOP="${ROOTFOLDER}/tools/cqrlog.desktop"
ICON="${ROOTFOLDER}/images/icon/256x256/cqrlog.png"

# capturing the platform architecture
ARCH=$(uname -m)

# detecting the DE used
DE=GTK2
if [ "$1" ] ; then
    DE=$1
fi
echo "Building over the $DE desktop environment framework"

# clean log space
echo "==================================================================="
echo "                Starting to build the AppImage..."
echo "==================================================================="
echo ""

# get version numbres
VER=$(./tools/get_version.sh)
VER_NUMBER=$(./tools/get_version.sh 1)
export VERSION="${VER}_(${VER_NUMBER})"

# version notice
echo "You are building CQRLOG version: $VERSION"
echo ""

# basic tests
if [ ! -f "$APP" ] ; then
    echo "Error: the app file is no in the path we need it, update the APP var on this script"
    echo "APP=$APP"
    exit 1
fi

if [ ! -f "$DESKTOP" ] ; then
    echo "Error: can't find the desktop file, please update the DESKTOP var on the scriot"
    echo "DESKTOP=$DESKTOP"
    exit 1
fi

if [ ! -f "$ICON" ] ; then
    echo "Error: can't find the default icon, please update the ICON var in the script"
    echo "ICON=$ICON"
    exit 1
fi

# prepare the ground
rm -rdf AppDir 2>/dev/null
rm -rdf CQRLOG-*-${DE}-${ARCH}.AppImage 2>/dev/null

# notice
echo "Starting the build..."

# Create the AppDir & neede folders
TARGET="${ROOTFOLDER}/AppDir/usr/share/cqrlog"
mkdir -p ${TARGET}

# copy some utils we need
for f in ctyfiles help images members voice_keyer xplanet zipcodes ; do
    echo "Adding folder $f"
    cp -r "${ROOTFOLDER}/${f}" "${TARGET}/"
done

# copy all the icons
ICONS="${ROOTFOLDER}/images/icon/"
TARGET="${ROOTFOLDER}/AppDir/usr/share/icons/hicolor"
mkdir -p ${TARGET}
for i in $(ls $ICONS) ; do
    echo "Adding icons for '$i' sizes"
    mkdir -p "${TARGET}/${i}/apps/"
    cp "$ICONS/$i/cqrlog.png" "${TARGET}/${i}/apps/"
done

# detect libmysqlclient.so lib
LIBMYSQL=$(find /usr/lib/${ARCH}*/ -type f -name "*libmysqlclient.so*")
cp "$LIBMYSQL" "/tmp/libmysqlclient.so"
LIBMYSQL=/tmp/libmysqlclient.so

# detect hamlib bins
RIGCTL=$(which rigctl)
RIGCTLD=$(which rigctld)
ROTCTL=$(which rotctl)
ROTCTLD=$(which rotctld)

# detect mysql
MYSQL=$(which mysqld)

echo " "

# download & set all needed tools
wget -c -nv "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-${ARCH}.AppImage"
wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-appimage/releases/download/continuous/linuxdeploy-plugin-appimage-${ARCH}.AppImage"
if [ "$DE" == "QT5" ] ; then
    wget -c -nv "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-${ARCH}.AppImage"
fi
chmod a+x *.AppImage

# build (optional QT plugin if set)
QT=""
if [ "$DE" == "QT5" ] ; then
    QT="-p qt"
fi
./linuxdeploy-${ARCH}.AppImage \
    -e "$APP" \
    -e "$MYSQL" \
    -e "$RIGCTL" \
    -e "$RIGCTLD" \
    -e "$ROTCTL" \
    -e "$ROTCTLD" \
    -l "$LIBMYSQL" \
    $QT \
    -d "$DESKTOP" \
    -i "$ICON" \
    --output appimage \
    --appdir=./AppDir

RESULT=$?

# check build success
if [ $RESULT -ne 0 ] ; then
    # warning something gone wrong
    echo ""
    echo "ERROR: Aborting as something gone wrong, please check the logs"
    exit 1
else
    # success, adding the DE variables
    NAME=$(ls CQRLOG-*\)-${ARCH}.AppImage | cut -d ")" -f1)
    mv CQRLOG-*\)-${ARCH}.AppImage ${NAME}\)-${DE}-${ARCH}.AppImage
    echo ""
    echo "Success build, check your built apps files:"
    ls -lh CQRLOG-*.AppImage
fi
