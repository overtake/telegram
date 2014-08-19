//
//  SelectUserItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectUserItem.h"
#import "TGUserCategory.h"
@implementation SelectUserItem

- (id)initWithObject:(TGContact *)object {
    if(self = [super initWithObject:object]) {
        self.title = [[NSMutableAttributedString alloc] init];
        self.lastSeen = [[NSMutableAttributedString alloc] init];
        
        self.contact = object;
        self.titleSize = NSZeroSize;
        self.lastSeenSize = NSMakeSize(200, 30);
        
        self.avatarPoint = NSMakePoint(15, (60 - 44) / 2);
        
        
        BOOL isOnline = self.contact.user.isOnline;
        
        
        
        self.titlePoint = NSMakePoint(67, 31);
        self.lastSeenPoint = NSMakePoint(67, 2);
     
        
        
        [self.title appendString:[object.user fullName] withColor:NSColorFromRGB(0x333333)];
        [self.lastSeen appendString:[object.user lastSeen] withColor:!isOnline ? NSColorFromRGB(0xaeaeae) : BLUE_UI_COLOR];
        
        [self.title setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
        [self.title setSelectionColor:NSColorFromRGB(0xfffffe) forColor:DARK_GREEN];
        
        [self.lastSeen setSelectionColor:NSColorFromRGB(0xfffffe) forColor:NSColorFromRGB(0xaeaeae)];
        [self.lastSeen setSelectionColor:NSColorFromRGB(0xffffff) forColor:LINK_COLOR];
        
    }
    return self;
}




- (NSObject *)itemForHash {
    return self.contact;
}

+ (NSUInteger) hash:(TGContact *)object {
    return [ @(object.user.n_id) hash];
}

@end
