//
//  NewConversationRow.m
//  Telegram P-Edition
//
//  Created by keepcoder on 20.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NewConversationRowItem.h"
#import "NS(Attributed)String+Geometrics.h"
#import "NSAttributedString+Hyperlink.h"

@interface NewConversationRowItem ()
@property (nonatomic, strong) TLContact * object;

@end

@implementation NewConversationRowItem

- (id)initWithObject:(TLContact *)object {
    if(self = [super initWithObject:object]) {
        self.object = object;
        self.animated = NO;
        self.action = NewConversationActionWrite;
        self.title = [[NSMutableAttributedString alloc] init];
        self.lastSeen = [[NSMutableAttributedString alloc] init];
        
        
        self.location = object.user.photo.photo_small;
        self.user = object.user;
        self.titleSize = NSZeroSize;
        self.lastSeenSize = NSMakeSize(200, 30);
        
        self.avatarPoint = NSMakePoint(15, (60 - 44) / 2);
        
        
        BOOL isOnline = self.user.isOnline;
        
        
        [self.title appendString:[object.user fullName] withColor:NSColorFromRGB(0x333333)];
        [self.lastSeen appendString:[object.user lastSeen] withColor:!isOnline ? NSColorFromRGB(0xaeaeae) : LINK_COLOR];
        
        [self.title setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
        [self.title setSelectionColor:NSColorFromRGB(0xfffffe) forColor:DARK_GREEN];
        
        [self.lastSeen setSelectionColor:NSColorFromRGB(0xfffffe) forColor:NSColorFromRGB(0xaeaeae)];
        [self.lastSeen setSelectionColor:NSColorFromRGB(0xffffff) forColor:LINK_COLOR];

    }
    return self;
}

-(BOOL)canSelect {
    return YES;
}

- (NSObject *)itemForHash {
    return self.object;
}

+ (NSUInteger) hash:(TLContact *)object {
    return [ @(object.user.n_id) hash];
}

@end
