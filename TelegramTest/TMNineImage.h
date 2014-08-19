//
//  TMNineImage.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/23/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMNineImage : NSImage
- (id) initWithImage:(NSImage *)image ninePoint:(NSPoint)ninePoint;
@end

@interface NSImage(TMNineImage)
- (TMNineImage*) imageWithNinePoint:(NSPoint)ninePoint;
@end