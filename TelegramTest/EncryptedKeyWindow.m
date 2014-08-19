//
//  EncryptedKeyWindow.m
//  Messenger for Telegram
//
//  Created by keepcoder on 08.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "EncryptedKeyWindow.h"
#import "ImageUtils.h"
#import "Crypto.h"
#import "NS(Attributed)String+Geometrics.h"
@interface EncryptedKeyWindow ()
@property (nonatomic,strong) NSImageView *imageView;
@property (nonatomic,strong) TMHyperlinkTextField *textField;
@end

@implementation EncryptedKeyWindow

-(id)init {
    if(self = [super initWithContentRect:NSMakeRect(400, 400, 700, 330)
                               styleMask:NSClosableWindowMask|NSTitledWindowMask
                                 backing:NSBackingStoreBuffered
                                   defer:YES]) {
        
        TMView *bg = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
        [bg setBackgroundColor:NSColorFromRGB(0xffffff)];
        [self.contentView addSubview:bg];
        
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(roundf((self.frame.size.height-264)/2), roundf((self.frame.size.height-264)/2), 264, 264)];
        [self.contentView addSubview:self.imageView];
        
        self.textField = [[TMHyperlinkTextField alloc] initWithFrame:NSMakeRect(self.imageView.frame.size.width+self.imageView.frame.origin.x + 40, self.imageView.frame.origin.y, 300, 264)];
        
       [self.textField setAlignment:NSCenterTextAlignment];
        
        self.textField.url_delegate = self;
        
        [self.textField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        
        [self.textField setEditable:NO];
        [self.textField setSelectable:NO];
        [self.textField setBordered:NO];
        self.textField.hardYOffset = 25.0f;
        [self.contentView addSubview:self.textField];
        
       
        self.title = NSLocalizedString(@"EncryptionKey.EncryptionKey", nil);
    }
    
    return self;
}

+ (void)showForChat:(TL_encryptedChat *)chat {
    EncryptedKeyWindow *window = [self sharedManager];
    
    
    EncryptedParams *params = [EncryptedParams findAndCreate:chat.n_id];
    
    NSData *hashData = [Crypto sha1:params.encrypt_key];
    
    
    
    window.imageView.image = TGIdenticonImage(hashData, CGSizeMake(264, 264));

    
    NSString *_userName = chat.peerUser.first_name;
    
    NSString *textFormat = NSLocalizedString(@"EncryptionKey.Description", nil);
    
    NSString *baseText = [[NSString alloc] initWithFormat:textFormat, _userName, _userName];
    
    
    
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"HelveticaNeue" size:14], NSFontAttributeName, nil];
    
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"HelveticaNeue-Medium" size:14], NSFontAttributeName, nil];
    
    NSDictionary *linkAtts = @{NSForegroundColorAttributeName: BLUE_UI_COLOR, NSLinkAttributeName:@"telegram.org"};
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:baseText attributes:attrs];
    
    [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%1$@"].location, _userName.length)];
    
    [attributedText setAttributes:subAttrs range:NSMakeRange([textFormat rangeOfString:@"%2$@"].location + (_userName.length - @"%1$@".length), _userName.length)];
    
    [attributedText setAttributes:linkAtts range:[baseText rangeOfString:@"telegram.org"]];
    
    [attributedText setAlignment:NSCenterTextAlignment range:NSMakeRange(0, attributedText.length)];
    
   
    
    [window.textField setAttributedStringValue:attributedText];
   
    
    NSSize size = [attributedText sizeForWidth:window.textField.frame.size.width height:FLT_MAX];
    
    NSRect frame = window.textField.frame;
    
    frame.size.height = size.height+40;
    
    frame.origin.y = roundf((window.frame.size.height-frame.size.height)/2);
    
    window.textField.frame = frame;
    
    
    
    [window makeKeyAndOrderFront:nil];
    
}

- (void) textField:(id)textField handleURLClick:(NSString *)url {
    open_link(url);
}


+(EncryptedKeyWindow *)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[[self class] alloc] init];
    });
    return instance;
}

@end
