//
//  MessageTableItem.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "MessageTableItemServiceMessage.h"
#import "MessageTableItemText.h"
#import "MessageTableItemPhoto.h"
#import "MessageTableItemVideo.h"
#import "MessageTableItemDocument.h"
#import "MessageTableItemGeo.h"
#import "MessageTableItemContact.h"
#import "MessageTableItemAudio.h"
#import "MessageTableItemGif.h"
#import "MessagetableitemUnreadMark.h"
#import "MessageTableItemAudioDocument.h"
#import "MessageTableItemServiceMessage.h"
#import "MessageTableItemSticker.h"
#import "TGDateUtils.h"
#import "PreviewObject.h"
#import "NSString+Extended.h"
#import "MessageTableHeaderItem.h"
#import "MessageTableItemSocial.h"
@interface MessageTableItem()
@property (nonatomic) BOOL isChat;
@property (nonatomic) NSSize _viewSize;
@property (nonatomic,assign) BOOL autoStart;
@end

@implementation MessageTableItem

- (id)initWithObject:(TL_localMessage *)object {
    self = [super init];
    if(self) {
        self.message = object;
        
        
        if(object.peer.peer_id == [UsersManager currentUserId])
            object.flags&= ~TGUNREADMESSAGE;
        
        self.isForwadedMessage = ([self.message isKindOfClass:[TL_messageForwarded class]] || [self.message isKindOfClass:[TL_localMessageForwarded class]] ) && ![self.message.media isKindOfClass:[TL_messageMediaPhoto class]] && (![self.message.media isKindOfClass:[TL_messageMediaDocument class]] || ![self.message.media.document isSticker]);
        self.isChat = self.message.conversation.type == DialogTypeChat;
        
        _containerOffset = self.isForwadedMessage ? 129 : 79;
        
        if(self.message) {
           
            self.user = [[UsersManager sharedManager] find:object.from_id];
            
            if(self.isForwadedMessage) {
                self.fwd_user = [[UsersManager sharedManager] find:object.fwd_from_id];
            }
            
            [self rebuildDate];
            
            [self headerStringBuilder];
        }
    }
    return self;
}

- (void) headerStringBuilder {
//    if(!self.headerString) {
//        self.headerString = [[NSMutableAttributedString alloc] init];
//    }
//    
//    [[self.headerString mutableString] setString:@""];
    
    
    NSString *name = self.isChat ? self.user.fullName : self.user.dialogFullName;
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
    
    
    int uid = self.user.n_id;
    
    if(self.isChat && self.user.n_id != [UsersManager currentUserId]) {
        
        
       int colorMask = [TMAvatarImageView colorMask:self.user];
        
        nameColor = colors[colorMask % (sizeof(colors) / sizeof(colors[0]))];
        
    }
    
    NSMutableAttributedString *header = [[NSMutableAttributedString alloc] init];
    
    [header appendString:name withColor:nameColor];
    
    [header setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13] forRange:header.range];
    
    [header addAttribute:NSLinkAttributeName value:[TMInAppLinks userProfile:uid] range:header.range];
    
    self.headerName = header;
    
  //  self.headerSize = [self.headerName sizeForTextFieldForWidth:<#(int)#>]
    
//    NSRange range = [self.headerString appendString:name withColor:nameColor];
//    [self.headerString addAttribute:NSParagraphStyleAttributeName value:style range:range];
//    [self.headerString setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12] forRange:range];
//    [self.headerString setLink:[TMInAppLinks userProfile:self.user.n_id] forRange:range];
    
    if(self.isForwadedMessage) {
        self.forwardMessageAttributedString = [[NSMutableAttributedString alloc] init];
//        [self.forwardMessageAttributedString appendString:NSLocalizedString(@"Message.ForwardedFrom", nil) withColor:NSColorFromRGB(0x909090)];
        
        TLUser *user = [[UsersManager sharedManager] find:self.message.fwd_from_id];
        
        NSRange rangeUser = NSMakeRange(0, 0);
        if(user) {
            rangeUser = [self.forwardMessageAttributedString appendString:user.fullName withColor:LINK_COLOR];
            [self.forwardMessageAttributedString setLink:[TMInAppLinks userProfile:user.n_id] forRange:rangeUser];
            
        }
        [self.forwardMessageAttributedString appendString:@"  " withColor:NSColorFromRGB(0x909090)];
    
        [self.forwardMessageAttributedString appendString:[TGDateUtils stringForLastSeen:self.message.fwd_date] withColor:NSColorFromRGB(0xbebebe)];
        
        [self.forwardMessageAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:self.forwardMessageAttributedString.range];
        [self.forwardMessageAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13] forRange:rangeUser];
        [self.forwardMessageAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:self.forwardMessageAttributedString.range];
    }
}

- (void)setViewSize:(NSSize)viewSize {
    self._viewSize = viewSize;
}

- (NSSize)viewSize {
    NSSize viewSize = self._viewSize;
    
    if(![self isKindOfClass:[MessageTableItemServiceMessage class]] && ![self isKindOfClass:[MessageTableItemUnreadMark class]] && ![self isKindOfClass:[MessageTableHeaderItem class]]) {
        if(self.isHeaderMessage) {
            viewSize.height += 38;
            
            if(self.isForwadedMessage)
                viewSize.height += 24;
            
            if(viewSize.height < 50)
                viewSize.height = 50;
        } else {
            viewSize.height += 12;
            
            if(self.isForwadedMessage)
                viewSize.height += 24;
        }
        
        if(self.isForwadedMessage && self.isHeaderForwardedMessage)
            viewSize.height += FORWARMESSAGE_TITLE_HEIGHT;
    }
    
    
    return viewSize;
}

- (void) setBlockSize:(NSSize)blockSize {
    self->_blockSize = blockSize;
    
    self.viewSize = NSMakeSize(blockSize.width, blockSize.height);
}

+ (id) messageItemFromObject:(TLMessage *)object {
    id objectReturn = nil;

    
    if(object.class == [TL_localMessage class] || object.class == [TL_localMessageForwarded class] || object.class == [TL_destructMessage class]) {
        TLMessage *message = object;
        
        
        
        if([message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            
            Class socialClass = [MessageTableItem socialClass:message.message];
            
            if(socialClass == [NSNull class])
                objectReturn = [[MessageTableItemText alloc] initWithObject:object];
            else
                objectReturn = [[MessageTableItemSocial alloc] initWithObject:object socialClass:socialClass];
            
        } else if([message.media isKindOfClass:[TL_messageMediaUnsupported class]]) {
            
            object.message = @"This message is not supported on your version of Telegram. Update the app to view: https://telegram.org/dl/osx";
            objectReturn = [[MessageTableItemText alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
            
            objectReturn = [[MessageTableItemPhoto alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaVideo class]]) {

            objectReturn = [[MessageTableItemVideo alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaDocument class]]) {
            
            TLDocument *document = message.media.document;
            
            if([document.mime_type isEqualToString:@"image/gif"] && ![document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                objectReturn = [[MessageTableItemGif alloc] initWithObject:object];
            } else if([document.mime_type hasPrefix:@"audio/"]) {
                 objectReturn = [[MessageTableItemAudioDocument alloc] initWithObject:object];
            } else if([document isSticker]) {
                objectReturn = [[MessageTableItemSticker alloc] initWithObject:object];
            } else {
                 objectReturn = [[MessageTableItemDocument alloc] initWithObject:object];
            }
            
        } else if([message.media isKindOfClass:[TL_messageMediaContact class]]) {
            
            objectReturn = [[MessageTableItemContact alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaGeo class]]) {
            
            objectReturn = [[MessageTableItemGeo alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaAudio class]]) {
            
            objectReturn = [[MessageTableItemAudio alloc] initWithObject:object ];
            
        }
    } else if([object isKindOfClass:[TL_localMessageService class]] || [object isKindOfClass:[TL_secretServiceMessage class]]) {
        objectReturn = [[MessageTableItemServiceMessage alloc] initWithObject:object ];
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

-(void)setDownloadItem:(DownloadItem *)downloadItem {
    self->_downloadItem = downloadItem;
    
    self.downloadListener = [[DownloadEventListener alloc] initWithItem:downloadItem];
    
    [self.downloadItem addEvent:self.downloadListener];
}

-(void)rebuildDate {
    self.date = [NSDate dateWithTimeIntervalSince1970:self.message.date];
    
    int time = self.message.date;
    time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    self.dateStr = [TGDateUtils stringForMessageListDate:time];
    NSSize dateSize = [self.dateStr sizeWithAttributes:@{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:12]}];
    dateSize.width = roundf(dateSize.width);
    dateSize.height = roundf(dateSize.height);
    self.dateSize = dateSize;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.message.date];
    
    self.fullDate = [formatter stringFromDate:date];
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
    return [NSURL fileURLWithPath:mediaFilePath(self.message.media)];;
}

- (BOOL)needUploader {
    return NO;
}

- (void)doAfterDownload {
 
}


- (void)checkStartDownload:(SettingsMask)setting size:(int)size {
    self.autoStart = [SettingsArchiver checkMaskedSetting:setting];
    
    if(size > [SettingsArchiver autoDownloadLimitSize])
        self.autoStart = NO;
    
    if(!self.downloadItem || self.downloadItem.downloadState == DownloadStateCompleted || self.downloadItem.downloadState == DownloadStateCanceled)
        if(![self isset])
            self.downloadItem = [[[self downloadClass] alloc] initWithObject:self.message];
    
    
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
    
    if(!self.downloadItem) {
        self.downloadItem = [[[self downloadClass] alloc] initWithObject:self.message];
    }
    
    if((self.downloadItem.downloadState == DownloadStateCanceled || self.downloadItem.downloadState == DownloadStateWaitingStart) && (force || self.autoStart))
        [self.downloadItem start];
    
    
    
}

- (BOOL)makeSizeByWidth:(int)width {
    return NO;
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateF = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateF = [[NSDateFormatter alloc] init];
    });
    return dateF;
}

@end
