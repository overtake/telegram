//
//  ProfileSharedMediaView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 09.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ProfileSharedMediaView.h"
#import "UserInfoContainerView.h"
#import "TMMediaController.h"
@interface ProfileSharedMediaView ()
@end

@implementation ProfileSharedMediaView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        self.backgroundColor = NSColorFromRGB(0x00000);
        
//        _mediaCollection = [[TMCollectionViewController alloc] initWithNibName:@"TMCollectionViewController" bundle:nil];
//        
//        [self setAutoresizingMask:NSViewWidthSizable];
//        
//        
//        [self addSubview:_mediaCollection.view];
//        
//        [_mediaCollection.view setFrame:NSMakeRect(150, 1, self.bounds.size.width-150, 60)];
//        
//        [_mediaCollection.view setAutoresizingMask: NSViewWidthSizable];

        
    }
    return self;
}

//-(void)setConversation:(TL_conversation *)dialog {
////    [[TMMediaController controller] prepare:dialog completionHandler:^{
////        [_mediaCollection setItems:[TMMediaController controller]->items];
////        
////        [self setHidden:_mediaCollection.data.count == 0];
////        
////        
////        [self setNeedsDisplay:YES];
////    }];
//    
// 
//}

-(void)mouseUp:(NSEvent *)theEvent {
    [appWindow().navigationController showInfoPage:_conversation];

}

-(void)setNeedBorder:(BOOL)needBorder {
    self->_needBorder = needBorder;
    
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	
//    NSString *str = [NSString stringWithFormat:NSLocalizedString(@"%d shared media", nil), _mediaCollection.data.count];
//    
//    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:str attributes:[UserInfoContainerView attributsForInfoPlaceholderString]];
//    
//    [attributedString drawAtPoint:NSMakePoint(130 - attributedString.size.width, self.frame.size.height-20)];
//    
//    
//    if(_needBorder) {
//        [NSColorFromRGB(0xe6e6e6) set];
//        NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, 1));
//    }

}


@end
