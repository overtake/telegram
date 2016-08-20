//
//  TGPipWindow.h
//  Telegram
//
//  Created by keepcoder on 18/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
@interface TGPipWindow : NSWindow

-(id)initWithPlayer:(AVPlayerView *)player origin:(NSPoint)origin currentItem:(id)item;

+(void)close;

@end
