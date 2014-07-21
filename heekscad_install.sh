#!/bin/bash
DEPENDS="subversion fakeroot  dpkg-dev libboost-python-dev liboce-*"
DEPENDS="$DEPENDS oce-draw libgtkglext1-dev libboost-dev bzr"
WORK_DIR="${HOME}/heeks"
MAKEFLAGS="-j2"

src_libarea="http://code.google.com/p/libarea/"
src_heekscad="http://code.google.com/p/heekscad/"
src_heekscnc="http://code.google.com/p/heekscnc/"
src_opencamlib="https://github.com/aewallin/opencamlib.git"
src_debianize_ocl="lp:~neomilium/opencamlib/packaging"

echo " _   _           _         ____    _    ____  "
echo "| | | | ___  ___| | _____ / ___|  / \  |  _ \ "
echo "| |_| |/ _ \/ _ \ |/ / __| |     / _ \ | | | |"
echo "|  _  |  __/  __/   <\__ \ |___ / ___ \| |_| |"
echo "|_| |_|\___|\___|_|\_\___/\____/_/   \_\____(_) "
echo "          Install or Update Script for "
echo "              Debian based Distros"
echo ""

if [ "$1" != "--update-or-install" ]; then
    echo "usage: $0 --update-or-install"
    echo ""
    echo "This script downloads and installs opencamlib from github,"
    echo "libarea, heekscad and heekscnc from googlecode on debian"
    echo "based linux distributions. All is packeged as .deb and "
    echo "installed via dpgk."
    echo ""
    echo "Source is downloaded to:"
    echo "      $WORK_DIR"
    exit 1
fi

echo " --> Installing dependencies ..."
sudo apt-get install $DEPENDS || exit -1

echo " --> Getting sources ..."
mkdir -p $WORK_DIR 2>/dev/zero
cd $WORK_DIR
rm *.deb 2>/dev/zero

if [ -d "${WORK_DIR}/heekscad" ]; then
    cd "${WORK_DIR}/heekscad" && svn update
else
    cd $WORK_DIR && svn checkout $src_heekscad heekscad
fi
if [ -d "${WORK_DIR}/heekscnc" ]; then
    cd "${WORK_DIR}/heekscnc" && svn update
else
    cd $WORK_DIR && svn checkout $src_heekscnc heekscnc
fi
if [ -d "${WORK_DIR}/libarea" ]; then
    cd "${WORK_DIR}/libarea" && svn update
else
    cd $WORK_DIR && svn checkout $src_libarea libarea
fi
if [ -d "${WORK_DIR}/opencamlib" ]; then
    cd "${WORK_DIR}/opencamlib" && git pull
    cd "debian" && bzr merge
else
    cd $WORK_DIR && git clone $src_opencamlib
    bzr branch $debianize_ocl debian    
fi

echo " --> Building libarea ..."
cd "${WORK_DIR}/libarea"
dpkg-buildpackage -b
cd .. && sudo dpkg -i libarea*.deb python-area*.deb

echo " --> Building heekscad ..."
cd "${WORK_DIR}/heekscad"
dpkg-buildpackage -b
cd .. && sudo dpkg -i heekscad*.deb libheekstinyxml*.deb

echo " --> Building heekscnc ..."
cd "${WORK_DIR}/opencamlib"

dpkg-buildpackage -b -us -uc
cd .. && sudo dpkg -i python-ocl*.deb

cd "${WORK_DIR}/heekscnc"
dpkg-buildpackage -b
cd .. && sudo dpkg -i heekscnc*.deb
