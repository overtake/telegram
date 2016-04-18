//
//  TGFont.h
//  Telegram
//
//  Created by keepcoder on 22/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

#ifdef __cplusplus
extern "C" {
#endif

CTFontRef TGCoreTextMediumFontOfSize(CGFloat size);
CTFontRef TGCoreTextLightFontOfSize(CGFloat size);
CTFontRef TGCoreTextSystemFontOfSize(CGFloat size);

#ifdef __cplusplus
}
#endif
