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
#import "TGS_MTNetwork.h"
#import "TGDateUtils.h"



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
    
    
    if(!_user.first_name)
        _user.first_name = @"";
    
    if(!_user.last_name)
        _user.last_name = @"";
    
    [attr appendString:_user ? [NSString stringWithFormat:@"%@ %@",_user.first_name, _user.last_name] : _chat.title withColor:NSColorFromRGB(0x000000)];
    
    
    [attr setFont:TGSystemFont(15) forRange:attr.range];
    
    [attr appendString:@"\n"];
    
    NSString *lastSeen = [self lastSeen];
    
    NSRange range = [attr appendString:lastSeen withColor:[lastSeen isEqualToString:@"online"] ? LINK_COLOR : GRAY_TEXT_COLOR];
    
    [attr setFont:TGSystemFont(13) forRange:range];
    
    _name = attr;
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineBreakMode = NSLineBreakByTruncatingTail;

    [attr addAttribute:NSParagraphStyleAttributeName value:style range:attr.range];
    
    _imageObject = [[TGSImageObject alloc] initWithLocation:_chat ? _chat.photo.photo_small : _user.photo.photo_small placeHolder:nil sourceId:_chat ? _chat.n_id : _user.n_id];
    
    _imageObject.imageSize = NSMakeSize(40, 40);
    
    _imageObject.object = _user ? _user : _chat;
}


- (NSString *)lastSeen {
    
    if(_chat)
    {
        return [NSString stringWithFormat:NSLocalizedString(_chat.participants_count > 1 ? @"Group.membersCount" : @"Group.memberCount", nil),_chat.participants_count];
    }
    
    if(_user.n_id == 777000) {
        return NSLocalizedString(@"Service notifications", nil);
    }
    
    int lastSeenTime = [_user.status isKindOfClass:[TL_userStatusEmpty class]] ? - 1 : (_user.status.expires ? _user.status.expires : _user.status.was_online);
    
    if([[TGS_MTNetwork instance] getTime] < lastSeenTime)
        return NSLocalizedString(@"Account.Online", nil);
    
    int time = lastSeenTime;
    if(time == -1)
        return  NSLocalizedString(@"LastSeen.longTimeAgo", nil);
    
    if(time == 0) {
        
        if(_user.status.class == [TL_userStatusRecently class]) {
            return NSLocalizedString(@"LastSeen.Recently", nil);
        }
        if(_user.status.class == [TL_userStatusLastWeek class]) {
            return NSLocalizedString(@"LastSeen.Weekly", nil);
        }
        if(_user.status.class == [TL_userStatusLastMonth class]) {
            return NSLocalizedString(@"LastSeen.Monthly", nil);
        }
        
        return  NSLocalizedString(@"LastSeen.longTimeAgo", nil);
    }
    
    
    time -= [[TGS_MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    return  [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Time.last_seen", nil), [TGDateUtils stringForRelativeLastSeen:time]];
}

-(NSUInteger)hash {
    return _user ? _user.n_id : _chat.n_id;
}

@end
