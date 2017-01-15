Telegram for OSX
===========

[Telegram](http://telegram.org) is a messaging app with a focus on speed and security. It’s superfast, simple and free.

This repo contains official [Telegram for macOS](https://macos.telegram.org/) source code.

### API, Protocol Documentation

Documentation for Telegram API is available here: http://core.telegram.org/api

Documentation for MTproto protocol is available here: http://core.telegram.org/mtproto

### Setting Up

1. Checkout repository.
1. `git submodule update --init --recursive`
1. Open with Xcode.
1. Click on `SSignalKit.xcodeproj` and under the "Build Settings" tab, change "Base SDK" to macOS.
1. Click on `SSignalKit` target and change "ENABLE_BITCODE" from `YES` to `NO`.

### License

GPL V2
