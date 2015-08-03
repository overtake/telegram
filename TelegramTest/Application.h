//
//  Application.h
//  Telegram
//
//  Created by keepcoder on 19.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#ifndef Telegram_Application_h
#define Telegram_Application_h


#define API_ID 2834
#define API_HASH @"68875f756c9b437a8b916ca3de215815"

#ifdef TGDEBUG

#ifdef TGStable

#define HOCKEY_APP_IDENTIFIER @"d77af558b21e0878953100680b5ac66a"

#else 

#define HOCKEY_APP_IDENTIFIER @"c55f5e74ae5d0ad254df29f71a1b5f0e"

#endif

#else

#define HOCKEY_APP_IDENTIFIER @"715197b9fde97522d67b323b316412aa"

#endif



#define HOCKEY_APP_COMPANY @"VIKO"


#define BUNDLE_IDENTIFIER @"ru.keepcoder.Telegram"
#endif
