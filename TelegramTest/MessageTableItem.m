//
//  MessageTableItem.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableElements.h"

#import "MessageTableItem.h"
#import "MessageTableItemServiceMessage.h"
#import "MessageTableItemText.h"
#import "MessageTableItemPhoto.h"
#import "MessageTableItemVideo.h"
#import "MessageTableItemDocument.h"
#import "MessageTableItemGeo.h"
#import "MessageTableItemContact.h"
#import "MessageTableItemAudio.h"
#import "MessagetableitemUnreadMark.h"
#import "MessageTableItemAudioDocument.h"
#import "MessageTableItemServiceMessage.h"
#import "MessageTableItemSticker.h"
#import "MessageTableItemHole.h"
#import "MessageTableItemDate.h"
#import "MessageTableItemPinned.h"
#import "TGDateUtils.h"
#import "PreviewObject.h"
#import "NSString+Extended.h"
#import "MessageTableHeaderItem.h"
#import "MessageTableItemSocial.h"
#import "TL_localMessage_old32.h"
#import "TL_localMessage_old34.h"
#import "TL_localMessage_old44.h"
#import "NSNumber+NumberFormatter.h"
#import "MessageTableItemMpeg.h"
#import "NSAttributedString+Hyperlink.h"
#import "TGLocationRequest.h"
@interface TGItemCache : NSObject
@property (nonatomic,strong) NSMutableAttributedString *header;
@property (nonatomic,strong) TLUser *user;
@end


@implementation TGItemCache



@end

@interface MessageTableItem() <NSCopying,CLLocationManagerDelegate>
@property (nonatomic) BOOL isChat;
@property (nonatomic) NSSize _viewSize;
@property (nonatomic,assign) BOOL autoStart;
@property (nonatomic, assign) NSSize headerOriginalSize;
@property (nonatomic, assign) NSSize viewsCountAndSignOriginalSize;


@property (nonatomic,strong) TGLocationRequest *locationRequest;


@end

@implementation MessageTableItem


static NSCache *cItems;

- (id)initWithObject:(TL_localMessage *)object {
    self = [super init];
    if(self) {
        self.message = object;
        
        if(self.message.media.caption.length > 0) {
            NSMutableAttributedString *c = [[NSMutableAttributedString alloc] init];
            
            [c appendString:[[self.message.media.caption trim] fixEmoji] withColor:TEXT_COLOR];
            
            [c setFont:TGSystemFont(13) forRange:c.range];
            
            [c detectAndAddLinks:URLFindTypeHashtags | URLFindTypeLinks | URLFindTypeMentions | (self.user.isBot || self.message.peer.isChat ? URLFindTypeBotCommands : 0)];
            
            _caption = c;
        }
        
        [self rebuildDate];
        
        if(object.isFake)
            return self; // fake message;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            cItems = [[NSCache alloc] init];
            [cItems setCountLimit:100];
        });

        if(object.peer_id == [UsersManager currentUserId])
            object.flags&= ~TGUNREADMESSAGE;


        self.isForwadedMessage = self.message.fwd_from != nil;
        
        if(self.isForwadedMessage && [self.message.media isKindOfClass:[TL_messageMediaDocument class]] && ([self.message.media.document isSticker] || (self.message.media.document.audioAttr && !self.message.media.document.audioAttr.isVoice))) {
            self.isForwadedMessage = NO;
        }
        
        self.isChat = [self.message.to_id isKindOfClass:[TL_peerChat class]] || [self.message.to_id isKindOfClass:[TL_peerChannel class]];
        
        
        if(self.message) {
            
            TGItemCache *cache = [cItems objectForKey:@(channelMsgId(_isChat ? 1 : 0, object.isPost ? object.peer_id : object.from_id))];
           
            if(cache) {
                _user = cache.user;
                if(_message.isPost) {
                    _user = _message.fromUser;
                }
                
                self.headerName = cache.header;
            } else {
                [self buildHeaderAndSaveToCache];
            }
            
             NSString *viaBotUserName;
            
            if(self.isViaBot) {
                
                if([self.message isKindOfClass:[TL_destructMessage45 class]]) {
                    viaBotUserName = ((TL_destructMessage45 *)self.message).via_bot_name;
                } else {
                     _via_bot_user = [[UsersManager sharedManager] find:self.message.via_bot_id];
                    viaBotUserName = _via_bot_user.username;
                }
               
                
                if(!self.isForwadedMessage)
                {
                    _headerName = [_headerName mutableCopy];
                    
                    [_headerName appendString:@" "];
                     NSRange range = [_headerName appendString:NSLocalizedString(@"ContextBot.Message.Via", nil) withColor:GRAY_TEXT_COLOR];
                    
                    [_headerName setFont:TGSystemFont(13) forRange:range];
                    
                    [_headerName appendString:@" "];
                    range = [_headerName appendString:[NSString stringWithFormat:@"@%@",viaBotUserName] withColor:GRAY_TEXT_COLOR];
                    [_headerName addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
                    [_headerName setLink:[NSString stringWithFormat:@"chat://viabot/?username=@%@",viaBotUserName] forRange:range];
                    [_headerName setFont:TGSystemMediumFont(13) forRange:range];
                    self.headerName = self.headerName;
                    
                }
                
                
                
            }
            
            if(self.isForwadedMessage) {
                
                if(object.fwd_from.from_id != 0) {
                    self.fwd_user = [[UsersManager sharedManager] find:object.fwd_from.from_id];
                }
                
                if(object.fwd_from.channel_id != 0) {
                    self.fwd_chat = [[ChatsManager sharedManager] find:object.fwd_from.channel_id];
                }
                
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
                
                [attr appendString:NSLocalizedString(@"Messages.ForwardedMessages", nil) withColor:GRAY_TEXT_COLOR];
                [attr setFont:TGSystemFont(13) forRange:attr.range];
                
                
                _forwardHeaderAttr = attr;
                _forwardHeaderSize = [attr coreTextSizeOneLineForWidth:INT32_MAX];
                
            }
            
            [self headerStringBuilder];
            
            if(self.message.isPost) {
                [self updateViews];
            }
            
        }
        
        
        [self buildRightSize];
    }
    return self;
}





-(int)makeSize {
    return MAX(NSWidth(self.table.frame) - self.startContentOffset - (self.isHeaderMessage ? _rightSize.width : self.rightSize.width) - self.defaultContainerOffset - (self.isForwadedMessage ?  self.defaultOffset : 0),100);
}

-(void)buildHeaderAndSaveToCache {
    _user = self.message.fromUser;
    
    NSString *name = self.isChat ? self.user.fullName : self.user.dialogFullName;
    
    if(self.message.isPost)
    {
        name = self.message.conversation.chat.title;
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    
    static NSColor * colors[6];
    static NSMutableDictionary *cacheColorIds;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colors[0] = NSColorFromRGB(0xce5247);
        colors[1] = NSColorFromRGB(0xcda322);
        colors[2] = NSColorFromRGB(0x5eaf33);
        colors[3] = NSColorFromRGB(0x468ec4);
        colors[4] = NSColorFromRGB(0xac6bc8);
        colors[5] = NSColorFromRGB(0xe28941);
        
        cacheColorIds = [[NSMutableDictionary alloc] init];
    });
    
    NSColor *nameColor = LINK_COLOR;
    
    
    if(self.isChat && !self.message.isPost && self.user.n_id != [UsersManager currentUserId]) {
        
        int colorMask = [TMAvatarImageView colorMask:self.user];
        
        nameColor = colors[colorMask % (sizeof(colors) / sizeof(colors[0]))];
        
    }
    
    NSMutableAttributedString *header = [[NSMutableAttributedString alloc] init];
    
    [header appendString:name withColor:nameColor];

    [header setFont:TGSystemMediumFont(13) forRange:header.range];
    
    [header addAttribute:NSLinkAttributeName value:[TMInAppLinks peerProfile:self.message.isPost ? self.message.peer : [TL_peerUser createWithUser_id:self.message.from_id]] range:header.range];
    
    self.headerName = header;
    
    
    TGItemCache *item = [[TGItemCache alloc] init];
    item.user = _user;
    item.header = header;
    
    long cacheId = channelMsgId(_isChat ? 1 : 0, _message.isPost ? _message.peer_id : _message.from_id);
    
    
    if(item.user != nil)
        [cItems setObject:item forKey:@(cacheId)];
}



-(void)setHeaderName:(NSMutableAttributedString *)headerName {
    _headerName = headerName;
    
    NSSize headerSize = [self.headerName coreTextSizeOneLineForWidth:INT32_MAX];
    
    _headerOriginalSize = headerSize;
    _headerSize = headerSize;
}

- (void) headerStringBuilder {
    
    
    if([self isReplyMessage])
    {
        
        _replyObject = [[TGReplyObject alloc] initWithReplyMessage:self.message.replyMessage fromMessage:self.message tableItem:self];
            
    }
    
    if(self.isForwadedMessage) {
        self.forwardName = [[NSMutableAttributedString alloc] init];
        
        NSString *title = self.message.fwd_from.channel_id != 0 && !self.fwd_chat.isMegagroup ? self.fwd_chat.title : self.fwd_user.fullName ;
        
        NSRange rangeUser = NSMakeRange(0, 0);
        if(title) {
            rangeUser = [self.forwardName appendString:title withColor:LINK_COLOR];
            [self.forwardName setLink:[TMInAppLinks peerProfile:self.message.fwd_from.fwdPeer jumpId:self.message.fwd_from.channel_post] forRange:rangeUser];
            
        }
        
        [self.forwardName setFont:TGSystemFont(12) forRange:self.forwardName.range];
        
        
        
        if(self.message.fwd_from.channel_id != 0 && self.message.fwd_from.from_id != 0) {
            
            TLChat *chat = [[ChatsManager sharedManager] find:self.message.fwd_from.channel_id];
            
            if(!chat.isMegagroup) {
                [self.forwardName appendString:@" (" withColor:LINK_COLOR];
                NSRange r = [self.forwardName appendString:[NSString stringWithFormat:@"%@",self.fwd_user.first_name] withColor:LINK_COLOR];
                [self.forwardName appendString:@")" withColor:LINK_COLOR];
                
                [self.forwardName setLink:[TMInAppLinks peerProfile:[TL_peerChannel createWithChannel_id:self.message.fwd_from.channel_id]] forRange:r];
                
                [self.forwardName setFont:TGSystemMediumFont(13) forRange:r];
            }
            
        }
        
        if([self isViaBot]) {
            [self.forwardName appendString:@" "];
            NSRange range = [self.forwardName appendString:NSLocalizedString(@"ContextBot.Message.Via", nil) withColor:GRAY_TEXT_COLOR];
            [self.forwardName setFont:TGSystemFont(13) forRange:range];
            [self.forwardName appendString:@" "];
            range = [self.forwardName appendString:[NSString stringWithFormat:@"@%@",_via_bot_user.username] withColor:GRAY_TEXT_COLOR];
            [self.forwardName setFont:TGSystemBoldFont(13) forRange:range];
            [self.forwardName setLink:[NSString stringWithFormat:@"chat://viabot/?username=@%@",_via_bot_user.username] forRange:range];
            [self.forwardName addAttribute:NSForegroundColorAttributeName value:LINK_COLOR range:range];
        }
        
         [self.forwardName appendString:@"  " withColor:NSColorFromRGB(0x909090)];
    
        [self.forwardName appendString:[TGDateUtils stringForLastSeen:self.message.fwd_from.date] withColor:NSColorFromRGB(0xbebebe)];
        

        [self.forwardName setFont:TGSystemMediumFont(13) forRange:rangeUser];
        
        _forwardNameSize = [self.forwardName coreTextSizeOneLineForWidth:INT32_MAX];
        
     

    }
}

static NSTextAttachment *channelViewsCountAttachment() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:image_ChannelViews()];
    });
    return instance;
}


- (void)setViewSize:(NSSize)viewSize {
    self._viewSize = viewSize;
}



- (NSSize)viewSize {
    NSSize viewSize = self._viewSize;
    
    if(![self isKindOfClass:[MessageTableItemHole class]] && ![self isKindOfClass:[MessageTableItemDate class]] && ![self isKindOfClass:[MessageTableItemServiceMessage class]] && ![self isKindOfClass:[MessageTableItemUnreadMark class]] && ![self isKindOfClass:[MessageTableHeaderItem class]]) {
        
        if(self.isHeaderMessage) {
            
            viewSize.height += _headerSize.height + self.contentHeaderOffset + (self.defaultContentOffset * 2);
            
            if(self.isForwadedMessage)
                viewSize.height += self.contentHeaderOffset + _forwardNameSize.height + self.contentHeaderOffset;
            

        } else {
            viewSize.height += self.defaultContentOffset*2;
            
            if(self.isForwadedMessage)
            {
                viewSize.height += _forwardNameSize.height;
                viewSize.height+=self.contentHeaderOffset;
            }
            

        }
        
        if([self isReplyMessage]) {
            viewSize.height +=self.replyObject.containerHeight+self.defaultContentOffset;
        }
        
        if(self.isForwadedMessage && self.isHeaderForwardedMessage)
            viewSize.height += _forwardHeaderSize.height;
    }
    
    assert(viewSize.height > 0);
    
    
    if([self.message.action isKindOfClass:[TL_messageActionChatMigrateTo class]]) {
        viewSize.height = 1;
    }
    
    if(self.message.reply_markup.isInline) {
        viewSize.height+=_inlineKeyboardSize.height+self.defaultContentOffset;
    }
    
    viewSize.width = self.makeSize + (self.isForwadedMessage ? self.defaultOffset : 0);
    
    if(![self isKindOfClass:[MessageTableItem class]]) {
        if(self.isHeaderMessage) {
            viewSize.height = MAX(46,viewSize.height);
        } else {
            viewSize.height = MAX(28,viewSize.height);
        }
    }
    return viewSize;
}

-(BOOL)isViaBot {
    return self.message.via_bot_id != 0 || ([self.message isKindOfClass:[TL_destructMessage45 class]] && ((TL_destructMessage45 *)self.message).via_bot_name.length > 0);
}

- (void) setBlockSize:(NSSize)blockSize {
    self->_blockSize = blockSize;
    
    self.viewSize = NSMakeSize(blockSize.width, blockSize.height);
}


+ (NSArray *)messageTableItemsFromMessages:(NSArray *)input {
    NSMutableArray *array = [NSMutableArray array];
    for(TLMessage *message in input) {
        MessageTableItem *item = [MessageTableItem messageItemFromObject:message];
        if(item) {
            item.isSelected = NO;
            [array insertObject:item atIndex:0];
        }
    }
    return array;
}

+ (id) messageItemFromObject:(TL_localMessage *)message {
    id objectReturn = nil;

    
    @try {
        if(message.class == [TL_localMessage_old46 class] || message.class == [TL_localMessage class] || message.class == [TL_localMessage_old32 class] || message.class == [TL_localMessage_old34 class] || message.class == [TL_localMessage_old44 class] || message.class == [TL_destructMessage class] || message.class == [TL_destructMessage45 class]) {
            
            if((message.media == nil || [message.media isKindOfClass:[TL_messageMediaEmpty class]]) || [message.media isMemberOfClass:[TL_messageMediaWebPage class]]) {
                
                objectReturn = [[MessageTableItemText alloc] initWithObject:message];
                
            } else if([message.media isKindOfClass:[TL_messageMediaUnsupported class]]) {
                
                message.message = @"This message is not supported on your version of Telegram. Update the app to view: https://telegram.org/dl/osx";
                objectReturn = [[MessageTableItemText alloc] initWithObject:message ];
                
            } else if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
                
                objectReturn = [[MessageTableItemPhoto alloc] initWithObject:message ];
                
            } else if([message.media isKindOfClass:[TL_messageMediaVideo class]]) {
                
                objectReturn = [[MessageTableItemVideo alloc] initWithObject:message ];
                
            } else if([message.media isKindOfClass:[TL_messageMediaDocument class]] || [message.media isKindOfClass:[TL_messageMediaDocument_old44 class]]) {
                
                TLDocument *document = message.media.document;
                
                if(document.isGif) {
                    objectReturn = [[MessageTableItemMpeg alloc] initWithObject:message];
                } else if(document.isVideo) {
                    objectReturn = [[MessageTableItemVideo alloc] initWithObject:message];
                } else if(document.isAudio) {
                    objectReturn = [[MessageTableItemAudioDocument alloc] initWithObject:message];
                } else if(document.isSticker) {
                    objectReturn = [[MessageTableItemSticker alloc] initWithObject:message];
                } else if(document.isVoice) {
                    objectReturn = [[MessageTableItemAudio alloc] initWithObject:message];
                } else {
                    objectReturn = [[MessageTableItemDocument alloc] initWithObject:message];
                }
                
            } else if([message.media isKindOfClass:[TL_messageMediaContact class]]) {
                
                objectReturn = [[MessageTableItemContact alloc] initWithObject:message];
                
            } else if([message.media isKindOfClass:[TL_messageMediaGeo class]] || [message.media isKindOfClass:[TL_messageMediaVenue class]]) {
                
                objectReturn = [[MessageTableItemGeo alloc] initWithObject:message];
                
            }  else if([message.media isKindOfClass:[TL_messageMediaBotResult class]]) {
                
                if([message.media.bot_result.send_message isKindOfClass:[TL_botInlineMessageText class]]) {
                    objectReturn = [[MessageTableItemText alloc] initWithObject:message];
                }
                
                NSString *mime_type = message.media.bot_result.document ? message.media.bot_result.document.mime_type : message.media.bot_result.content_type;
                
                if(([message.media.bot_result.type isEqualToString:kBotInlineTypeGif])) {
                    objectReturn = [[MessageTableItemMpeg alloc] initWithObject:message];
                } else if([message.media.bot_result.type isEqualToString:kBotInlineTypePhoto]) {
                    objectReturn = [[MessageTableItemPhoto alloc] initWithObject:message];
                } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeAudio]) {
                    
                    if([mime_type isEqualToString:@"audio/ogg"])
                        objectReturn = [[MessageTableItemAudio alloc] initWithObject:message];
                    else
                        objectReturn = [[MessageTableItemAudioDocument alloc] initWithObject:message];
                    
                } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeVideo]) {
                    objectReturn = [[MessageTableItemVideo alloc] initWithObject:message];
                } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeFile]) {
                    objectReturn = [[MessageTableItemDocument alloc] initWithObject:message];
                } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeVenue]) {
                    objectReturn = [[MessageTableItemGeo alloc] initWithObject:message];
                } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeContact]) {
                    objectReturn = [[MessageTableItemContact alloc] initWithObject:message];
                } else if([message.media.bot_result.type isEqualToString:kBotInlineTypeSticker]) {
                    objectReturn = [[MessageTableItemSticker alloc] initWithObject:message];
                }
                
                if(!objectReturn) {
                    message.message = @"This message is not supported on your version of Telegram. Update the app to view: https://telegram.org/dl/osx";
                    objectReturn = [[MessageTableItemText alloc] initWithObject:message];
                }
                
            }
        } else if(message.hole != nil) {
            objectReturn = [[MessageTableItemHole alloc] initWithObject:message];
        } else if([message isKindOfClass:[TL_localMessageService class]] || [message isKindOfClass:[TL_secretServiceMessage class]] || [message isKindOfClass:[TL_localMessageService_old48 class]]) {
            
            if([message.action isKindOfClass:[TL_messageActionPinMessage class]]) {
                objectReturn = [[MessageTableItemPinned alloc] initWithObject:message];
            } else
                objectReturn = [[MessageTableItemServiceMessage alloc] initWithObject:message];
        }

    }
    @catch (NSException *exception) {
        int bp = 0;
    }
    

    
    return objectReturn;
}

+(Class)socialClass:(NSString *)message {
    
    if(message == nil)
        return [NSNull class];
    
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:1ULL << 5 error:nil];
    
    
    NSArray *results = [detect matchesInString:message options:0 range:NSMakeRange(0, [message length])];

    
    if(results.count != 1)
        return [NSNull class];
    
    NSRange range = [results[0] range];
    
    if(range.location != 0 || range.length != message.length)
        return [NSNull class];

    // youtube checker
    
     NSString *vid = [YoutubeServiceDescription idWithURL:message];
    
    
    if(vid.length > 0)
        return [YoutubeServiceDescription class];
    
    
    NSString *iid = [InstagramServiceDescription idWithURL:message];
    
    if(iid.length > 0)
        return [InstagramServiceDescription class];
    
    return [NSNull class];
    
    
}

-(void)clean {
    [self.messageSender cancel];
    self.messageSender = nil;
    [self.downloadItem cancel];
    self.downloadItem = nil;
}

-(DownloadItem *)downloadItem {
    if(_downloadItem == nil)
        _downloadItem = [DownloadQueue find:self.message.n_id];
    
    return _downloadItem;
}

-(void)rebuildDate {
    self.date = [NSDate dateWithTimeIntervalSince1970:self.message.date];
    
    int time = self.message.date;
    time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    NSMutableAttributedString *dString = [[NSMutableAttributedString alloc] init];
    
    [dString appendString:[TGDateUtils stringForMessageListDate:time] withColor:GRAY_TEXT_COLOR];
    [dString setFont:TGSystemFont(12) forRange:dString.range];
    _dateAttributedString = dString;

    _dateSize = [dString coreTextSizeOneLineForWidth:INT32_MAX];
     
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.message.date];
    
    self.fullDate = [formatter stringFromDate:date];
}

-(void)buildRightSize {
    
    const int selectSize = 18;
    const int selectOffset = self.defaultOffset;
    const int sendingUnreadReadSize = 16;
    const int sendingUnreadReadOffset = self.defaultOffset;
    
    int w = _dateSize.width +selectSize + selectOffset + sendingUnreadReadSize + sendingUnreadReadOffset;
    
    if(!self.message.n_out && !self.message.isPost) {
        w = _dateSize.width + selectSize + selectOffset;
    }
    
    _rightSize = NSMakeSize(w,_dateSize.height);
}

-(NSSize)rightSize {
    return NSMakeSize(_rightSize.width + _viewsCountAndSignSize.width, _dateSize.height);
}


- (Class)downloadClass {
    return [NSNull class];
}

- (BOOL)canDownload {
    return NO;
}

- (BOOL)isset {
    return YES;
}

-(BOOL)canShare {
    return NO;
}

-(NSURL *)shareObject {
    return [NSURL fileURLWithPath:mediaFilePath(self.message)];
}

- (BOOL)needUploader {
    return NO;
}

- (void)doAfterDownload {
    _downloadItem = nil;
}


- (void)checkStartDownload:(SettingsMask)setting size:(int)size {
    self.autoStart = [SettingsArchiver checkMaskedSetting:setting];
    
    if(size > [SettingsArchiver autoDownloadLimitSize])
        self.autoStart = NO;

        
    if((self.autoStart && !self.downloadItem && !self.isset) || (self.downloadItem && self.downloadItem.downloadState != DownloadStateCanceled)) {
        [self startDownload:NO force:NO];
    }
    
}

-(id)identifier {
    return @(self.message.n_id);
}


-(NSString *)string {
    return ((MessageTableItemText *)self).textAttributed.string;
}

- (void)startDownload:(BOOL)cancel force:(BOOL)force {


    DownloadItem *downloadItem = self.downloadItem;
    
    if(!downloadItem) {
        downloadItem = [[[self downloadClass] alloc] initWithObject:self.message];
    }
    
    if((downloadItem.downloadState == DownloadStateCanceled || downloadItem.downloadState == DownloadStateWaitingStart) && (force || self.autoStart)) {
        [downloadItem start];
    }
    
}

-(BOOL)isReplyMessage {
    return (self.message.reply_to_msg_id != 0 && ![self.message.replyMessage isKindOfClass:[TL_localEmptyMessage class]]) || ([self.message isKindOfClass:[TL_destructMessage45 class]] && ((TL_destructMessage45 *)self.message).reply_to_random_id != 0);
}


- (BOOL)makeSizeByWidth:(int)width {
    _blockWidth = width;
    
    if(_caption) {
        _captionSize = [_caption coreTextSizeForTextFieldForWidth:self.blockSize.width];
        self.blockSize = NSMakeSize(self.blockSize.width, self.blockSize.height + _captionSize.height + self.defaultContentOffset);
    }
    
    _viewsCountAndSignSize = NSMakeSize(MIN(MAX(width - _headerOriginalSize.width/2.0f,0),_viewsCountAndSignOriginalSize.width), self.viewsCountAndSignSize.height);
    
    self.headerSize = NSMakeSize(MIN(_headerOriginalSize.width, width - self.defaultOffset * 2), self.headerSize.height);
    
    if(_message.reply_markup.rows) {
        _inlineKeyboardSize = NSMakeSize(MIN(300,width), _message.reply_markup.rows.count > 1 ? _message.reply_markup.rows.count * (33 + self.defaultContentOffset) - self.defaultContentOffset *2 : 33);
    }
    
    
    return YES;
}

-(int)fontSize {
    return [SettingsArchiver checkMaskedSetting:BigFontSetting] ? 15 : 13;
}


-(BOOL)updateViews {
    
    NSAttributedString *o = _viewsCountAndSign;
    
    NSMutableAttributedString *signString = [[NSMutableAttributedString alloc] init];
    
    NSRange range = [signString appendString:[@(MAX(1,self.message.views)) prettyNumber] withColor:GRAY_TEXT_COLOR];
    
    if(self.message.isPost && self.message.from_id != 0) {
        [signString appendString:@" "];
        range = [signString appendString:_user.fullName withColor:GRAY_TEXT_COLOR];
      //  [signString setLink:[TMInAppLinks peerProfile:[TL_peerUser createWithUser_id:_user.n_id]] forRange:range];
    }
    
    [signString setFont:TGSystemFont(12) forRange:signString.range];
    
     _viewsCountAndSignOriginalSize = _viewsCountAndSignSize = [signString coreTextSizeOneLineForWidth:INT32_MAX];
    
    _viewsCountAndSign = signString;
    
    return ![_viewsCountAndSign.string isEqualToString:o.string];
    
}

-(id)copy {
    MessageTableItem *item = [MessageTableItem messageItemFromObject:self.message];
    
    item.messageSender = self.messageSender;
    
    return item;
}



-(void)proccessInlineKeyboardButton:(TLKeyboardButton *)keyboard handler:(void (^)(TGInlineKeyboardProccessType type))handler {
    
    assert(handler != nil);
    
    if([keyboard isKindOfClass:[TL_keyboardButtonCallback class]]) {
        
        weak();
        
        handler(TGInlineKeyboardProccessingType);
        
        [RPCRequest sendRequest:[TLAPI_messages_getBotCallbackAnswer createWithPeer:_message.conversation.inputPeer msg_id:_message.n_id data:keyboard.data] successHandler:^(id request, TL_messages_botCallbackAnswer *response) {
            
            strongWeak();
            
            if(strongSelf == weakSelf) {
                if([response isKindOfClass:[TL_messages_botCallbackAnswer class]]) {
                    if(response.isAlert)
                        alert(appName(), response.message);
                    else
                        if(response.message.length > 0)
                            [Notification perform:SHOW_ALERT_HINT_VIEW data:@{@"text":response.message,@"color":NSColorFromRGB(0x4ba3e2)}];
                }
                
                handler(TGInlineKeyboardSuccessType);
            }
            
            
        } errorHandler:^(id request, RpcError *error) {
            handler(TGInlineKeyboardErrorType);
        }];
        
    } else if([keyboard isKindOfClass:[TL_keyboardButtonUrl class]]) {
        open_link(keyboard.url);
        handler(TGInlineKeyboardSuccessType);
        
    } else if([keyboard isKindOfClass:[TL_keyboardButtonRequestGeoLocation class]]) {
        
        weak();
        
        [SettingsArchiver requestPermissionWithKey:kPermissionInlineBotGeo peer_id:_message.peer_id handler:^(bool success) {
            
            if(success) {
                strongWeak();
                
                handler(TGInlineKeyboardProccessingType);
                
                strongSelf.locationRequest = [[TGLocationRequest alloc] init];
                
                [strongSelf.locationRequest startRequestLocation:^(CLLocation *location) {
                    
                    [strongSelf.table.viewController sendLocation:location.coordinate forConversation:_message.conversation];
                    
                    handler(TGInlineKeyboardSuccessType);
                    
                } failback:^(NSString *error) {
                    
                    handler(TGInlineKeyboardErrorType);
                    
                    alert(appName(), error);
                    
                }];

            } else {
                handler(TGInlineKeyboardErrorType);
            }
            
        }];
        
        
    } else if([keyboard isKindOfClass:[TL_keyboardButtonRequestPhone class]]) {
        
        weak();
        
        [SettingsArchiver requestPermissionWithKey:kPermissionInlineBotContact peer_id:_message.peer_id handler:^(bool success) {
            
            if(success) {
                strongWeak();
                
                [strongSelf.table.viewController shareContact:[UsersManager currentUser] forConversation:_message.conversation callback:nil];
                
                handler(TGInlineKeyboardSuccessType);
            }
            
        }];
        
    } else if([keyboard isKindOfClass:[TL_keyboardButton class]]) {
        [self.table.viewController sendMessage:keyboard.text forConversation:_message.conversation];
        
        handler(TGInlineKeyboardSuccessType);
    }
}


-(id)copyWithZone:(NSZone *)zone {
    return [self copy];
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateF = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateF = [[NSDateFormatter alloc] init];
    });
    return dateF;
}

-(Class)viewClass {
    return [TGModernMessageCellContainerView class];
}

-(int)cellWidth {
    return NSWidth(self.table.frame);
}

-(BOOL)hasRightView {
    return YES;
}

-(NSString *)path {
    return mediaFilePath(self.message);
}


-(int)defaultContentOffset {
    return 6;
}
-(int)defaultOffset {
    return 10;
}

+(int)defaultOffset {
    return 10;
}

-(int)contentHeaderOffset {
    return 6;
}

-(int)defaultContainerOffset {
    return 20;
}

+(int)defaultContainerOffset {
    return 20;
}

-(int)startContentOffset {
    return self.defaultContainerOffset + self.defaultPhotoWidth + self.defaultOffset;
}

-(int)defaultPhotoWidth {
    return 36;
}

-(void)dealloc {
    
}

@end
