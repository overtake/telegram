//
//  EncryptedKeyViewController.m
//  Telegram
//
//  Created by keepcoder on 25.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "EncryptedKeyViewController.h"
#import "Crypto.h"
#import "NS(Attributed)String+Geometrics.h"
@interface EncryptedKeyViewController ()<TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) NSImageView *imageView;
@property (nonatomic,strong) TMHyperlinkTextField *textField;
@end

@implementation EncryptedKeyViewController


-(void)loadView {
    [super loadView];
    
    
    
    TMButton *center = [[TMButton alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)];
    [center setTextFont:TGSystemFont(14)];
    [center setText:NSLocalizedString(@"EncryptionKey.EncryptionKey", nil)];
    [center setTarget:self selector:@selector(navigationGoBack)];
    self.centerNavigationBarView = center;
    center.acceptCursor = NO;

    
    
    
    
    self.view.isFlipped = YES;
    
    
    TMView *container = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 464)];
    
    
    self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0, 200, 200)];
    [container addSubview:self.imageView];
    
   
    [self.imageView setCenterByView:container];
    
    [self.imageView setFrameOrigin:NSMakePoint(NSMinX(self.imageView.frame), NSHeight(container.frame) - 200)];
    
    self.textField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 264)];
    
    
    [self.textField setFrameOrigin:NSMakePoint(NSMinX(self.textField.frame), NSHeight(container.frame) - NSHeight(self.imageView.frame) - 291)];
    
    [self.textField setAlignment:NSCenterTextAlignment];
    
    self.textField.url_delegate = self;
    
    [self.textField setFont:TGSystemFont(14)];
    
    [self.textField setEditable:NO];
    [self.textField setSelectable:NO];
    [self.textField setBordered:NO];
    self.textField.hardYOffset = 25.0f;
 
    [container addSubview:self.textField];
    
    [self.view addSubview:container];
    
    
    [container setCenterByView:self.view];
    
    [container setFrameOrigin:NSMakePoint(NSMinX(container.frame), 32)];
    
    container.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;


}

- (void)showForChat:(TL_encryptedChat *)chat {
    
    [self view];
    
    EncryptedParams *params = [EncryptedParams findAndCreate:chat.n_id];
    
    NSData *hashData = [Crypto sha1:[params firstKey]];
    
    
    
    self.imageView.image = TGIdenticonImage(hashData, CGSizeMake(200, 200));
    
    
    NSString *_userName = chat.peerUser.first_name;
    
    NSString *textFormat = NSLocalizedString(@"EncryptionKey.Description", nil);
    
    NSString *baseText = [[NSString alloc] initWithFormat:textFormat, _userName, _userName];
    
    
     NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:TGSystemFont(14), NSFontAttributeName, nil];
    
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:TGSystemMediumFont(14), NSFontAttributeName, nil];
    
    NSDictionary *linkAtts = @{NSForegroundColorAttributeName: BLUE_UI_COLOR, NSLinkAttributeName:@"telegram.org"};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:baseText attributes:attrs];
    
    [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%1$@"].location, _userName.length)];
    
    [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%2$@"].location + (_userName.length - @"%1$@".length), _userName.length)];
    
    [attributedText setAttributes:linkAtts range:[baseText rangeOfString:@"telegram.org"]];
    
    [attributedText setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attributedText.length)];
    
    
    
    [self.textField setAttributedStringValue:attributedText];
    
    
    NSSize size = [attributedText sizeForWidth:self.textField.frame.size.width height:FLT_MAX];
    
    NSRect frame = self.textField.frame;
    
    frame.size.height = size.height+40;
    
   // frame.origin.y = roundf((self.view.frame.size.height-frame.size.height)/2);
    
   // self.textField.frame = frame;
    
    
}

- (void) textField:(id)textField handleURLClick:(NSString *)url {
    open_link(url);
}


@end
