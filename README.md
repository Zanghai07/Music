# MusicPlayer iOS 10

Simple Objective-C music player for jailbroken iOS 10 devices. It uses the system music library picker and packages an ad-hoc signed `.ipa` for AppSync installation.

## Build on GitHub Actions

1. Push this repository to GitHub.
2. Open the repository's **Actions** tab.
3. Run **Build IPA** manually, or push to `main` / `master`.
4. Download the `MusicPlayer-ipa` artifact.
5. Install `MusicPlayer.ipa` on the jailbroken device with AppSync installed.

## Local build with Theos

```sh
export THEOS=/path/to/theos
chmod +x ./build-ipa.sh
./build-ipa.sh
```

The IPA is written to:

```text
build/MusicPlayer.ipa
```

## Notes

- Target minimum iOS version is `10.0`.
- The GitHub Actions workflow uses Theos with the iPhoneOS 10.3 SDK for legacy 32-bit devices.
- The current CI build is `armv7`, suitable for iPhone 5 on iOS 10.3.3.
- The app plays songs chosen from the device music library.
