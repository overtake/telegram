//
//  TGSModalSenderView.m
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSModalSenderView.h"
#import "UploadOperation.h"
#import "ImageUtils.h"
#import "NSViewCategory.h"
#import "TGLinearProgressView.h"



@interface TGSModalSenderView ()
{
    int _ts_count;
    int _cs_count;
    int _sent_count;
    NSMutableArray *_operationsAndRequests;
    NSMutableDictionary *_uploadedFileHash;
}
@property (nonatomic,strong) TMView *backgroundView;
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,copy) dispatch_block_t completionHandler;
@property (nonatomic,copy) dispatch_block_t errorHandler;
@property (nonatomic,strong) NSArray *rowItems;
@property (nonatomic,strong) TGLinearProgressView *progressView;

@property (nonatomic,strong) NSTextField *sharingTextField;



@end

@implementation TGSModalSenderView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _backgroundView = [[TMView alloc] initWithFrame:frameRect];
        
        _backgroundView.wantsLayer = YES;
        _backgroundView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        _backgroundView.layer.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.2).CGColor;
        
        
        _containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, 260, 100)];
        
        _containerView.wantsLayer = YES;
        _containerView.layer.backgroundColor = [NSColor whiteColor].CGColor;
        _containerView.layer.cornerRadius = 4;
        _containerView.layer.borderColor = DIALOG_BORDER_COLOR.CGColor;
        
        [_containerView setCenterByView:self];
        
        [self addSubview:_backgroundView];
        
        
        [self addSubview:_containerView];
        
        
        _sharingTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_containerView.frame) - 20, 20)];
        
        [_sharingTextField setCenterByView:_containerView];
        
        [_sharingTextField setEditable:NO];
        [_sharingTextField setSelectable:NO];
        [_sharingTextField setDrawsBackground:NO];
        [_sharingTextField setBordered:NO];
        [_sharingTextField setAlignment:NSCenterTextAlignment];
        
        [_sharingTextField setFont:TGSystemFont(13)];
        
        [_sharingTextField setStringValue:@"Sharing..."];
        
        [_sharingTextField setFrameOrigin:NSMakePoint(NSMinX(_sharingTextField.frame), NSHeight(_containerView.frame) - 30)];
        
        [_containerView addSubview:_sharingTextField];
        
        _progressView = [[TGLinearProgressView alloc] initWithFrame:NSMakeRect(0, 30, NSWidth(_containerView.frame), 3)];
        
        
        [_progressView setCenterByView:_containerView];
        
        [_containerView addSubview:_progressView];
        
        
    }
    
    return self;
}


-(void)sendItems:(NSArray *)shareItems rowItems:(NSArray *)rowItems completionHandler:(dispatch_block_t)completionHandler errorHandler:(dispatch_block_t)errorHandler {
    
    _completionHandler = completionHandler;
    _errorHandler = errorHandler;
    _rowItems = rowItems;
    
    _uploadedFileHash = [[NSMutableDictionary alloc] init];
    _operationsAndRequests = [[NSMutableArray alloc] init];
    
    
    NSExtensionItem *obj = shareItems.firstObject;
    
    _ts_count = (int) obj.attachments.count * (int) rowItems.count;
    
    
    [obj.attachments enumerateObjectsUsingBlock:^(NSItemProvider *itemProvider, NSUInteger idx, BOOL *stop) {
            
        if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
            [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                
                [_rowItems enumerateObjectsUsingBlock:^(id rowItem, NSUInteger idx, BOOL *stop) {
                    
                    if(![url isFileURL]) {
                        [self sendAsMessage:url.absoluteString rowItem:rowItem];
                    } else {
                        [self sendAsMedia:url.path rowItem:rowItem];
                    }
                    
                }];
                    
            }];
        }
            
    }];

}

-(void)update {
    if(_ts_count == _sent_count) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _completionHandler();
        });
    }
}

-(void)error {
    [self cleanup];
    
    _errorHandler();
}

-(void)cleanup {
    [_operationsAndRequests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[TGS_RPCRequest class]]) {
            [obj cancelRequest];
        } else if([obj isKindOfClass:[UploadOperation class]]) {
            [obj cancel];
        }
        
    }];
    
    [_operationsAndRequests removeAllObjects];
}

-(void)cancel {
    
    [self cleanup];
    
    _completionHandler();
}

-(void)updateProgress:(int)progress {
    
    assert([NSThread isMainThread]);
    
    int part_progress = ceil(100/_ts_count);
    
    int current_progress = (part_progress * _cs_count)+ (progress / 100 * part_progress);
    
    [_progressView setProgress:current_progress animated:YES];
}

-(void)sendAsMedia:(NSString *)path rowItem:(TGS_ConversationRowItem *)rowItem {
    
    [ASQueue dispatchOnStageQueue:^{
       
        UploadOperation *operation = [[UploadOperation alloc] init];
        
        
        [operation setUploadComplete:^(UploadOperation *operation, id file) {
            
            
            _cs_count++;
            
            id media;
            
            if(operation.uploadType == UploadImageType)
                media = [TL_inputMediaUploadedPhoto createWithFile:file caption:@""];
            else
                media = [TL_inputMediaUploadedDocument createWithFile:file mime_type:mimetypefromExtension([path pathExtension]) attributes:[@[[TL_documentAttributeFilename createWithFile_name:[path lastPathComponent]]] mutableCopy]];
            
            id request = [TGS_RPCRequest sendRequest:[TLAPI_messages_sendMedia createWithFlags:0 peer:[self inputPeer:rowItem] reply_to_msg_id:0 media:media random_id:rand_long()] successHandler:^(id request, id response) {
                
                _sent_count++;
                
                [self update];
                
            } errorHandler:^(id request, RpcError *error) {
                [self error];
            }];
            
            [_operationsAndRequests addObject:request];
            
        }];
        
        [operation setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
            [self updateProgress:(int)current/(int)total*100];
        }];
        
        if([imageTypes() indexOfObject:[path pathExtension]] != NSNotFound && fileSize(path) <= 10*1014*1024) {
            
            NSImage *originImage = imageFromFile(path);
            
            originImage = prettysize(originImage);
            
             if(originImage.size.width / 10 > originImage.size.height) {
                
                 [operation setFilePath:path];
                 [operation ready:UploadDocumentType];
                 
                return;
            }
            
            originImage = strongResize(originImage, 1280);
            
            NSData *imageData = jpegNormalizedData(originImage);
            
            [operation setFileData:imageData];
            
            [operation ready:UploadImageType];
            
        } else {
            [operation setFilePath:path];
            [operation ready:UploadDocumentType];
        }
        
        [_operationsAndRequests addObject:operation];

    }];
    
}

-(void)sendAsMessage:(NSString *)message rowItem:(TGS_ConversationRowItem *)rowItem {
    
    
    [self updateProgress:30];
    
    id request = [TGS_RPCRequest sendRequest:[TLAPI_messages_sendMessage createWithFlags:0 peer:[self inputPeer:rowItem] reply_to_msg_id:0 message:message random_id:rand_long()] successHandler:^(TGS_RPCRequest *request, id response) {
        
        _cs_count++;
        
        _sent_count++;
        
        [self updateProgress:100];
        
        [self update];
        
    } errorHandler:^(TGS_RPCRequest *request, RpcError *error) {
        
        [self error];
    }];
    
    [_operationsAndRequests addObject:request];
}


-(id)inputPeer:(TGS_ConversationRowItem *)rowItem {
    
    id input;
    if(rowItem.chat.n_id != 0) {
        input = [TL_inputPeerChat createWithChat_id:rowItem.chat.n_id];
    } else {
        
        if([rowItem.user isKindOfClass:[TL_userContact class]]) {
            input = [TL_inputPeerContact createWithUser_id:rowItem.user.n_id];
        } else if([rowItem.user isKindOfClass:[TL_userDeleted class]] || [rowItem.user isKindOfClass:[TL_userEmpty class]]) {
            input = [TL_inputPeerEmpty create];
        } else if([rowItem.user isKindOfClass:[TL_userForeign class]] || [rowItem.user isKindOfClass:[TL_userRequest class]]) {
            input = [TL_inputPeerForeign createWithUser_id:rowItem.user.n_id access_hash:rowItem.user.access_hash];
        } else if([rowItem.user isKindOfClass:[TL_userSelf class]]) {
            input = [TL_inputPeerSelf create];
        }
    }
    if(!input)
        return [TL_inputPeerEmpty create];
    return input;
}




@end
