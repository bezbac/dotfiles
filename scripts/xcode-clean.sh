#!/bin/bash

echo "Removing unused xcode files"

cd /Applications/Xcode.app/Contents/Developer/Platforms/
sudo rm -rf AppleTV* Watch* iPhone*

rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/