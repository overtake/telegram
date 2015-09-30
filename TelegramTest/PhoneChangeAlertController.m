//
//  PhoneChangeAlertController.m
//  Telegram
//
//  Created by keepcoder on 25.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhoneChangeAlertController.h"

@interface PhoneChangeAlertController ()
@end

@implementation PhoneChangeAlertController


-(void)loadView {
    [super loadView];
    
    self.view.isFlipped = YES;
    
    [self setCenterBarViewText:NSLocalizedString(@"PhoneChangeAlertController.Header", nil)];
    
    TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"PhoneChangeAlertController.ChangePhone", nil)];
    
    
    [doneButton setTapBlock:^{
        [[Telegram rightViewController] showPhoneChangeController];
    }];
    

    
    [self setRightNavigationBarView:(TMView *)doneButton animated:NO];
    
    
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    NSString *textFormat = NSLocalizedString(@"PhoneChangeAlertController.Description", nil);
    
    [attr appendString:[NSString stringWithFormat:textFormat,@"",@"",@"",@""] withColor:GRAY_TEXT_COLOR];
    
    [attr setFont:TGSystemFont(13) forRange:attr.range];
    
    NSRange startRange = [textFormat rangeOfString:@"%1$@"];
    NSRange endRange = [textFormat rangeOfString:@"%2$@"];
    
    NSUInteger length = endRange.location - startRange.location;
    
    
    
    [attr addAttribute:NSFontAttributeName value:TGSystemMediumFont(13) range:NSMakeRange(startRange.location, length-4)];
    
    
    startRange = [textFormat rangeOfString:@"%3$@"];
    endRange = [textFormat rangeOfString:@"%4$@"];
    
    length = endRange.location - startRange.location;
    
    [attr addAttribute:NSFontAttributeName value:TGSystemMediumFont(13) range:NSMakeRange(startRange.location - 8, length-4)];
    
//   
//    
//    [attr appendString:@"\n\n"];
//    
//    NSRange range = [attr appendString:NSLocalizedString(@"PhoneChangeAlertController.ChangePhone", nil) withColor:BLUE_UI_COLOR];
//    
//    [attr addAttribute:NSLinkAttributeName value:@"change" range:range];
    
     [attr setAlignment:NSCenterTextAlignment range:attr.range];
    
    
    TMHyperlinkTextField * descriptionTextField = [TMHyperlinkTextField defaultTextField];
    [descriptionTextField setAlignment:NSCenterTextAlignment];
    [descriptionTextField setAutoresizingMask:NSViewWidthSizable];
    
    [descriptionTextField setAttributedStringValue:attr];
    
    [descriptionTextField setFrameSize:NSMakeSize(NSWidth(self.view.frame) - 200, NSHeight(self.view.frame) - 270)];
    

    
    [descriptionTextField setCenterByView:self.view];
    
    [self.view addSubview:descriptionTextField];
    
    NSImageView *imageView = imageViewWithImage(image_ChangenumberAlertIcon());
    
    [imageView setFrameOrigin:NSMakePoint(roundf((NSWidth(self.view.frame) - NSWidth(imageView.frame)) /2), 40)];
    
    imageView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
    [self.view addSubview:imageView];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setCenterBarViewText:[UsersManager currentUser].phoneWithFormat];
    
}

@end
