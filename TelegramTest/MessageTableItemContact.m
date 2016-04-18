//
//  MessageTableItemContact.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemContact.h"
#import "NSString+Extended.h"
#import "ImageUtils.h"
#import "RMPhoneFormat.h"
#import "NS(Attributed)String+Geometrics.h"
#import "MessageTableCellContactView.h"

@interface MessageTableItemContact ()
@property (nonatomic,strong) TL_messageMediaContact *contact;
@end

@implementation MessageTableItemContact

- (id) initWithObject:(TLMessage *)object  {
    self = [super initWithObject:object];
    if(self) {
        
        [self doAfterDownload];
        
        
    }
    return self;
}



-(void)doAfterDownload {
    
    
    _contact = [self.message.media isKindOfClass:[TL_messageMediaContact class]] ? (TL_messageMediaContact *) self.message.media : [TL_messageMediaContact createWithPhone_number:self.message.media.bot_result.send_message.phone_number first_name:self.message.media.bot_result.send_message.first_name last_name:self.message.media.bot_result.send_message.last_name user_id:0];
    
    _fullName = [[[[NSString stringWithFormat:@"%@%@%@", self.contact.first_name,self.contact.first_name.length > 0 ? @" " : @"", self.contact.last_name] trim] htmlentities] singleLine];
    
    
    if(self.contact.user_id) {
        self.contactUser = [[UsersManager sharedManager] find:self.contact.user_id];
    }
    
    
    if(self.contactUser) {
        self.user_id = self.contact.user_id;
    } else {
        self.contactText =  [NSString stringWithFormat:@"%C%C", (unichar)(self.contact.first_name.length ? [self.contact.first_name characterAtIndex:0] : 0), (unichar)(self.contact.last_name.length ? [self.contact.last_name characterAtIndex:0] : 0)];
    }
    
    
    
    NSString *phoneNumber = self.contact.phone_number.length ? [RMPhoneFormat formatPhoneNumber:self.contact.phone_number] : NSLocalizedString(@"User.Hidden", nil);
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    
    NSRange range = [attributedText appendString:_fullName withColor:_contactUser ? LINK_COLOR : TEXT_COLOR];
    [attributedText setFont:TGSystemMediumFont(13) forRange:attributedText.range];
    
    if(_contactUser)
        [attributedText setLink:[TMInAppLinks peerProfile:[TL_peerUser createWithUser_id:self.contact.user_id]] forRange:range];
    
    [attributedText appendString:@"\n"];
    
    range = [attributedText appendString:phoneNumber withColor:TEXT_COLOR];
    [attributedText setFont:TGSystemFont(13) forRange:range];
    
    
    if(_contactUser.type == TLUserTypeForeign || _contactUser.type == TLUserTypeRequest) {
        [attributedText appendString:@"\n"];
        range = [attributedText appendString:NSLocalizedString(@"AddContact.AddContact", nil) withColor:LINK_COLOR];
        [attributedText setFont:TGSystemFont(13) forRange:range];
        [attributedText setLink:@"chat://addcontact" forRange:range];
    }
    
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.lineSpacing = 2;
    
    [attributedText addAttribute:NSParagraphStyleAttributeName value:style range:attributedText.range];
    
    _attributedText = attributedText;
    
    [self makeSizeByWidth:self.makeSize];
}

-(BOOL)makeSizeByWidth:(int)width {
    _textSize = [_attributedText coreTextSizeForTextFieldForWidth:width - 50 - self.defaultOffset];
    
    self.contentSize = self.blockSize = NSMakeSize(MIN(300,_textSize.width + 50 + self.defaultOffset), 50);
    
    return [super makeSizeByWidth:width];
}


-(Class)viewClass {
    return [MessageTableCellContactView class];
}

@end
