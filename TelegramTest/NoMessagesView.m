//
//  NoMessagesView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 15.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NoMessagesView.h"

@interface NoMessagesView ()
@property (nonatomic,strong) NSProgressIndicator *progress;
@property (nonatomic,strong) TMTextField *field;
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) NSAttributedString *secret;
@end

@implementation NoMessagesView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:NSColorFromRGB(0xffffff)];
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
        
        _field = [[TMTextField alloc] initWithFrame:NSMakeRect(0, roundf(self.frame.size.height / 2 - 12.5), self.bounds.size.width, 25)];
        [_field setAlignment:NSCenterTextAlignment];
        [_field setEditable:NO];
        [_field setBordered:NO];
        [_field setSelectable:NO];
        [_field setDrawsBackground:NO];
        [_field setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        [_field setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        [_field setTextColor:NSColorFromRGB(0x9b9b9b)];
        [_field setStringValue:NSLocalizedString(@"Conversation.NoMessages", nil)];
        
       // [self.field setBackgroundColor:NSColorFromRGB(0xf43d2)];
        
        [self addSubview:_field];
        
        
        self.progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(roundf(self.frame.size.width / 2 - 12.5), roundf(self.frame.size.height / 2 - 12.5), 25, 25)];
        
        [self.progress setStyle:NSProgressIndicatorSpinningStyle];
        
        [self addSubview:self.progress];
        
        self.secret = [self buildSecretString];
        
        
        [_field setAttributedStringValue:self.secret];
        
        
       

    }
    return self;
}

-(void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [self.progress setCenterByView:self];
}


- (NSAttributedString *)buildSecretString {
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    
    [paragraphStyle setParagraphSpacing:11];
    
    NSMutableParagraphStyle *subParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    [subParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [subParagraphStyle setAlignment:NSLeftTextAlignment];
    [subParagraphStyle setParagraphSpacing:4];
    
    NSMutableParagraphStyle *subParagraphStyle2 = [[NSMutableParagraphStyle alloc] init];
    [subParagraphStyle2 setLineBreakMode:NSLineBreakByTruncatingTail];
    [subParagraphStyle2 setAlignment:NSCenterTextAlignment];
    [subParagraphStyle2 setParagraphSpacing:3];
  
    
    TLEncryptedChat *chat = self.conversation.encryptedChat;
    
    
    NSString *descFormat = chat.admin_id == [UsersManager currentUserId] ?  NSLocalizedString(@"Secret.join.description", nil) :  NSLocalizedString(@"Secret.join.invitedDescription", nil);
    
    
    [string appendString:[NSString stringWithFormat:descFormat,chat.peerUser.first_name] withColor:NSColorFromRGB(0x9b9b9b)];
    
    [string setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:NSMakeRange(0, string.length)];
    
    [string addAttribute:NSParagraphStyleAttributeName value:subParagraphStyle2 range:NSMakeRange(0, string.length)];
    
    
    [string setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13] forRange:NSMakeRange([descFormat rangeOfString:@"%1$@"].location, self.conversation.encryptedChat.peerUser.first_name.length)];
    

    NSRange range = [string appendString:NSLocalizedString(@"Secret.join.secret_chats",nil) withColor:NSColorFromRGB(0x9b9b9b)];
    
    [string setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:range];
    
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    
    NSMutableAttributedString *subString = [[NSMutableAttributedString alloc] init];
    
    
    NSAttributedString *secretImageAttributedString = [NSAttributedString attributedStringWithAttachment:secretImage()];
    
    [subString appendAttributedString:secretImageAttributedString];
    
    [subString appendString:NSLocalizedString(@"Secret.join.desc1", nil) withColor:NSColorFromRGB(0x9b9b9b)];
    
    [subString appendAttributedString:secretImageAttributedString];
    
    [subString appendString:NSLocalizedString(@"Secret.join.desc2", nil) withColor:NSColorFromRGB(0x9b9b9b)];
    
    [subString appendAttributedString:secretImageAttributedString];
    
    [subString appendString:NSLocalizedString(@"Secret.join.desc3", nil) withColor:NSColorFromRGB(0x9b9b9b)];
    
    [subString appendAttributedString:secretImageAttributedString];
    
    [subString appendString:NSLocalizedString(@"Secret.join.desc4", nil) withColor:NSColorFromRGB(0x9b9b9b)];

    [subString setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:NSMakeRange(0, subString.length)];
    
    [subString addAttribute:NSParagraphStyleAttributeName value:subParagraphStyle range:NSMakeRange(0, subString.length)];
    
    
    [string appendAttributedString:subString];
    
    return string;
    
}


-(void)setConversation:(TL_conversation *)conversation {
    _conversation = conversation;
    // && conversation.top_message == -1
    if(conversation.type == DialogTypeSecretChat) {
        
        self.secret = [self buildSecretString];
        
        [self.field setAttributedStringValue:self.secret];
        
        
        
    } else {
        [self.field setStringValue:NSLocalizedString(@"Conversation.NoMessages", nil)];
    }
    


    
    [self.field sizeToFit];
    
    [self.field setFrameSize:NSMakeSize(230, self.field.frame.size.height)];
    [self.field setCenterByView:self];
}


-(void)setHidden:(BOOL)flag {
    if(self.conversation)
        [self setConversation:self.conversation];
   
    [super setHidden:flag];
}

static NSTextAttachment *secretImage() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_secretGray() imageWithInsets:NSEdgeInsetsMake(0, 0, 0, 4)]];
    });
    return instance;
}

-(void)setLoading:(BOOL)isLoading {
    [self.progress setHidden:!isLoading || self.conversation.type == DialogTypeSecretChat];
    [self.field setHidden:isLoading];
    if(isLoading) {
        [self.progress startAnimation:self];
    } else {
        [self.progress stopAnimation:self];
    }
    
}



- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
