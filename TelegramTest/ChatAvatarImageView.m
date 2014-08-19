//
//  ChatAvatarImageView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatAvatarImageView.h"
#import "ImageUtils.h"
#import "TMCircularProgress.h"

@interface AvatarUpdaterItem : NSObject
@property (nonatomic, strong) UploadOperation *operation;
@property (nonatomic, strong) RPCRequest *request;
@end

@implementation AvatarUpdaterItem

@end

@interface ChatAvatarImageView()
@property (nonatomic, strong) TMCircularProgress *progress;
@property (nonatomic, strong) TMView *progressContainer;
@property (nonatomic, strong) BTRButton *cancelButton;
@property (nonatomic, strong) AvatarUpdaterItem  *updaterItem;
@end

@implementation ChatAvatarImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.progressContainer];
        
        self.sourceType = ChatAvatarSourceGroup;
        
        
//        [self.progressContainer.layer setNeedsDisplay];
//        [self.progressContainer.layer display];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    

    // Drawing code here.
}

-(TMView *)progressContainer {
    if(self->_progressContainer)
        return self->_progressContainer;
    
    self->_progressContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height)];
    
    
    self.progressContainer.wantsLayer = YES;
    self.progressContainer.layer.masksToBounds = YES;
    self.progressContainer.layer.cornerRadius = ceil(self.bounds.size.width / 2);

    
    [self.progressContainer setBackgroundColor:NSColorFromRGB(0x000000)];
    [self.progressContainer setHidden:YES];
    
    self.progress = [[TMCircularProgress alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
    
    self.progress.style = TMCircularProgressLightStyle;
    
    [self.progress setCenterByView:self.progressContainer];
    
    weakify();
    [self.progress setCancelCallback:^{
        [strongSelf cancelUploading];
    }];
    
    
    [self.progressContainer addSubview:self.progress];
    
    

    
    return self.progressContainer;
    
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    [super rightMouseDown:theEvent];
    
    NSMenu *menu = [[NSMenu alloc] init];
    weakify();

    if(self.updaterItem) {
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Profile.CancelPhotoUpload", nil) withBlock:^(id sender) {
            [strongSelf cancelUploading];
            
        }]];
    } else {
        
        if(self.sourceType == ChatAvatarSourceBroadcast || self.sourceType == ChatAvatarSourceGroup || (self.sourceType == ChatAvatarSourceUser && self.user.type == TGUserTypeSelf)) {
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Profile.UpdatePhoto", nil) withBlock:^(id sender) {
                [strongSelf showUpdateChatPhotoBox];
                
            }]];
            
            if(self.fileLocationSmall) {
                [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Profile.RemovePhoto", nil) withBlock:^(id sender) {
                    [strongSelf updateChatPhoto:nil];
                    
                }]];
            }
        }
        
        
        
    }
   
    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
}

- (void)showUpdateChatPhotoBox {
    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    //  [pictureTaker setType:TMImagePickerWebSearchDefaultSelection];
    //    IKPictureTaker *pictureTaker = [IKPictureTaker pictureTaker];
    [pictureTaker setValue:[NSNumber numberWithBool:YES] forKey:IKPictureTakerShowEffectsKey];
    [pictureTaker setValue:[NSValue valueWithSize:NSMakeSize(640, 640)] forKey:IKPictureTakerOutputImageMaxSizeKey];
    [pictureTaker beginPictureTakerSheetForWindow:[[NSApp delegate] mainWindow] withDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
}

- (void) pictureTakerValidated:(IKPictureTaker*) pictureTaker code:(int) returnCode contextInfo:(void*) ctxInf {
    if(returnCode == NSOKButton){
        NSImage *outputImage = [pictureTaker outputImage];
        if(outputImage.size.width < 100 || outputImage.size.height < 100) {
            alert(NSLocalizedString(@"Profile.SmallPhoto", nil), NSLocalizedString(@"App.MinPhotoSize", nil));
            return;
        }
        
        [self updateChatPhoto:outputImage];
    }
}

- (void)rebuild {
    AvatarUpdaterItem *operation = [lockDictionary() objectForKey:@(self.controller.chat.n_id)];
    if(operation) {
        [self startUploading:operation withAnimation:NO];
    } else {
        [self.progressContainer setHidden:YES];
        self.updaterItem = nil;
    }
}

- (void)calcProgress {
    if(!self.updaterItem) {
        [self.progress setProgress:0 animated:NO];
        return;
    }
    
    if(self.updaterItem.operation.uploadState == UploadFinished) {
        if(!self.updaterItem.request.response) {
            [self.progress setProgress:75 animated:YES];
        } else {
            [self.progress setProgress:90 animated:YES];
        }
    } else {
        [self.progress setProgress:0 animated:NO];
    }
}

-(int)lockId {
    return self.sourceType == ChatAvatarSourceUser ? self.user.n_id : self.chat.n_id;
}

- (void)startUploading:(AvatarUpdaterItem *)updateItem withAnimation:(BOOL)isAnimation {
    [lockDictionary() setObject:updateItem forKey:@([self lockId])];
    
    [self calcProgress];
    
    
    self.updaterItem = updateItem;
    [self.progressContainer setHidden:NO];
    
//    self.progressContainer.wantsLayer = NO;
//    [self.progressContainer prepareForAnimation];
    
    self.progressContainer.layer.masksToBounds = YES;
    self.progressContainer.layer.cornerRadius = ceil(self.bounds.size.width / 2.0);
//    [self.progressContainer.layer setNeedsDisplay];
//    [self.progressContainer.layer display];
    
    
    if(isAnimation) {
        [self.progressContainer setAnimation:[TMAnimations fadeWithDuration:0.4 fromValue:0 toValue:0.8] forKey:@"opacity"];
    } else {
        [self.progressContainer.layer setOpacity:0.8];
    }
}

- (void)endUploading {
    [lockDictionary() removeObjectForKey:@([self lockId])];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.progressContainer setHidden:YES];
    }];
    [self.progressContainer setAnimation:[TMAnimations fadeWithDuration:0.4 fromValue:0.8 toValue:0] forKey:@"opacity"];
    [CATransaction commit];
}

- (void)setImage:(NSImage *)image {
    [super setImage:image];
    
    if(self.updaterItem && self.updaterItem.operation.uploadState == UploadFinished) {
        [self endUploading];
        self.updaterItem = nil;
    }
}


- (void)cancelUploading {
    [lockDictionary() removeObjectForKey:@([self lockId])];
    [self.updaterItem.operation cancel];
    [self.updaterItem.request cancelRequest];
    [self endUploading];
    self.updaterItem = nil;
}

- (void)updateChatPhoto:(NSImage *)image {
    __block id request = nil;
    __block int lockId = [self lockId];
    __block AvatarUpdaterItem *updaterItem = nil;
    
    weakify();
    
    dispatch_block_t groupBlock = ^{
        [strongSelf calcProgress];
        
        updaterItem.request = [MessageSender sendStatedMessage:request successHandler:^(RPCRequest *request, id response) {
            if([self lockId] == lockId) {
                [strongSelf calcProgress];
            }
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            if([self lockId] == lockId) {
                [strongSelf cancelUploading];
            }
        }];
    };
    
    dispatch_block_t userBlock = ^{
        [strongSelf calcProgress];
        
        updaterItem.request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
            
            [SharedManager proccessGlobalResponse:response];
            
            if([self lockId] == lockId) {
                [strongSelf calcProgress];
            }
            
        } errorHandler:^(RPCRequest *request, RpcError *error) {
           
            if([self lockId] == lockId) {
                [strongSelf cancelUploading];
            }
        
        } timeout:10];
    };
    
    
    if(!image) {
        if(self.sourceType == ChatAvatarSourceGroup) {
            request = [TLAPI_messages_editChatPhoto createWithChat_id:lockId photo:[TL_inputChatPhotoEmpty create]];
            groupBlock();
        } else {
            request = [TLAPI_photos_updateProfilePhoto createWithN_id:[TL_inputPhotoEmpty create] crop:[TL_inputPhotoCropAuto create]];
            userBlock();
        }
        
        return;
    }
    
    UploadOperation *operation = [[UploadOperation alloc] init];
    [operation setUploadComplete:^(UploadOperation *operation, id input) {
        if(self.sourceType == ChatAvatarSourceGroup) {
            request = [TLAPI_messages_editChatPhoto createWithChat_id:lockId photo:[TL_inputChatUploadedPhoto createWithFile:input crop:[TL_inputPhotoCropAuto create]]];
            groupBlock();
        } else {
            request = [TLAPI_photos_uploadProfilePhoto createWithFile:input caption:@"me" geo_point:[TL_inputGeoPointEmpty create] crop:[TL_inputPhotoCropAuto create]];
            userBlock();
        }
    }];
    
    [operation setFileData:compressImage([image TIFFRepresentation], 0.7)];
    [operation ready:UploadImageType];
    
    updaterItem = [[AvatarUpdaterItem alloc] init];
    updaterItem.operation = operation;
    [self startUploading:updaterItem withAnimation:YES];
}

static NSMutableDictionary *lockDictionary() {
    static NSMutableDictionary *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSMutableDictionary alloc] init];
    });
    return instance;
}

@end
