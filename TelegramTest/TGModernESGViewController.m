//
//  TGModernESGViewController.m
//  Telegram
//
//  Created by keepcoder on 20/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernESGViewController.h"

@interface TGModernESGViewController ()
@property (nonatomic,strong) TMView *separator;
@end

@implementation TGModernESGViewController

-(void)loadView {
    [super loadView];
    
    self.view.wantsLayer = YES;
    self.view.layer.cornerRadius = 4;
    self.view.autoresizesSubviews = YES;
    _separator = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, DIALOG_BORDER_WIDTH, NSHeight(self.view.frame))];
    _separator.autoresizingMask = NSViewHeightSizable;
    [_separator setBackgroundColor:DIALOG_BORDER_COLOR];
    [_separator setHidden:YES];
    
    self.navigationViewController = [[TMNavigationController alloc] initWithFrame:self.view.bounds];
    
    self.navigationViewController.view.wantsLayer = YES;
    
    [self.view addSubview:self.navigationViewController.view];
    
    [self.view addSubview:_separator];
    
    _emojiViewController = [[TGModernEmojiViewController alloc] initWithFrame:self.view.bounds];
    _sgViewController = [[TGModernSGViewController alloc] initWithFrame:self.view.bounds];
    
    
    
    [_emojiViewController loadViewIfNeeded];
    [_sgViewController loadViewIfNeeded];
    
    _emojiViewController.esgViewController = self;
    _sgViewController.esgViewController = self;
    _emojiViewController.isNavigationBarHidden = YES;
    _sgViewController.isNavigationBarHidden = YES;

    
   
}

static NSMutableArray *sets;
static NSMutableDictionary *stickers;

+(NSDictionary *)allStickers {
    
    if(!stickers) {
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            NSDictionary *info  = [transaction objectForKey:@"modern_stickers" inCollection:STICKERS_COLLECTION];
            
            stickers = info[@"serialized"];
            
        }];
    }
    
    
    return stickers;
}

+(NSArray *)allSets {
    
    if(!sets) {
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            NSDictionary *info = [transaction objectForKey:@"modern_stickers" inCollection:STICKERS_COLLECTION];
            
            sets = info[@"sets"];
            
        }];
    }
    
    
    return sets;
}

+(TL_stickerSet *)setWithId:(long)n_id {
    NSArray *sets = [self allSets];
    
    __block TL_stickerSet *set;
    
    [sets enumerateObjectsUsingBlock:^(TL_stickerSet *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if(obj.n_id == n_id) {
            set = obj;
            *stop = YES;
        }
        
    }];
    
    return set;
}

+(NSArray *)stickersWithId:(long)n_id {
    NSDictionary *stickers = [self allStickers];
    return stickers[@(n_id)];
}

+(void)reloadStickers {
    sets = nil;
    stickers = nil;
    [[self controller].sgViewController reloadStickers];
}
-(void)setIsLayoutStyle:(BOOL)isLayoutStyle {
    _isLayoutStyle = isLayoutStyle;
   
    [self.view setNeedsDisplay:YES];
    [_separator setHidden:!isLayoutStyle];
}

-(void)setMessagesViewController:(MessagesViewController *)messagesViewController {
    _messagesViewController = messagesViewController;
    _emojiViewController.messagesViewController = messagesViewController;
    [_sgViewController setEsgViewController:self];
}

-(void)show {
    [self.navigationViewController clear];
    [self.navigationViewController pushViewController:_emojiViewController animated:NO];
}

-(void)showSGController:(BOOL)animated {
    [self.navigationViewController pushViewController:_sgViewController animated:YES];

}

-(void)close {
    [_emojiViewController close];
    [_sgViewController close];
}

-(void)forceClose {
    [self close];
    [_epopover close];
}

+(TGModernESGViewController *)controller {
    static TGModernESGViewController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TGModernESGViewController alloc] initWithFrame:NSMakeRect(0, 0, 350, 300)];
        [instance loadViewIfNeeded];
    });
    
    return instance;
}

-(void)setEpopover:(RBLPopover *)epopover {
    _epopover = epopover;
    _emojiViewController.epopover = epopover;
}

@end
