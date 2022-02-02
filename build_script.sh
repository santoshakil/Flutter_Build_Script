#!/bin/zsh

# This script is used to build apk.

# get the app name from pubspec.yaml
appName=$(cat pubspec.yaml | grep name | awk '{print $2}' | tr -d '"')

# get the prevois version
previousVersion=$(grep -oP '(?<=version: ).*' pubspec.yaml)

# get the current version
newVersion=$(echo $previousVersion | awk -F. '{$NF+=1}1' | sed 's/ /./g')

# get the previous build number
previousBuildNumber=$(echo $previousVersion | awk -Fdev '{print $NF}')

# get the new version
newVersion="$newVersion+dev$((previousBuildNumber + 1))"

# get the new build number
newBuildNumber=$((previousBuildNumber + 1))

# update the version in pubspec.yaml
sed -i "s/$previousVersion/$newVersion/g" pubspec.yaml

# git task
git add .
git commit -m "Update version to $newVersion"
git push

# build the apk
flutter build apk --split-per-abi --release --build-name=$newVersion --build-number=$newBuildNumber

# create a folder named $appName if it doesn't exist
if [ ! -d ~/Documents/$appName ]; then
    mkdir ~/Documents/$appName
fi

# rename the apks
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk ~/Documents/$appName/$appName-$newVersion-arm.apk
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk ~/Documents/$appName/$appName-$newVersion-arm64.apk

echo "$appName has been built and saved to ~/Documents/$appName"
echo "Previous Version was $previousVersion"
echo "New Version is $newVersion"
echo "Previous Build Number $previousBuildNumber"
echo "New Build Number is $newBuildNumber"
