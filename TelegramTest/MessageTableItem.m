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
#import "MessageTableItemPVG.h"
#import "MessageTableItemPhoto.h"
#import "MessageTableItemVideo.h"
#import "MessageTableItemDocument.h"
#import "MessageTableItemGeo.h"
#import "MessageTableItemContact.h"
#import "MessageTableItemAudio.h"
#import "MessageTableItemGif.h"
#import "MessagetableitemUnreadMark.h"
#import "TGDialog+Extensions.h"
#import "MessageTableItemServiceMessage.h"
#import "TGDateUtils.h"
#import "PreviewObject.h"
#import "NSString+Extended.h"
#import "MessageTableHeaderItem.h"

@interface MessageTableItem()
@property (nonatomic) BOOL isChat;
@property (nonatomic) NSSize _viewSize;
@property (nonatomic,assign) BOOL autoStart;
@end

@implementation MessageTableItem

- (id)initWithObject:(TGMessage *)object {
    self = [super init];
    if(self) {
        self.message = object;
        
        
        if(object.peer.peer_id == [UsersManager currentUserId])
            object.unread = NO;
        
        self.isForwadedMessage = [self.message isKindOfClass:[TL_messageForwarded class]] || [self.message isKindOfClass:[TL_localMessageForwarded class]];
        self.isChat = self.message.dialog.type == DialogTypeChat;
        
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
    
    static NSColor * color[8];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color[0] = NSColorFromRGB(0xe74336);
        color[1] = NSColorFromRGB(0x4fad2d);
        color[2] = NSColorFromRGB(0xc68b02);
        color[3] = NSColorFromRGB(0x1173be);
        color[4] = NSColorFromRGB(0x8544d6);
        color[5] = NSColorFromRGB(0xe63e7b);
        color[6] = NSColorFromRGB(0x0ba28e);
        color[7] = NSColorFromRGB(0x92a708);
    });
    
    NSColor *nameColor = self.isChat ? color[self.user.n_id % 8] : LINK_COLOR;
  
    
    self.headerName = name;
    self.headerColor = nameColor;
    
//    NSRange range = [self.headerString appendString:name withColor:nameColor];
//    [self.headerString addAttribute:NSParagraphStyleAttributeName value:style range:range];
//    [self.headerString setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12] forRange:range];
//    [self.headerString setLink:[TMInAppLinks userProfile:self.user.n_id] forRange:range];
    
    if(self.isForwadedMessage) {
        self.forwardMessageAttributedString = [[NSMutableAttributedString alloc] init];
//        [self.forwardMessageAttributedString appendString:NSLocalizedString(@"Message.ForwardedFrom", nil) withColor:NSColorFromRGB(0x909090)];
        
        TGUser *user = [[UsersManager sharedManager] find:self.message.fwd_from_id];
        
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

+ (id) messageItemFromObject:(TGMessage *)object {
    id objectReturn = nil;

    
    if(object.class == [TL_localMessage class] || object.class == [TL_localMessageForwarded class] || object.class == [TL_destructMessage class]) {
        TGMessage *message = object;
        
        
        
        if([message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
            
            objectReturn = [[MessageTableItemText alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaUnsupported class]]) {
            
            object.message = @"This message is not supported on your version of Telegram. Update the app to view: http://vk.com/telegram_osx";
            objectReturn = [[MessageTableItemText alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaPhoto class]]) {
            
            objectReturn = [[MessageTableItemPhoto alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaVideo class]]) {

            objectReturn = [[MessageTableItemVideo alloc] initWithObject:object ];
            
        } else if([message.media isKindOfClass:[TL_messageMediaDocument class]]) {
            
            TGDocument *document = message.media.document;
            
            if([document.mime_type isEqualToString:@"image/gif"] && ![document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
                objectReturn = [[MessageTableItemGif alloc] initWithObject:object];
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
    } else if([object isKindOfClass:[TL_localMessageService class]]) {
        objectReturn = [[MessageTableItemServiceMessage alloc] initWithObject:object ];
    }
    
    
    return objectReturn;
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
    NSSize dateSize = [self.dateStr sizeWithAttributes:@{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:11]}];
    dateSize.width = roundf(dateSize.width);
    dateSize.height = roundf(dateSize.height);
    self.dateSize = dateSize;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.message.date];
    
    self.fullDate = [formatter stringFromDate:date];
}


- (BOOL)canDownload {
    return NO;
}

- (BOOL)isset {
    return YES;
}

- (BOOL)needUploader {
    return NO;
}

- (void)doAfterDownload {
 
}


- (void)checkStartDownload:(SettingsMask)setting size:(int)size downloadItemClass:(Class)itemClass {
    self.autoStart = [SettingsArchiver checkMaskedSetting:setting];
    
    if(size > [SettingsArchiver autoDownloadLimitSize])
        self.autoStart = NO;
    
    if(!self.downloadItem || self.downloadItem.downloadState == DownloadStateCompleted || self.downloadItem.downloadState == DownloadStateCanceled)
        if(![self isset])
            self.downloadItem = [[itemClass alloc] initWithObject:self.message];
    
    
    if((self.autoStart && !self.downloadItem && !self.isset) || (self.downloadItem && self.downloadItem.downloadState != DownloadStateCanceled)) {
        [self startDownload:NO downloadItemClass:itemClass force:NO];
    }
    
    
}

- (void)startDownload:(BOOL)cancel downloadItemClass:(Class)itemClass force:(BOOL)force {
    
    if(!self.downloadItem) {
        self.downloadItem = [[itemClass alloc] initWithObject:self.message];
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
