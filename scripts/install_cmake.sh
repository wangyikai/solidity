#!/usr/bin/env sh

# This script downloads the CMake binary and installs it in ~/.local directory
# (the cmake executable will be in ~/.local/bin).
# This is mostly suitable for CIs, not end users.

set -e

VERSION=3.12.4
PREFIX=~/.local

OS=$(uname -s)
case $OS in
Linux)  SHA256=486edd6710b5250946b4b199406ccbf8f567ef0e23cfe38f7938b8c78a2ffa5f;;
Darwin) SHA256=95d76c00ccb9ecb5cb51de137de00965c5e8d34b2cf71556cf8ba40577d1cff3;;
esac


BIN=$PREFIX/bin

PATH=$PREFIX/bin:$PATH

if test -f $BIN/cmake && ($BIN/cmake --version | grep -q "$VERSION"); then
    echo "CMake $VERSION already installed in $BIN"
else
    FILE=cmake-$VERSION-$OS-x86_64.tar.gz
    URL=https://cmake.org/files/v3.12/$FILE
    ERROR=0
    TMPFILE=$(mktemp --tmpdir cmake-$VERSION-$OS-x86_64.XXXXXXXX.tar.gz)
    echo "Downloading CMake ($URL)..."
    wget "$URL" -O "$TMPFILE" -nv
    if ! (shasum -a256 "$TMPFILE" | grep -q "$SHA256"); then
        echo "Checksum mismatch ($TMPFILE)"
        exit 1
    fi
    mkdir -p "$PREFIX"
    tar xzf "$TMPFILE" -C "$PREFIX" --strip 1
    rm $TMPFILE
fi
