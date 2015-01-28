//
//  AboutViewController.m
//  Telegram
//
//  Created by keepcoder on 15.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()
@end

@implementation AboutViewController

-(void)loadView {
    [super loadView];
    
    
     TMTextField* centerTextField = [TMTextField defaultTextField];
    [centerTextField setAlignment:NSCenterTextAlignment];
    [centerTextField setAutoresizingMask:NSViewWidthSizable];
    [centerTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:15]];
    [centerTextField setTextColor:NSColorFromRGB(0x222222)];
    [[centerTextField cell] setTruncatesLastVisibleLine:YES];
    [[centerTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [centerTextField setDrawsBackground:NO];
    
    [centerTextField setStringValue:NSLocalizedString(@"Account.About", nil)];
    
    TMView *centerView = [[TMView alloc] initWithFrame:NSZeroRect];
    
    
    self.centerNavigationBarView = centerView;
    
    [centerView addSubview:centerTextField];
    
    [centerTextField sizeToFit];
    
    [centerTextField setCenterByView:centerView];
    
    [centerTextField setFrameOrigin:NSMakePoint(centerTextField.frame.origin.x, 12)];
    
    
    
    
    self.view.isFlipped = YES;
    
    NSImageView *img = imageViewWithImage([NSImage imageNamed:@"logoAbout"]);
    
    [img setFrameSize:NSMakeSize(100, 100)];
    
    [img setCenterByView:self.view];
    
    [img setFrame:NSMakeRect(NSMinX(img.frame), 30, NSWidth(img.frame), NSHeight(img.frame))];
    
    TMTextField *telegram = [TMTextField defaultTextField];
    
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    [telegram setTextColor:NSColorFromRGB(0x999999)];
    [telegram setStringValue:[NSString stringWithFormat:@"Copyright © 2013 - %@ TELEGRAM MESSENGER",[formatter stringFromDate:[NSDate date]]]];
    
    [telegram sizeToFit];
    
    [telegram setCenterByView:self.view];
    
    [telegram setFrameOrigin:NSMakePoint(NSMinX(telegram.frame), NSHeight(self.view.frame) - 30 - NSHeight(telegram.frame))];
//
    
    TMTextField *description = [TMTextField defaultTextField];
    
    [description setStringValue:NSLocalizedString(@"Login.Description", nil)];
    
    [description sizeToFit];
    
    [description setCenterByView:self.view];
    
    [description setFrameOrigin:NSMakePoint(NSMinX(description.frame), NSMinY(img.frame) + 110)];
    
    
    TMTextField *version = [TMTextField defaultTextField];
    [version setStringValue:[NSString stringWithFormat:@"Version %@",API_VERSION]];
    [version setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
    [version setSelectable:YES];
    [version sizeToFit];
   
    [version setCenterByView:self.view];
    
    [version setFrameOrigin:NSMakePoint(NSMinX(version.frame), NSMinY(img.frame) + 130)];

    
    
    telegram.autoresizingMask = img.autoresizingMask  = description.autoresizingMask = version.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
    telegram.autoresizingMask|= NSViewMinYMargin;
    
    [self.view addSubview:version];
    [self.view addSubview:description];
    [self.view addSubview:telegram];
    [self.view addSubview:img];
    
}



@end
