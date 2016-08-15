//
//  TGModernBottomAttachView.m
//  Telegram
//
//  Created by keepcoder on 13/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernBottomAttachView.h"
#import "MapPanel.h"
#import "TGMenuItemPhoto.h"
@interface TGModernBottomAttachView ()
@property (nonatomic,strong) BTRButton *attach;
@property (nonatomic,weak) MessagesViewController *messagesController;
@property (nonatomic, strong) TMMenuPopover *menuPopover;
@end

@implementation TGModernBottomAttachView

-(instancetype)initWithFrame:(NSRect)frameRect messagesController:(MessagesViewController *)messagesController {
    if(self = [super initWithFrame:frameRect]) {
        
        _messagesController = messagesController;
        
        
        _attach = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, image_BottomAttach().size.width, image_BottomAttach().size.height)];
        
        
        [_attach setCenterByView:self];
        
        NSImage *attach_h = [image_BottomAttach() imageTintedWithColor:BLUE_ICON_COLOR];
        
        [_attach setBackgroundImage:image_BottomAttach() forControlState:BTRControlStateNormal];
        [_attach setBackgroundImage:attach_h forControlState:BTRControlStateSelected];
        [_attach setBackgroundImage:attach_h forControlState:BTRControlStateSelected | BTRControlStateHover];
        [_attach setBackgroundImage:attach_h forControlState:BTRControlStateHighlighted];
        [_attach addTarget:self action:@selector(attachButtonPressed) forControlEvents:BTRControlEventMouseEntered];
        [_attach addTarget:self action:@selector(showMediaAttachPanel) forControlEvents:BTRControlEventMouseDownInside];
        
        [self addSubview:_attach];
        

    }
    
    return self;
}

- (void) attachButtonPressed {
    [_attach setSelected:YES];
    
    if(!self.menuPopover) {
        self.menuPopover = [[TMMenuPopover alloc] initWithMenu:self.attachMenu];
        [self.menuPopover setHoverView:_attach];
        
        if(!self.menuPopover.isShown) {
            NSRect rect = _attach.bounds;
            rect.origin.x += 80;
            rect.origin.y += 10;
            weak();
            [self.menuPopover setDidCloseBlock:^(TMMenuPopover *popover) {
                [weakSelf.attach setSelected:NO];
                weakSelf.menuPopover = nil;
            }];
            [self.menuPopover showRelativeToRect:rect ofView:_attach preferredEdge:CGRectMaxYEdge];
        }
        
    }
}

-(void)showMediaAttachPanel {
    
    self.menuPopover.animates = NO;
    
    [self.menuPopover setDidCloseBlock:^(TMMenuPopover *popover) {}];
    [self.menuPopover close];
    
    [_attach setSelected:YES];

    
    dispatch_async(dispatch_get_main_queue(),^{
        [FileUtils showPanelWithTypes:mediaTypes() completionHandler:^(NSArray *paths) {
            
            self.menuPopover = nil;
            [_attach setSelected:NO];
            
            BOOL isMultiple = [paths filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.pathExtension.lowercaseString IN (%@)",imageTypes()]].count > 1;
            
            [paths enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                
                NSString *extenstion = [[obj pathExtension] lowercaseString];
                
                if([imageTypes() indexOfObject:extenstion] != NSNotFound) {
                    [_messagesController sendImage:obj forConversation:_messagesController.conversation file_data:nil isMultiple:isMultiple addCompletionHandler:nil];
                } else {
                    [_messagesController sendVideo:obj forConversation:_messagesController.conversation];
                }
                
            }];
        }];
    });
    
}

-(NSMenu *)attachMenu {
    NSMenu *theMenu = [[NSMenu alloc] init];
    
    NSMenuItem *attachPhotoOrVideoItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Attach.PictureOrVideo", nil) withBlock:^(id sender) {
        [self showMediaAttachPanel];
    }];
    [attachPhotoOrVideoItem setImage:[image_AttachPhotoVideo() imageTintedWithColor:GRAY_ICON_COLOR]];
    [attachPhotoOrVideoItem setHighlightedImage:[image_AttachPhotoVideo() imageTintedWithColor:[NSColor whiteColor]]];
    [theMenu addItem:attachPhotoOrVideoItem];
    
    
    NSMenuItem *attachTakePhotoItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Attach.TakePhoto", nil) withBlock:^(id sender) {
        
        IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
        [pictureTaker setValue:[NSNumber numberWithBool:YES] forKey:IKPictureTakerShowEffectsKey];
        [pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(640, 640)] forKey:IKPictureTakerOutputImageMaxSizeKey];
        [pictureTaker beginPictureTakerSheetForWindow:self.window withDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
    }];
    [attachTakePhotoItem setImage:[image_AttachTakePhoto() imageTintedWithColor:GRAY_ICON_COLOR]];
    [attachTakePhotoItem setHighlightedImage:[image_AttachTakePhoto() imageTintedWithColor:[NSColor whiteColor]]];
    [theMenu addItem:attachTakePhotoItem];
    
    weak();
    
    NSMenuItem *attachLocationItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Attach.Location", nil) withBlock:^(id sender) {
        
        MapPanel *panel = [MapPanel sharedPanel];
        panel.messagesViewController = weakSelf.messagesController;
        [panel update];
        
        [self.window beginSheet:panel completionHandler:^(NSModalResponse returnCode) {
            
        }];
        
    }];
    
    [attachLocationItem setImage:[image_AttachLocation() imageTintedWithColor:GRAY_ICON_COLOR]];
    [attachLocationItem setHighlightedImage:[image_AttachLocation() imageTintedWithColor:[NSColor whiteColor]]];
    
    
    if(_messagesController.conversation.type != DialogTypeSecretChat && floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_9) {
        [theMenu addItem:attachLocationItem];
    }
    
    NSMenuItem *attachFileItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Attach.File", nil) withBlock:^(id sender) {
        [FileUtils showPanelWithTypes:nil completionHandler:^(NSArray *paths) {
            
            [paths enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                [self.messagesController sendDocument:obj forConversation:_messagesController.conversation];
            }];
            
        }];
    }];
    [attachFileItem setImage:[image_AttachFile() imageTintedWithColor:GRAY_ICON_COLOR]];
    [attachFileItem setHighlightedImage:[image_AttachFile() imageTintedWithColor:[NSColor whiteColor]]];
    
    
    [theMenu addItem:attachFileItem];
    
    if(_messagesController.conversation.type != DialogTypeSecretChat) {
        __block NSMutableArray *top;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            top = [[transaction objectForKey:@"categories" inCollection:TOP_PEERS] mutableCopy];
            
        }];
        
        
        [top enumerateObjectsUsingBlock:^(TL_topPeerCategoryPeers *obj, NSUInteger cidx, BOOL * _Nonnull stop) {
            
            if([obj.category isKindOfClass:[TL_topPeerCategoryBotsInline class]]) {
                
                [obj.peers enumerateObjectsUsingBlock:^(TL_topPeer *peer, NSUInteger idx, BOOL *stop) {
                    
                    TLUser *user = [[UsersManager sharedManager] find:peer.peer.user_id];
                    
                    NSMenuItem *botMenuItem = [NSMenuItem menuItemWithTitle:[NSString stringWithFormat:@"@%@",user.username] withBlock:^(id sender) {
                        
                        open_link_with_controller([NSString stringWithFormat:@"chat://viabot/?username=@%@",user.username],weakSelf.messagesController.navigationViewController);
                        
                    }];
                    
                   __unused TGMenuItemPhoto *unuse = [[TGMenuItemPhoto alloc] initWithUser:user menuItem:botMenuItem];
                    
                    
                    [theMenu addItem:botMenuItem];
                    
                }];
                
                *stop = YES;
            }
            
        }];
    }
    
    
    
    return theMenu;
}


- (void) pictureTakerValidated:(IKPictureTaker*) pictureTaker code:(int) returnCode contextInfo:(void*) ctxInf {
    if(returnCode == NSOKButton){
        NSImage *outputImage = [pictureTaker outputImage];
        [_messagesController sendImage:nil forConversation:_messagesController.conversation file_data:[outputImage TIFFRepresentation]];
    }
}

@end
