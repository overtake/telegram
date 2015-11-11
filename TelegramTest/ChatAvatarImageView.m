//
//  ChatAvatarImageView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ChatAvatarImageView.h"
#import "ImageUtils.h"
#import "TMLoaderView.h"
#import "TGPhotoViewer.h"
@interface AvatarUpdaterItem : NSObject
@property (nonatomic, strong) UploadOperation *operation;
@property (nonatomic, strong) RPCRequest *request;
@end

@implementation AvatarUpdaterItem

@end

@interface ChatAvatarImageView()
@property (nonatomic, strong) TMLoaderView *progress;
@property (nonatomic, strong) TMView *progressContainer;
@property (nonatomic, strong) BTRButton *cancelButton;
@property (nonatomic, strong) AvatarUpdaterItem  *updaterItem;

@property (nonatomic,strong) NSImageView *editCamera;

@property (nonatomic,strong) TMView *editBlank;

@end

@implementation ChatAvatarImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.progressContainer];
        
        self.sourceType = ChatAvatarSourceGroup;
        [self setFont:TGSystemLightFont(18)];
        
        
        _editCamera = imageViewWithImage(image_EditPhotoCamera());
        
        
        
        _editBlank = [[TMView alloc] initWithFrame:self.bounds];
        
        _editBlank.wantsLayer = YES;
        _editBlank.layer.backgroundColor = [NSColor blackColor].CGColor;
        _editBlank.layer.opacity = 0.7;
        _editBlank.layer.cornerRadius = NSWidth(self.frame)/2;
        
        [self addSubview:_editBlank];
        
        [_editBlank setHidden:YES];
        
        [_editCamera setCenterByView:self];
        [self addSubview:_editCamera];
        
        [_editCamera setHidden:YES];
        
        
       
    }
    return self;
}

-(void)updateWithConversation:(TL_conversation *)conversation {
    [super updateWithConversation:conversation];
    
    switch (conversation.type) {
        case DialogTypeBroadcast:
            _sourceType = ChatAvatarSourceBroadcast;
            break;
        case DialogTypeChannel:
            _sourceType = ChatAvatarSourceChannel;
            break;
        case DialogTypeUser:
            _sourceType = ChatAvatarSourceUser;
            break;
        default:
            break;
    }
}


-(void)setEditable:(BOOL)editable {
    _editable = editable;
    
    [_editCamera setHidden:!editable];
    
    [_editBlank setHidden:!editable];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    

    // Drawing code here.
}

-(TMView *)progressContainer {
    if(self->_progressContainer)
        return self->_progressContainer;
    
    self->_progressContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height)];
    
    
    self.progressContainer.wantsLayer = YES;
    self.progressContainer.layer.masksToBounds = YES;
    self.progressContainer.layer.cornerRadius = ceil(self.frame.size.width / 2);
    self.progressContainer.layer.opacity = 0.8;
    
    [self.progressContainer setBackgroundColor:NSColorFromRGB(0x000000)];
    [self.progressContainer setHidden:YES];
    
    self.progress = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
    
    self.progress.style = TMCircularProgressDarkStyle;
    
    [self.progress setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
    
    [self.progress setState:TMLoaderViewStateUploading];
    
    [self.progress setCenterByView:self.progressContainer];

    [self.progress addTarget:self selector:@selector(cancelUploading)];
    
    
    [self.progressContainer addSubview:self.progress];
    
    return self.progressContainer;
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    
    if(self.isEditable)
    {
        [self rightMouseDown:theEvent];
        
        return;
    }
    
    PreviewObject *previewObject;
    
    if(self.sourceType == ChatAvatarSourceUser) {
        if(![self.user.photo isKindOfClass:[TL_userProfilePhotoEmpty class]] && self.user.photo != nil) {
            
            previewObject = [[PreviewObject alloc] initWithMsdId:NSIntegerMax media:[TL_photoSize createWithType:@"x" location:self.user.photo.photo_big w:640 h:640 size:0] peer_id:self.user.n_id];
            
            previewObject.reservedObject = [TGCache cachedImage:self.user.photo.photo_small.cacheKey];
            
            
            [[TGPhotoViewer viewer] show:previewObject user:self.user];
        }
    } else {
                
        if(![self.chat.photo isKindOfClass:[TL_chatPhotoEmpty class]] && self.chat.photo != nil) {
            
            
            previewObject = [[PreviewObject alloc] initWithMsdId:NSIntegerMax media:[TL_photoSize createWithType:@"x" location:self.chat.photo.photo_big w:640 h:640 size:0] peer_id:self.chat.n_id];
            
            previewObject.reservedObject = [TGCache cachedImage:self.chat.photo.photo_big.cacheKey];
            
            [[TGPhotoViewer viewer] show:previewObject];
        }
    }
    
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
        
        if(self.sourceType == ChatAvatarSourceBroadcast || self.sourceType == ChatAvatarSourceGroup  || self.sourceType == ChatAvatarSourceChannel || (self.sourceType == ChatAvatarSourceUser && self.user.type == TLUserTypeSelf)) {
            [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Profile.UpdatePhoto", nil) withBlock:^(id sender) {
                [strongSelf showUpdateChatPhotoBox];
                
            }]];
            
            if(self.fileLocation) {
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
    [pictureTaker beginPictureTakerSheetForWindow:[NSApp mainWindow] withDelegate:self didEndSelector:@selector(pictureTakerValidated:code:contextInfo:) contextInfo:nil];
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

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.progressContainer setFrameSize:newSize];
    self.progressContainer.layer.cornerRadius = newSize.width/2;
    
    [self.progress setCenterByView:self.progressContainer];
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
        
        updaterItem.request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, id response) {
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
    
    
    if(self.sourceType == ChatAvatarSourceGroup) {
        request = [TLAPI_messages_editChatPhoto createWithChat_id:lockId photo:[TL_inputChatPhotoEmpty create]];
    } else if(self.sourceType == ChatAvatarSourceChannel) {
        request = [TLAPI_channels_editPhoto createWithChannel:self.chat.inputPeer photo:[TL_inputChatPhotoEmpty create]];
    } else {
        request = [TLAPI_photos_updateProfilePhoto createWithN_id:[TL_inputPhotoEmpty create] crop:[TL_inputPhotoCropAuto create]];
    }
    
    
    if(!image) {
        if(self.sourceType == ChatAvatarSourceGroup || self.sourceType == ChatAvatarSourceChannel) {
            groupBlock();
        } else  {
            userBlock();
        } 
        
        return;
    }
    
    UploadOperation *operation = [[UploadOperation alloc] init];
    [operation setUploadComplete:^(UploadOperation *operation, id input) {
        
        
        if(self.sourceType == ChatAvatarSourceGroup) {
            request = [TLAPI_messages_editChatPhoto createWithChat_id:lockId photo:[TL_inputChatUploadedPhoto createWithFile:input crop:[TL_inputPhotoCropAuto create]]];
        } else if(self.sourceType == ChatAvatarSourceChannel) {
            request = [TLAPI_channels_editPhoto createWithChannel:self.chat.inputPeer photo:[TL_inputChatUploadedPhoto createWithFile:input crop:[TL_inputPhotoCropAuto create]]];
        } else {
            request = [TLAPI_photos_uploadProfilePhoto createWithFile:input caption:@"me" geo_point:[TL_inputGeoPointEmpty create] crop:[TL_inputPhotoCropAuto create]];
        }
        
        if(self.sourceType == ChatAvatarSourceGroup || self.sourceType == ChatAvatarSourceChannel) {
            groupBlock();
        } else {
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
