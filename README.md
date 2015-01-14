Telegram for OSX
===========

[Telegram](http://telegram.org) is a messaging app with a focus on speed and security. It’s superfast, simple and free.

This repo contains official [Telegram Messenger](https://telegram.org/dl/osx) source code.

### API, Protocol documentation

Documentation for Telegram API is available here: http://core.telegram.org/api

Documentation for MTproto protocol is available here: http://core.telegram.org/mtproto

### For Quick Start Usage



1. Checkout repository
2. Create 'Application.h' file with this content:

```c
#ifndef Telegram_Application_h
#define Telegram_Application_h


#define API_ID 0000 // you can create new app on my.telegram.org
#define API_HASH @"" // you can create new app on my.telegram.org
#define HOCKEY_APP_IDENTIFIER @"" // hocheckey app
#define HOCKEY_APP_COMPANY @""  // hocheckey app
#define BUNDLE_IDENTIFIER @"ru.keepcoder.Telegram"  // bundle name
#endif
```

Code avaiable on GPLV2 license
