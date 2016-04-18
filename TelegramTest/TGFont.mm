//
//  TGFont.m
//  Telegram
//
//  Created by keepcoder on 22/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGFont.h"
#import "NSObject+TGLock.h"
#import <map>


static std::map<int, CTFontRef> systemFontCache;
static std::map<int, CTFontRef> lightFontCache;
static std::map<int, CTFontRef> mediumFontCache;
static TG_SYNCHRONIZED_DEFINE(systemFontCache) = PTHREAD_MUTEX_INITIALIZER;

CTFontRef TGCoreTextSystemFontOfSize(CGFloat size)
{
    int key = (int)(size * 2.0f);
    CTFontRef result = NULL;
    
    TG_SYNCHRONIZED_BEGIN(systemFontCache);
    auto it = systemFontCache.find(key);
    if (it != systemFontCache.end())
        result = it->second;
    else
    {
        if (NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max) {
            result = CTFontCreateWithName(CFSTR(".SFUIText-Regular"), floor(size * 2.0f) / 2.0f, NULL);
        } else {
            result = CTFontCreateWithName(CFSTR("HelveticaNeue"), floor(size * 2.0f) / 2.0f, NULL);
        }
        systemFontCache[key] = result;
    }
    TG_SYNCHRONIZED_END(systemFontCache);
    
    return result;
}

CTFontRef TGCoreTextLightFontOfSize(CGFloat size)
{
    int key = (int)(size * 2.0f);
    CTFontRef result = NULL;
    
    TG_SYNCHRONIZED_BEGIN(systemFontCache);
    auto it = lightFontCache.find(key);
    if (it != lightFontCache.end())
        result = it->second;
    else
    {
        if (NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max) {
            result = CTFontCreateWithName(CFSTR(".SFUIText-Light"), floor(size * 2.0f) / 2.0f, NULL);
        } else {
            result = CTFontCreateWithName(CFSTR("HelveticaNeue-Light"), floor(size * 2.0f) / 2.0f, NULL);
        }
        lightFontCache[key] = result;
    }
    TG_SYNCHRONIZED_END(systemFontCache);
    
    return result;
}

CTFontRef TGCoreTextMediumFontOfSize(CGFloat size)
{
    int key = (int)(size * 2.0f);
    CTFontRef result = NULL;
    
    TG_SYNCHRONIZED_BEGIN(systemFontCache);
    auto it = mediumFontCache.find(key);
    if (it != mediumFontCache.end())
        result = it->second;
    else
    {
        if (NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max) {
            result = CTFontCreateWithName(CFSTR(".SFUIText-Medium"), floor(size * 2.0f) / 2.0f, NULL);
        } else {
            result = CTFontCreateWithName(CFSTR("HelveticaNeue-Medium"), floor(size * 2.0f) / 2.0f, NULL);
        }
        mediumFontCache[key] = result;
    }
    TG_SYNCHRONIZED_END(systemFontCache);
    
    return result;
}