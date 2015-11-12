//
//  NoMessagesView.m
//  Messenger for Telegram
//
//  Created by keepcoder on 15.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NoMessagesView.h"
#import "MessagesUtils.h"
#import "FullUsersManager.h"
#import "TGCTextView.h"
#import "NSAttributedString+Hyperlink.h"
@interface NoMessagesView ()
@property (nonatomic,strong) NSProgressIndicator *progress;
@property (nonatomic,strong) TGCTextView *field;
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) NSAttributedString *secret;

@property (nonatomic,strong) NSAttributedString *defAttrString;

@property (nonatomic,strong) TMAvatarImageView *avatarImageView;

@end

@implementation NoMessagesView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _avatarImageView = [TMAvatarImageView standartUserInfoAvatar];
        
        [self addSubview:_avatarImageView];
        
        
        [self setBackgroundColor:NSColorFromRGB(0xffffff)];
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable];
        
        _field = [[TGCTextView alloc] initWithFrame:NSMakeRect(0, roundf(self.frame.size.height / 2 - 12.5), self.bounds.size.width, 25)];
       
      
        
       // [self.field setBackgroundColor:NSColorFromRGB(0xf43d2)];
        
        [self addSubview:_field];
        
        
        self.progress = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(roundf(self.frame.size.width / 2 - 12.5), roundf(self.frame.size.height / 2 - 12.5), 25, 25)];
        
        [self.progress setStyle:NSProgressIndicatorSpinningStyle];
        
        [self addSubview:self.progress];
        
        self.secret = [self buildSecretString];
        
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:NSLocalizedString(@"Conversation.NoMessages", nil) withColor:NSColorFromRGB(0x9b9b9b)];
        
        [attr setAlignment:NSCenterTextAlignment range:attr.range];
        
        _defAttrString = attr;

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
    [subParagraphStyle setAlignment:NSCenterTextAlignment];
    [subParagraphStyle setParagraphSpacing:4];
    
    NSMutableParagraphStyle *subParagraphStyle2 = [[NSMutableParagraphStyle alloc] init];
    [subParagraphStyle2 setLineBreakMode:NSLineBreakByTruncatingTail];
    [subParagraphStyle2 setAlignment:NSCenterTextAlignment];
    [subParagraphStyle2 setParagraphSpacing:3];
  
    
    TLEncryptedChat *chat = self.conversation.encryptedChat;
    
    
    NSString *descFormat = chat.admin_id == [UsersManager currentUserId] ?  NSLocalizedString(@"Secret.join.description", nil) :  NSLocalizedString(@"Secret.join.invitedDescription", nil);
    
    
    [string appendString:[NSString stringWithFormat:descFormat,chat.peerUser.first_name] withColor:NSColorFromRGB(0x9b9b9b)];
    
    [string setFont:TGSystemFont(13) forRange:NSMakeRange(0, string.length)];
    
    [string addAttribute:NSParagraphStyleAttributeName value:subParagraphStyle2 range:NSMakeRange(0, string.length)];
    
    
    [string setFont:TGSystemMediumFont(13) forRange:NSMakeRange([descFormat rangeOfString:@"%1$@"].location, self.conversation.encryptedChat.peerUser.first_name.length)];
    

    NSRange range = [string appendString:NSLocalizedString(@"Secret.join.secret_chats",nil) withColor:NSColorFromRGB(0x9b9b9b)];
    
    [string setFont:TGSystemFont(13) forRange:range];
    
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

    [subString setFont:TGSystemFont(13) forRange:NSMakeRange(0, subString.length)];
    
    [subString addAttribute:NSParagraphStyleAttributeName value:subParagraphStyle range:NSMakeRange(0, subString.length)];
    
    
    [string appendAttributedString:subString];
    
    return string;
    
}


-(void)setConversation:(TL_conversation *)conversation {
    
    assert([NSThread isMainThread]);
    
    [_avatarImageView updateWithConversation:conversation];
    
    _conversation = conversation;
    // && conversation.top_message == -1
    
    [self.field removeFromSuperview];
    
    dispatch_block_t updateSize = ^{
        NSSize size = [self.field isKindOfClass:[TMTextField class]] ? [((TMTextField *)_field).attributedStringValue sizeForTextFieldForWidth:NSWidth(self.frame) - 100] : [self.field.attributedString coreTextSizeForTextFieldForWidth:NSWidth(self.frame) - 100];
        
        [self.field setFrameSize:size];
        [self setFrameSize:self.frame.size];
    };
    
    [_avatarImageView setHidden:conversation.type != DialogTypeUser || conversation.user.isBot];
    
    if(conversation.type == DialogTypeSecretChat) {
        
        self.field = [TMTextField defaultTextField];
        
        self.secret = [self buildSecretString];
        
        [(TMTextField *)self.field setAttributedStringValue:self.secret];
                
    } else {
        
        self.field = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        
        if(conversation.user.isBot) {
            
            [[FullUsersManager sharedManager] loadUserFull:conversation.user callback:^(TL_userFull *userFull) {
                
                if(userFull.bot_info.n_description.length > 0) {
                    TL_localMessageService *service = [TL_localMessageService createWithFlags:0 n_id:0 from_id:0 to_id:_conversation.peer date:0 action:[TL_messageActionBotDescription createWithTitle:userFull.bot_info.n_description] fakeId:0 randomId:rand_long() dstate:DeliveryStateNormal];
                                        
                        NSMutableAttributedString *attr = [[MessagesUtils serviceAttributedMessage:service forAction:service.action] mutableCopy];
                    
                    [attr detectAndAddLinks:URLFindTypeAll];
                    
                    
                    [self.field setAttributedString:attr];
                } else {
                    [self.field setAttributedString:_defAttrString];
                }
               
                updateSize();
                
            }];
            
        } else {
            [self.field setAttributedString:_defAttrString];
        }
        
    }
    
    [self addSubview:_field];
    
    self.progress.usesThreadedAnimation = NO;

    updateSize();
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    
    if(_avatarImageView.isHidden) {
        [self.field setCenterByView:self];
    } else {
        [_avatarImageView setCenterByView:self];
        
        
        [_avatarImageView setCenteredXByView:self];
        [_field setCenteredXByView:self];
        
        int totalHeight = NSHeight(_avatarImageView.frame) + NSHeight(_field.frame) + 10;
        
        [_field setFrameOrigin:NSMakePoint(NSMinX(_field.frame), roundf((newSize.height - totalHeight)/2))];
        [_avatarImageView setFrameOrigin:NSMakePoint(NSMinX(_avatarImageView.frame) , roundf((newSize.height - totalHeight)/2 + NSHeight(_field.frame) + 10))];
    }
    
    
}

-(void)setHidden:(BOOL)flag {
    
    assert([NSThread isMainThread]);
    
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
    
    assert([NSThread isMainThread]);
    
    [self.progress setHidden:!isLoading || self.conversation.type == DialogTypeSecretChat];
   
    
    [self.field setHidden:!self.progress.isHidden];
    
    
    [_avatarImageView setHidden:_avatarImageView.isHidden || !self.progress.isHidden];
    
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
