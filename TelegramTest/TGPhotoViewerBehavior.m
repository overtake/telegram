//
//  TGPhotoViewerBehavior.m
//  Telegram
//
//  Created by keepcoder on 09/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGPhotoViewerBehavior.h"
#import "ChatHistoryController.h"
@implementation TGPhotoViewerBehavior

-(id)initWithConversation:(TL_conversation *)conversation commonItem:(PreviewObject *)object {
    if(self = [super init]) {
        
    }
    
    return self;
}

-(void)drop {
    [_controller drop:YES];
    _controller = nil;
}

@end
