
//
//  TGMentionPopup.m
//  Telegram
//
//  Created by keepcoder on 02.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGMentionPopup.h"
#import "TMMenuPopover.h"
#import "TMAvaImageObject.h"
#import "TMAvatarImageView.h"
@interface TGMentionPhoto : NSObject <TGImageObjectDelegate>

@property (nonatomic,weak,readonly) NSMenuItem *menuItem;
@property (nonatomic,strong,readonly) TLUser *user;

@property (nonatomic,strong) TMAvaImageObject *imageObject;

-(id)initWithUser:(TLUser *)user menuItem:(NSMenuItem *)menuItem;



@end


@implementation TGMentionPhoto

-(id)initWithUser:(TLUser *)user menuItem:(NSMenuItem *)menuItem {
    if(self = [super init]) {
        _user = user;
        _menuItem = menuItem;
        
        [self generatePhoto];
        
    }
    
    return self;
}

static NSImage *mentionCap() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSRect rect = NSMakeRect(0, 0, 30, 30);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        [NSColorFromRGB(0xffffff) set];
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:rect.size.width/2 yRadius:rect.size.height/2];
        [path fill];
        
        
        [image unlockFocus];
    });
    return image;//image_VideoPlay();
}

-(void)generatePhoto {
    
    
    
    self.imageObject = [[TMAvaImageObject alloc] initWithLocation:_user.photo.photo_small];
    
    self.imageObject.delegate = self;
    
    self.imageObject.imageSize = NSMakeSize(30, 30);
    
    NSImage *image = [TGCache cachedImage:self.imageObject.cacheKey];
        
    
    if(!image) {
        
        if(![_user.photo isKindOfClass:[TL_userProfilePhotoEmpty class]]) {
            self.menuItem.image = mentionCap();
            [self.imageObject initDownloadItem];
        } else {
            
            int colorMask = [TMAvatarImageView colorMask:_user];
            
            NSString *text = [TMAvatarImageView text:_user];
            
            image = [TMAvatarImageView generateTextAvatar:colorMask size:NSMakeSize(30, 30) text:text type: TMAvatarTypeUser font:[NSFont fontWithName:@"HelveticaNeue" size:12] offsetY:2];
            
            self.menuItem.image = image;
        }

    } else
        self.menuItem.image = image;
    
    
    
}

-(void)didDownloadImage:(NSImage *)image object:(id)object {
    
    
    _menuItem.highlightedImage = image;
    _menuItem.image = image;
    
    
}


@end



@interface TGMentionPopup ()

@end

@implementation TGMentionPopup


static TMMenuPopover *popover;

+(void)show:(NSString *)string chat:(TLChat *)chat view:(NSView *)view ofRect:(NSRect)rect callback:(void (^)(NSString *userName))callback {
    
    
    TLChatFull *fullChat = [[FullChatManager sharedManager] find:chat.n_id];
    
    NSMutableArray *uids = [[NSMutableArray alloc] init];
    
    [fullChat.participants.participants enumerateObjectsUsingBlock:^(TLChatParticipant * obj, NSUInteger idx, BOOL *stop) {
        [uids addObject:@(obj.user_id)];
        
    }];
    
    
    NSArray *users = [UsersManager findUsersByMention:string withUids:uids];
    
    
    users = [users subarrayWithRange:NSMakeRange(0, MIN(20,users.count))];
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"menu"];
    
    [users enumerateObjectsUsingBlock:^(TLUser *obj, NSUInteger idx, BOOL *stop) {
        
        NSMenuItem *item = [NSMenuItem menuItemWithTitle:obj.fullName withBlock:^(id sender) {
            
            callback(obj.username);
            
            [popover close];
            popover = nil;
            
        }];
        
        [item setSubtitle:[NSString stringWithFormat:@"@%@",obj.username]];
        
        item.representedObject = [[TGMentionPhoto alloc] initWithUser:obj menuItem:item];
        
        
        [menu addItem:item];
        
    }];
    
    if(menu.itemArray.count > 0) {
        [popover close];
        
        popover = [[TMMenuPopover alloc] initWithMenu:menu];
        
        [popover setAutoHighlight:NO];
        
        [popover showRelativeToRect:rect ofView:view preferredEdge:CGRectMinYEdge];
        
        [popover.contentViewController selectNext];
    } else {
        [popover close];
        popover = nil;
    }
    
}


+(BOOL)isVisibility {
    return [popover isShown];
    
}

+(void)performSelected {
    [popover.contentViewController performSelected];
}

+(void)selectNext {
    [popover.contentViewController selectNext];
}

+(void)selectPrev {
    [popover.contentViewController selectPrev];
}

+(void)close {
    [popover close];
}


@end
