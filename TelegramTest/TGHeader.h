//
//  TGHeader.h
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#ifndef Telegram_TGHeader_h
#define Telegram_TGHeader_h

#define TGOUTMESSAGE 0x2
#define TGUNREADMESSAGE 0x1
#define TGOUTUNREADMESSAGE 0x3
#define TGNOFLAGSMESSAGE 0x0
#define TGFWDMESSAGE 0x4
#define TGREPLYMESSAGE 0x8
#define TGMENTIONMESSAGE 16
#define TGREADEDCONTENT 32
#define TGFROMIDMESSAGE 256
#define TGSESSIONCURRENT 0x1
#define TGSESSIONOFFICIAL 0x2

#define TGMINFAKEID 1500000000
#define TGMINSECRETID 800000000


// flags.10 = self
// flags.11 - contact
// flags.12 - mutual contact
// flags.13 - deleted
// flags.14 - bot
// flags.15 - bot reading all the group history


#define TGUSERFLAGSELF 1 << 10
#define TGUSERFLAGCONTACT 1 << 11
#define TGUSERFLAGMUTUAL 1 << 12
#define TGUSERFLAGDELETED 1 << 13
#define TGUSERFLAGBOT 1 << 14
#define TGUSERFLAGREADHISTORY 1 << 15
#define TGBOTGROUPBLOCKED 1 << 16

#define API_VERSION  [NSString stringWithFormat:@"%@.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]

#define IS_RETINA ([[NSScreen mainScreen] backingScaleFactor] == 2.0)

#import <objc/runtime.h>
#define DYNAMIC_PROPERTY(Name) static char k##Name; - (id) get##Name { return objc_getAssociatedObject(self, &k##Name);}; - (void) set##Name:(id)object { objc_setAssociatedObject(self, &k##Name, object, OBJC_ASSOCIATION_RETAIN); }


#define ELog(fmt, ...) NSLog((@"ERROR %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define SLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define PLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define CHECK_LOCKER(isLocked) if(isLocked) return;


#define NSColorFromRGB(rgbValue) [NSColor colorWithDeviceRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define NSColorFromRGBWithAlpha(rgbValue, alphaValue) [NSColor colorWithDeviceRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(alphaValue)]

//#define TGSystemFont(s) [NSFont fontWithName:@"HelveticaNeue" size:(s)]
//#define TGSystemMediumFont(s) [NSFont fontWithName:@"HelveticaNeue-Medium" size:(s)]
//#define TGSystemLightFont(s) [NSFont fontWithName:@"HelveticaNeue-Light" size:(s)]
//#define TGSystemItalicFont(s) [NSFont fontWithName:@"HelveticaNeue-Italic" size:(s)]
//#define TGSystemBoldItalicFont(s) [NSFont fontWithName:@"HelveticaNeue-BoldItalic" size:(s)]
//#define TGSystemBoldFont(s) [NSFont fontWithName:@"HelveticaNeue-Bold" size:(s)]

//[NSFont fontWithName:@".SFNSDisplay-Regular" size:(s)]
//[NSFont fontWithName:@".SFNSText-Medium" size:(s)]
//[NSFont fontWithName:@".SFNSText-Regular" size:(s)]
#define TGSystemFont(s) NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max ? [NSFont systemFontOfSize:(s)] : [NSFont fontWithName:@"HelveticaNeue" size:(s)]
#define TGSystemMediumFont(s) NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max ? [NSFont fontWithName:@".SFNSDisplay-Semibold" size:(s)] : [NSFont fontWithName:@"HelveticaNeue-Medium" size:(s)]
#define TGSystemLightFont(s) NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max ? [NSFont systemFontOfSize:(s)  weight:0] : [NSFont fontWithName:@"HelveticaNeue-Light" size:(s)]
#define TGSystemItalicFont(s) NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max ? [NSFont fontWithName:@".SFNSText-Italic" size:(s)] : [NSFont fontWithName:@"HelveticaNeue-Italic" size:(s)]
#define TGSystemBoldItalicFont(s) NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max ? [NSFont fontWithName:@".SFNSText-BoldItalic" size:(s)] : [NSFont fontWithName:@"HelveticaNeue-BoldItalic" size:(s)]
#define TGSystemBoldFont(s) NSAppKitVersionNumber > NSAppKitVersionNumber10_10_Max ? [NSFont fontWithName:@".SFNSDisplay-Semibold" size:(s)] : [NSFont fontWithName:@"HelveticaNeue-Bold" size:(s)]


#define VIDEO_COMPRESSED_PROGRESS 10.0f
#define MAX_FILE_SIZE 1500000000

#define MIN_FILE_DOWNLOAD_SIZE 10*1024*1024

#define LIGHT_BLUE NSColorFromRGB(0x99b8d0)
#define DARK_BLUE NSColorFromRGB(0x57a4e1)
#define BLUE_UI_COLOR NSColorFromRGB(0x2481cc) //0x1d80cc
#define LIGHT_GRAY NSColorFromRGB(0xa1a1a1)
#define DARK_GRAY NSColorFromRGB(0xa0a0a0)
#define VERY_GRAY NSColorFromRGB(0x909090)
#define DARK_GREEN NSColorFromRGB(0x458b42)
#define DARK_BLACK NSColorFromRGB(0x222222)
#define TEXT_COLOR NSColorFromRGB(0x060606)
#define GRAY_TEXT_COLOR NSColorFromRGB(0x999999)
#define DIALOG_BORDER_COLOR NSColorFromRGB(0xeaeaea)
#define DIALOG_BORDER_WIDTH 1
#define BLUE_COLOR_SELECT NSColorFromRGB(0x4c91c7)
#define GRAY_BORDER_COLOR NSColorFromRGB(0xe4e4e4)
#define LIGHT_GRAY_BORDER_COLOR NSColorFromRGB(0xededed)
#define LINK_COLOR BLUE_UI_COLOR
#define BLUE_SEPARATOR_COLOR NSColorFromRGB(0x66A7DB)
#define MIN_IMG_SIZE NSMakeSize(250,40)
#define weakify() __block __typeof(&*self)strongSelf = self;

#define weak() __weak typeof(self) weakSelf = self;

#define APP_VERSION [[[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] intValue]

#import "CFunctions.h"

#endif
