//
//  MessageTableItemText.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemText.h"
#import "TMElements.h"
#import "NS(Attributed)String+Geometrics.h"
#import "MessagesUtils.h"
#import "NSAttributedString+Hyperlink.h"
#import "NSString+Extended.h"

#define MAX_WIDTH 400

@interface MessageTableItemText()
@property (nonatomic, strong) NSMutableAttributedString *nameAttritutedString;
@property (nonatomic, strong) NSMutableAttributedString *forwardAttributedString;
@end

@implementation MessageTableItemText

- (id) initWithObject:(TGMessage *)object {
    self = [super initWithObject:object];
    
    self.textAttributed = [[NSMutableAttributedString alloc] init];
    
    NSString *message = [object.message trim];
    
    
    NSRange range = [self.textAttributed appendString:message withColor:NSColorFromRGB(0x060606)];
    [self.textAttributed setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:range];
    [self.textAttributed detectAndAddLinks];
    
    
    
    
    
    
 //   [self.textAttributed addAttribute:NSBackgroundColorAttributeName value:NSColorFromRGB(0xcfcfcf) range:self.textAttributed.range];
    
  //  [self.textAttributed addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:self.textAttributed.range];
    
    
    NSString *fullname = self.user.fullName;
    
//    self.headerAttributed = [[NSMutableAttributedString alloc] init];
    
    self.nameAttritutedString = [[NSMutableAttributedString alloc] init];
    NSRange rangeHeader =  [self.nameAttritutedString appendString:fullname ? fullname : NSLocalizedString(@"User.Deleted", nil) withColor:[MessagesUtils colorForUserId:self.message.from_id]];
    
    
    [self.nameAttritutedString setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:11] forRange:rangeHeader];
    
//    NSMutableParagraphStyle *paragraphStyle =
    CGFloat spacing = 14;
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
//    [para setLineSpacing:spacing];
    [para setMinimumLineHeight:spacing];
    [para setMaximumLineHeight:spacing];
    [self.nameAttritutedString addAttribute:NSParagraphStyleAttributeName value:para range:rangeHeader];

//    NSLog(@"[TMInAppLinks userProfile:self.user.n_id] %@", [TMInAppLinks userProfile:self.user.n_id]);
    
//    NSURL *url = [NSURL URLWithString:];
    
//    NSString *string = [ copy];
    
    
    [self.nameAttritutedString setLink:[TMInAppLinks userProfile:self.user.n_id] withColor:[MessagesUtils colorForUserId:self.message.from_id] forRange:rangeHeader];
    
    
    if([object isKindOfClass:[TL_messageForwarded class]] || [object isKindOfClass:[TL_localMessageForwarded class]] ) {
        self.forwardAttributedString = [[NSMutableAttributedString alloc] init];
        NSRange range1 = [self.forwardAttributedString appendString:@"Message.ForwardedFrom" withColor:NSColorFromRGB(0x6da2cb)];
        TGUser *user = [[UsersManager sharedManager] find:object.fwd_from_id];
        NSRange range2 = [self.forwardAttributedString appendString:user.fullName withColor:NSColorFromRGB(0x57a4e1)];
        
        [self.forwardAttributedString setLink:[TMInAppLinks userProfile:user.n_id] forRange:range2];
        
        NSDate *fwd_date = [NSDate dateWithTimeIntervalSince1970:object.fwd_date];
        [[MessageTableItem dateFormatter] setDateFormat:@"HH:mm"];
        
        NSRange range3 = [self.forwardAttributedString appendString:[NSString stringWithFormat:@", %@", [[MessageTableItem dateFormatter] stringFromDate:fwd_date]] withColor:NSColorFromRGB(0x6da2cb)];

        NSRange rangeFinal = NSMakeRange(range1.location, range1.length + range2.length + range3.length);
        [self.forwardAttributedString setFont:[NSFont fontWithName:@"Helvetica" size:11.5] forRange:rangeFinal];
        
        //User
        [self.forwardAttributedString setFont:[NSFont fontWithName:@"Helvetica-Bold" size:11.5] forRange:range2];
    }
    
    
    [self makeSizeByWidth:300];
    
    return self;
}

- (BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    width -= self.dateSize.width;
    
    if(self.isForwadedMessage) {
        width -= 50;
    }
    
    float oldWidth = self.blockSize.width;
    
    
    static NSMutableParagraphStyle *paragraphStyle = nil;
    if(!paragraphStyle) {
        paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:0.7];
        [paragraphStyle setMinimumLineHeight:18];
        [paragraphStyle setMaximumLineHeight:19];
        
    }
    
    NSMutableAttributedString *copy = [self.textAttributed mutableCopy];
    
    [copy addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:copy.range];
    
    
    NSSize textSize = [copy sizeForWidth:width height:FLT_MAX];
    textSize.width = ceil(textSize.width);
    textSize.height = ceil(textSize.height);
    
    NSSize roundSize = [copy sizeForWidth:width+5 height:FLT_MAX];
    
    if(roundSize.height < textSize.height)
        textSize = roundSize;
    
    if(textSize.width == oldWidth)
        return NO;
        
    self.blockSize = textSize;
    return YES;
}

@end
