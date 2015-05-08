//
//  TGS_ConversationTableItem.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGS_ConversationRowItem.h"
#import "NSAttributedStringCategory.h"
#import "TMAttributedString.h"
@implementation TGS_ConversationRowItem

-(id)initWithConversation:(TLDialog *)conversation user:(TLUser *)user {
    if(self = [super init]) {
        _conversation = conversation;
        _user = user;
        
        
        [self configure];
    }
    
    return self;
}

-(id)initWithConversation:(TLDialog *)conversation chat:(TLChat *)chat {
    if(self = [super init]) {
        _conversation = conversation;
        _chat = chat;
        
        [self configure];
    }
    
    return self;
}

-(void)configure {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:_user ? [NSString stringWithFormat:@"%@ %@",_user.first_name, _user.last_name] : _chat.title withColor:NSColorFromRGB(0x000000)];
    
    [attr setFont:TGSystemFont(15) forRange:attr.range];
    
    _name = attr;
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineBreakMode = NSLineBreakByTruncatingTail;

    [attr addAttribute:NSParagraphStyleAttributeName value:style range:attr.range];
    
    _imageObject = [[TGSImageObject alloc] initWithLocation:_chat ? _chat.photo.photo_small : _user.photo.photo_small placeHolder:nil sourceId:_chat ? _chat.n_id : _user.n_id];
    
    _imageObject.imageSize = NSMakeSize(40, 40);
    
    _imageObject.object = _user ? _user : _chat;
}


-(NSUInteger)hash {
    return _user ? _user.n_id : _chat.n_id;
}

@end
