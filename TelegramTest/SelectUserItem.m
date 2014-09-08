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
        self.lastSeenSize = NSMakeSize(200, 20);
        
        self.avatarPoint = NSMakePoint(50, (50 - 36) / 2);
        
        
        self.rightBorderMargin = 23;
        
        
        BOOL isOnline = self.contact.user.isOnline;
        
        
        
        self.titlePoint = NSMakePoint(97, 25);
        self.lastSeenPoint = NSMakePoint(97, 8);
        
        self.noSelectTitlePoint = NSMakePoint(67, 26);
        self.noSelectLastSeenPoint = NSMakePoint(67, 8);
        self.noSelectAvatarPoint = NSMakePoint(23, (50 - 36) / 2);
        
        [self.title appendString:[object.user fullName] withColor:NSColorFromRGB(0x333333)];
        [self.lastSeen appendString:[object.user lastSeen] withColor:!isOnline ? NSColorFromRGB(0xaeaeae) : BLUE_UI_COLOR];
        
        [self.title setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
        [self.title setSelectionColor:NSColorFromRGB(0xfffffe) forColor:DARK_GREEN];
        
        [self.lastSeen setSelectionColor:NSColorFromRGB(0xfffffe) forColor:NSColorFromRGB(0xaeaeae)];
        [self.lastSeen setSelectionColor:NSColorFromRGB(0xffffff) forColor:LINK_COLOR];
        
    }
    return self;
}


-(id)copy {
    return [[SelectUserItem alloc] initWithObject:self.contact];
}

- (NSObject *)itemForHash {
    return self.contact;
}

+ (NSUInteger) hash:(TGContact *)object {
    return object.user_id;
}

@end
