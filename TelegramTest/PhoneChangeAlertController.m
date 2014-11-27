//
//  PhoneChangeAlertController.m
//  Telegram
//
//  Created by keepcoder on 25.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhoneChangeAlertController.h"

@interface PhoneChangeAlertController ()
@property (nonatomic,strong) TMTextField *centerTextField;
@end

@implementation PhoneChangeAlertController


-(void)loadView {
    [super loadView];
    
    self.view.isFlipped = YES;
    
    self.centerTextField = [TMTextField defaultTextField];
    [self.centerTextField setAlignment:NSCenterTextAlignment];
    [self.centerTextField setAutoresizingMask:NSViewWidthSizable];
    [self.centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    [self.centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[self.centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[self.centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.centerTextField setDrawsBackground:NO];
    
    [self.centerTextField setStringValue:NSLocalizedString(@"PhoneChangeAlertController.Header", nil)];
    
    [self.centerTextField setFrameOrigin:NSMakePoint(self.centerTextField.frame.origin.x, -12)];
    
    self.centerNavigationBarView = (TMView *) self.centerTextField;
    
    TMTextButton *doneButton = [TMTextButton standartUserProfileNavigationButtonWithTitle:NSLocalizedString(@"PhoneChangeAlertController.ChangePhone", nil)];
    
    
    [doneButton setTapBlock:^{
        [[Telegram rightViewController] showPhoneChangeController];
    }];
    

    
    [self setRightNavigationBarView:(TMView *)doneButton animated:NO];
    
    
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    NSString *textFormat = NSLocalizedString(@"PhoneChangeAlertController.Description", nil);
    
    [attr appendString:[NSString stringWithFormat:textFormat,@"",@""] withColor:NSColorFromRGB(0x999999)];
    
    [attr setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:attr.range];
    
    NSRange startRange = [textFormat rangeOfString:@"%1$@"];
    NSRange endRange = [textFormat rangeOfString:@"%2$@"];
    
    NSUInteger length = endRange.location - startRange.location;
    
    [attr addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13] range:NSMakeRange(startRange.location, length-4)];
    
    
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
    
    
    descriptionTextField.hardYOffset = 30;
    
    
    [descriptionTextField setCenterByView:self.view];
    
    [self.view addSubview:descriptionTextField];
    
    NSImageView *imageView = imageViewWithImage(image_ChangenumberAlertIcon());
    
    [imageView setFrameOrigin:NSMakePoint(roundf((NSWidth(self.view.frame) - NSWidth(imageView.frame)) /2), 30)];
    
    imageView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
    [self.view addSubview:imageView];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.centerTextField setStringValue:[UsersManager currentUser].phoneWithFormat];
    
}

@end
