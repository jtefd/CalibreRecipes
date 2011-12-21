#!/bin/bash

INSTALL_DIR=/usr/local/share/calibre/recipes

if [ ! -d "$INSTALL_DIR" ]; then
	mkdir -p "$INSTALL_DIR"
fi

[ $? -ne 0 ] && exit 1

cp -v *.recipe "$INSTALL_DIR"

[ $? -ne 0 ] && exit 1
