#!/usr/bin/bash

# Extracts .mui files from Windows language packs.
# dependencies: httpdirfs, 7z
# mkdir a mount point mount/, then use the following command to mount language packs:
# httpdirfs --cache "https://archive.org/download/windows-7-mui-all-language-packs-sp0-sp1-x86-x64/win7-sp1-x64-mui/" mount
# The .mui files will be produced to an output folder named according to its locale.
# NOTE: zh-TW locale was extracted manually from an SP1 ISO

mkdir locales

for filename in mount/*; do
    LOCALE_NAME=$(echo "$filename" | awk -F 'mount/windows6.1-kb2483139-x64-|_' '{print $2}');
    readarray files <<< $(7z l -ba -slt "$filename" | grep -iP "chess.exe.mui|freecell.exe.mui|hearts.exe.mui|mahjong.exe.mui|minesweeper.exe.mui|purbleplace.exe.mui|solitaire.exe.mui|spidersolitaire.exe.mui" | cut -c 8-);
    mkdir -p "locales/$LOCALE_NAME"
    for file in "${files[@]}"; do
        DIR_NAME=$(dirname "$file");
        FILE_NAME=$(basename "$file")
        7z x $filename $file
        mv "$DIR_NAME/$FILE_NAME" "locales/$LOCALE_NAME"
        rm -rf $DIR_NAME
    done;
done