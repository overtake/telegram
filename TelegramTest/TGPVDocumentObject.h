//
//  TGPVDocumentObject.h
//  Telegram
//
//  Created by keepcoder on 06.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGImageObject.h"

@interface TGPVDocumentObject : TGImageObject

-(id)initWithMessage:(TL_localMessage *)message placeholder:(NSImage *)placeholder;
@end
