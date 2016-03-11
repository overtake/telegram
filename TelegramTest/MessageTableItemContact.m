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
@implementation MessageTableItemContact

- (id) initWithObject:(TLMessage *)object  {
    self = [super initWithObject:object];
    if(self) {
        
        TL_messageMediaContact *contact = (TL_messageMediaContact * )object.media;
        
        _fullName = [[[[NSString stringWithFormat:@"%@%@%@", contact.first_name,contact.first_name.length > 0 ? @" " : @"", contact.last_name] trim] htmlentities] singleLine];
        
        
        if(contact.user_id) {
            self.contactUser = [[UsersManager sharedManager] find:contact.user_id];
        }


        if(self.contactUser) {
            self.user_id = contact.user_id;
        } else {
            self.contactText =  [NSString stringWithFormat:@"%C%C", (unichar)(contact.first_name.length ? [contact.first_name characterAtIndex:0] : 0), (unichar)(contact.last_name.length ? [contact.last_name characterAtIndex:0] : 0)];
        }
        
        [self doAfterDownload];
       
        
        self.blockSize = NSMakeSize(300, 50);
    }
    return self;
}

-(void)doAfterDownload {
    NSString *phoneNumber = self.message.media.phone_number.length ? [RMPhoneFormat formatPhoneNumber:self.message.media.phone_number] : NSLocalizedString(@"User.Hidden", nil);
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    
    NSRange range = [attributedText appendString:_fullName withColor:_contactUser ? LINK_COLOR : TEXT_COLOR];
    [attributedText setFont:TGSystemMediumFont(13) forRange:attributedText.range];
    
    if(_contactUser)
        [attributedText setLink:[TMInAppLinks peerProfile:[TL_peerUser createWithUser_id:self.message.media.user_id]] forRange:range];
    
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
    return [super makeSizeByWidth:width];
}


-(Class)viewClass {
    return [MessageTableCellContactView class];
}

@end
