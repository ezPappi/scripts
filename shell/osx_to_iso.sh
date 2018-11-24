#!/bin/sh
# Mac OSX ISO creator
# First download OSX from the App Store

hdiutil create -o /tmp/Mojave.cdr -size 6g -layout SPUD -fs HFS+J
hdiutil attach /tmp/Mojave.cdr.dmg -noverify -mountpoint /Volumes/install_build

sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume /Volumes/install_build
mv /tmp/Mojave.cdr.dmg ~/Mojave.cdr.dmg 
hdiutil detach /Volumes/Install\ macOS\ Mojave
    
hdiutil convert ~/Mojave.cdr.dmg -format UDTO -o ~/Desktop/Mojave.iso
mv ~/Desktop/Mojave.iso.cdr ~/Desktop/Mojave.iso
rm ~/Mojave.cdr.dmg

# To create bootable USB with OSX: 
# sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume /Volumes/USB_STICK --nointeraction
