#!/bin/bash
# mac script to generate icons for iOS and Android targets.
# icon-full.png should be the full size, preferably 1024x1024.

# iOS ====
cp icon-full.png iTunesArtwork.png
cp icon-full.png iTunesArtwork@2x.png
sips -z 1024 1024 iTunesArtWork@2x.png
sips -z 512 512 iTunesArtWork.png
mv iTunesArtWork.png iTunesArtWork
mv iTunesArtWork@2x.png iTunesArtWork@2x

cp icon-full.png Icon.png
cp icon-full.png Icon@2x.png
sips -z 57 57 Icon.png
sips -z 114 114 Icon@2x.png

cp icon-full.png Icon-60.png
cp icon-full.png Icon-60@2x.png 
sips -z 60 60 Icon-60.png
sips -z 120 120  Icon-60@2x.png

cp icon-full.png Icon-72.png
cp icon-full.png Icon-72@2x.png
sips -z 72 72 Icon-72.png
sips -z 144 144 Icon-72@2x.png

cp icon-full.png Icon-76.png
cp icon-full.png Icon-76@2x.png
sips -z 76 76 Icon-76.png
sips -z 152 152 Icon-76@2x.png

# android ====
mkdir android
mkdir android/drawable-ldpi
mkdir android/drawable-mdpi
mkdir android/drawable-hdpi
mkdir android/drawable-xhdpi
mkdir android/drawable-xxhdpi

cp icon-full.png android/drawable-ldpi/icon.png
cp icon-full.png android/drawable-mdpi/icon.png
cp icon-full.png android/drawable-hdpi/icon.png
cp icon-full.png android/drawable-xhdpi/icon.png
cp icon-full.png android/drawable-xxhdpi/icon.png
sips -z 36 36 android/drawable-ldpi/icon.png
sips -z 48 48 android/drawable-mdpi/icon.png
sips -z 72 72 android/drawable-hdpi/icon.png
sips -z 96 96 android/drawable-xhdpi/icon.png
sips -z 144 144 android/drawable-xxhdpi/icon.png
