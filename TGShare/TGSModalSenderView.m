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
#import "BTRButton.h"
#import "ShareViewController.h"

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


@property (nonatomic,strong) BTRButton *cancelButton;
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
        
        
        _cancelButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_containerView.frame), 50)];
        
        _cancelButton.layer.backgroundColor = [NSColor whiteColor].CGColor;
        
        [_cancelButton setTitleColor:LINK_COLOR forControlState:BTRControlStateNormal];
        
        [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forControlState:BTRControlStateNormal];
        
        
        weak();
        
        [_cancelButton addBlock:^(BTRControlEvents events) {
            
            [weakSelf cleanup];
            
            [ShareViewController close];
            
            
        } forControlEvents:BTRControlEventClick];
        
        
        TMView *topSeparator = [[TMView alloc] initWithFrame:NSMakeRect(0, 49, NSWidth(_containerView.frame), DIALOG_BORDER_WIDTH)];
        
        topSeparator.backgroundColor = DIALOG_BORDER_COLOR;
        
        
        
        [self.containerView addSubview:_cancelButton];
        
        [self.containerView addSubview:topSeparator];
        
        
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
    
    
    if(obj.attributedContentText.length > 0) {
        
        _ts_count+= 1 * (int) rowItems.count;
        
        [_rowItems enumerateObjectsUsingBlock:^(id rowItem, NSUInteger idx, BOOL *stop) {
            [self sendAsMessage:obj.attributedContentText.string rowItem:rowItem];
        }];
    }
    
    
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
        
        [self.progressView setProgress:100 animated:YES];
        
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

-(void)performMediaRequest:(id)media rowItem:(TGS_ConversationRowItem *)rowItem path:(NSString *)path {
   
    _cs_count++;
    
    id request = [TGS_RPCRequest sendRequest:[TLAPI_messages_sendMedia createWithFlags:0 peer:[self inputPeer:rowItem] reply_to_msg_id:0 media:media random_id:rand_long() reply_markup:nil] successHandler:^(id request, TLUpdates *response) {
        
        _sent_count++;
        
        [self update];
        
    } errorHandler:^(id request, RpcError *error) {
        [self error];
    }];
    
    [_operationsAndRequests addObject:request];
}


-(void)sendAsMedia:(NSString *)path rowItem:(TGS_ConversationRowItem *)rowItem {
    
    [ASQueue dispatchOnStageQueue:^{
       
        UploadOperation *operation = [[UploadOperation alloc] init];
        
        
        [operation setUploadComplete:^(UploadOperation *operation, id file) {
            
            [self updateProgress:100];
            
            id media;
            
            if(operation.uploadType == UploadImageType)
                media = [TL_inputMediaUploadedPhoto createWithFile:file caption:@""];
            else
                media = [TL_inputMediaUploadedDocument createWithFile:file mime_type:mimetypefromExtension([path pathExtension]) attributes:[@[[TL_documentAttributeFilename createWithFile_name:[path lastPathComponent]]] mutableCopy]];
            
            [self performMediaRequest:media rowItem:rowItem path:path];
            
        }];
        
        [operation setUploaderRequestFileHash:^id(UploadOperation *o) {
            
            return _uploadedFileHash[fileMD5(o.filePath)];
            
        }];
        
        [operation setUploaderNeedSaveFileHash:^(UploadOperation *o, id file) {
            _uploadedFileHash[fileMD5(o.filePath)] = file;
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
    
    [ASQueue dispatchOnMainQueue:^{
        [self updateProgress:30];
    }];
    
    id request = [TGS_RPCRequest sendRequest:[TLAPI_messages_sendMessage createWithFlags:0 peer:[self inputPeer:rowItem] reply_to_msg_id:0 message:message random_id:rand_long() reply_markup:nil entities:nil] successHandler:^(TGS_RPCRequest *request, id response) {
        
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
        
        return [TL_inputPeerUser createWithUser_id:rowItem.user.n_id access_hash:rowItem.user.access_hash];
        
    }
    if(!input)
        return [TL_inputPeerEmpty create];
    return input;
}




@end
