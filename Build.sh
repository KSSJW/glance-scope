#!/bin/bash

flutter build linux --release
tar -cvzf build/linux-x86_64-release.tar.gz -C build/linux/x64/release/bundle .
echo -e '\e[32m[Done] Linux application packaging complete.\e[0m'

flutter build apk --release --split-per-abi
mv build/app/outputs/apk/release/app-arm64-v8a-release.apk build/android-arm64-v8a-release.apk
mv build/app/outputs/apk/release/app-armeabi-v7a-release.apk build/android-armeabi-v7a-release.apk
mv build/app/outputs/apk/release/app-x86_64-release.apk build/android-x86_64-release.apk
echo -e '\e[32m[Done] Android application packaging complete.\e[0m'
