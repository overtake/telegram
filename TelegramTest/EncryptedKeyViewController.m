//
//  EncryptedKeyViewController.m
//  Telegram
//
//  Created by keepcoder on 25.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "EncryptedKeyViewController.h"
#import "Crypto.h"
#import <MTProtoKit/MTEncryption.h>
#import "NS(Attributed)String+Geometrics.h"
#import "NSData+Extensions.h"
@interface EncryptedKeyViewController ()<TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) NSImageView *imageView;
@property (nonatomic,strong) TMHyperlinkTextField *textField;
@property (nonatomic,strong) TMView *imageBorder;
@end

@implementation EncryptedKeyViewController


-(void)loadView {
    [super loadView];
    
    
    _imageBorder = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 164, 164)];
    
    _imageBorder.wantsLayer = YES;
    _imageBorder.layer.borderColor = [NSColor redColor].CGColor;
    _imageBorder.layer.borderWidth = 5;
    
    TMButton *center = [[TMButton alloc] initWithFrame:NSMakeRect(0, 0, 400, 200)];
    [center setTextFont:TGSystemFont(14)];
    [center setText:NSLocalizedString(@"EncryptionKey.EncryptionKey", nil)];
    [center setTarget:self selector:@selector(navigationGoBack)];
    self.centerNavigationBarView = center;
    center.acceptCursor = NO;

    
    
    self.view.isFlipped = YES;
    
    
    TMView *container = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 300, 464)];
    
    
    self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0,0, 240, 240)];
    [container addSubview:self.imageView];
    
    
    
   
    [self.imageView setCenterByView:container];
    
    
    
    [self.imageView setFrameOrigin:NSMakePoint(NSMinX(self.imageView.frame), NSHeight(container.frame) - 240)];
    
    [_imageBorder setFrameOrigin:NSMakePoint(NSMinX(_imageView.frame) + 38, NSMinY(_imageView.frame) + 38)];
    
    
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
    
    [container addSubview:_imageBorder];
    
    [self.view addSubview:container];
    
    
    [container setCenterByView:self.view];
    
    [container setFrameOrigin:NSMakePoint(NSMinX(container.frame), 32)];
    
    container.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;


}

/*
 в центре остается то, что было раньше, вокруг используются первые 20 байт из sha256(auth_key)
 ниже в hex у меня выводится вот так: sha1(0, 16) + sha256(0, 16)
 */

- (void)showForChat:(TL_encryptedChat *)chat {
    
    [self view];
    
    EncryptedParams *params = [EncryptedParams findAndCreate:chat.n_id];
    
    NSData *keyData = [[MTSha1(params.firstKey) subdataWithRange:NSMakeRange(0, 16)] dataWithData:[MTSha256(params.lastKey) subdataWithRange:NSMakeRange(0, 20)]];
    
    self.imageView.image = TGIdenticonImage(keyData, CGSizeMake(240, 240));
    
    
    NSString *hash = [[keyData subdataWithRange:NSMakeRange(0, keyData.length - 4)] hexadecimalString];
    
    
    
     NSString *_userName = chat.peerUser.first_name;
    
    NSString *textFormat = NSLocalizedString(@"EncryptionKey.Description", nil);
    
    NSString *baseText = [[NSString alloc] initWithFormat:textFormat, _userName, _userName];
    
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:TGSystemFont(14), NSFontAttributeName, nil];
    
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:TGSystemMediumFont(14), NSFontAttributeName, nil];
    
    NSDictionary *linkAtts = @{NSForegroundColorAttributeName: BLUE_UI_COLOR, NSLinkAttributeName:@"telegram.org"};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    
    
    NSRange range = [attributedText appendString:hash];
    
    [attributedText setCTFont:[NSFont fontWithName:@"Courier" size:14] forRange:range];
    [attributedText appendString:@"\n\n"];
    
    range = [attributedText appendString:baseText];
    
    [attributedText setAttributes:attrs range:range];
    
    [attributedText setAttributes:subAttrs range:NSMakeRange(hash.length + 2 + [textFormat rangeOfString:@"%1$@"].location, _userName.length)];
    
    [attributedText setAttributes:subAttrs range:NSMakeRange(hash.length + 2 + [textFormat rangeOfString:@"%2$@"].location + (_userName.length - @"%1$@".length), _userName.length)];
    
    [attributedText setAttributes:linkAtts range:NSMakeRange(hash.length + 2 + [baseText rangeOfString:@"telegram.org"].location, 12) ];
    
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
