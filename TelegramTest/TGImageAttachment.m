//
//  TGImageAttachment.m
//  Telegram
//
//  Created by keepcoder on 20.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGImageAttachment.h"
#import "TGImageAttachmentsController.h"
#import "TMLoaderView.h"
@interface TGImageAttachment ()<TGAttachDelegate>
@property (nonatomic,strong) BTRButton *close;
@property (nonatomic,strong) BTRImageView *imageView;
@property (nonatomic,strong) NSProgressIndicator *progress;


@property (nonatomic, strong) TMLoaderView *loaderView;
@property (nonatomic, strong) TMView *progressContainer;

@property (nonatomic, strong) BTRButton *captionButton;

@property (nonatomic, assign) BOOL acceptDelete;

@property (nonatomic, strong) TMView *captionBackground;

@end

@implementation TGImageAttachment

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(id)initWithItem:(TGAttachObject *)attach {
    if(self = [self initWithFrame:NSMakeRect(0, 0, 68, 68)]) {
        _item = attach;
        _item.delegate = self;
    }
    
    return self;
}

-(void)didFailGenerateAttach {
    
}

-(void)didSuccessGenerateAttach {
    
}

-(void)dealloc {
    assert([NSThread isMainThread]);
}



//NSImage *captedImage() {
//    
//    static NSImage *image;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        NSRect rect = NSMakeRect(0, 0, 25, 15);
//        image = [[NSImage alloc] initWithSize:rect.size];
//        [image lockFocus];
//        
//        [NSColorFromRGBWithAlpha(0x000000, 0.7) set];
//        NSBezierPath *path = [NSBezierPath bezierPath];
//        
//        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:4 yRadius:4];
//        [path fill];
//        
//        NSString *str = @"...";
//        
//        [str drawAtPoint:NSMakePoint(6, 2) withAttributes:@{NSFontAttributeName:TGSystemFont(15),NSForegroundColorAttributeName:[NSColor whiteColor]}];
//        
//        [image unlockFocus];
//        
//    });
//    
//    return image;
//    
//}
//
//
//NSImage *addCaptionImage() {
//    static NSImage *image;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        
//        NSRect rect = NSMakeRect(0, 0, 20, 20);
//        image = [[NSImage alloc] initWithSize:rect.size];
//        [image lockFocus];
//        
//        [NSColorFromRGBWithAlpha(0x000000, 0.8) set];
//        NSBezierPath *path = [NSBezierPath bezierPath];
//        
//        
//        
//        [path appendBezierPathWithRoundedRect:NSMakeRect(0, 0, rect.size.width, rect.size.height) xRadius:roundf(rect.size.width/2) yRadius:roundf(rect.size.height/2)];
//        [path fill];
//        
//        
//        
//        [NSColorFromRGBWithAlpha(0xffffff, 1) set];
//        
//        
//        path = [NSBezierPath bezierPath];
//        
//        [path appendBezierPathWithRoundedRect:NSMakeRect(9, 4, 2, 12) xRadius:2 yRadius:1];
//       // [path fill];
//        
//        
//        [path appendBezierPathWithRoundedRect:NSMakeRect(4, 9, 12, 2) xRadius:2 yRadius:2];
//        [path fill];
//        
//        
//        [image unlockFocus];
//        
//    });
//    
//    return image;
//}

-(void)didStartUploading:(UploadOperation *)uploader {
    
    
    [_captionButton setHidden:YES];
    
    assert([NSThread isMainThread]);
    
    [self.progressContainer setAlphaValue:0];
    
    [self.progressContainer setHidden:NO];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [[self.progressContainer animator] setAlphaValue:1];
        
    } completionHandler:^{}];
    
    [_loaderView setProgress:5 animated:YES];
    
    [uploader setUploadProgress:^(UploadOperation *operation, NSUInteger current, NSUInteger total) {
        
        [ASQueue dispatchOnMainQueue:^{
            [_loaderView setProgress:MAX(5, ((float)current/(float)total) * 100.0f ) animated:YES];
        }];
    }];
    
}

-(void)didEndUploading:(UploadOperation *)uploader {
    
    [_captionButton setHidden:!_acceptDelete];
    
    assert([NSThread isMainThread]);
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [[self.progressContainer animator] setAlphaValue:0];
        
    } completionHandler:^{
        [self.progressContainer setHidden:YES];
        [_loaderView setCurrentProgress:0];
    }];
    
    
    
    
}

static CAAnimation *thumbAnimation() {
    static CAAnimation *animation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.duration = .2;
    });
    return animation;
}

-(void)didSuccessGeneratedThumb:(NSImage *)thumb {
    
    [self setDeleteAccept:_acceptDelete];
    
    assert([NSThread isMainThread]);
    
    [_imageView addAnimation:thumbAnimation() forKey:@"contents"];
    
    [_imageView setImage:thumb];
    
    _imageView.layer.cornerRadius = 0;
    _imageView.layer.borderWidth = 0;
    _imageView.layer.borderColor = [NSColor clearColor].CGColor;
    
    [_progress setHidden:YES];
    [_progress stopAnimation:self];
    
    
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.wantsLayer = YES;
        
        _close = [[BTRButton alloc] initWithFrame:NSMakeRect(NSWidth(frameRect) - image_RemoveSticker().size.width, NSHeight(frameRect) - image_RemoveSticker().size.height, image_RemoveSticker().size.width , image_RemoveSticker().size.height)];
        
        
        [_close setImage:image_RemoveSticker() forControlState:BTRControlStateNormal];
        [_close setImage:image_RemoveStickerActive() forControlState:BTRControlStateHighlighted];
        
        weak();
        
        [_close addBlock:^(BTRControlEvents events) {
            
            [weakSelf.controller removeItem:weakSelf animated:YES];
            
        } forControlEvents:BTRControlEventClick];
        
        _imageView = [[BTRImageView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(frameRect) - image_RemoveSticker().size.width/2, NSHeight(frameRect) - image_RemoveSticker().size.height/2)];
        
        _imageView.layer.backgroundColor = [NSColor clearColor].CGColor;
        _imageView.cornerRadius = 4;
        _imageView.layer.cornerRadius = 4;
        _imageView.layer.borderWidth = 1;
        _imageView.layer.borderColor = GRAY_BORDER_COLOR.CGColor;
        
        [self addSubview:_imageView];
        
        [self addSubview:_close];
        
        
        _progress = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 25, 25)];
        
        [_progress setStyle:NSProgressIndicatorSpinningStyle];
        
        [_progress setCenterByView:_imageView];
        
        
        [self addSubview:_progress];
        
        
        [self.progressContainer setCenterByView:_imageView];
        [_imageView addSubview:self.progressContainer];
        
        [self.progressContainer setHidden:YES];
        
        
        
        _captionBackground = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_imageView.frame), 20)];
        
        
        _captionBackground.wantsLayer = YES;
        _captionBackground.layer.backgroundColor = NSColorFromRGBWithAlpha(0x000000, 0.8).CGColor;
        //_captionBackground.layer.cornerRadius = 4;
        
        
        [_imageView.currentLayer addSublayer:_captionBackground.layer];
        
        _imageView.cornerRadius = 4;
        
        _captionButton = [[BTRButton alloc] initWithFrame:NSMakeRect(0, 2, NSWidth(_imageView.frame), 20)];
        
        [_captionButton setTitle:NSLocalizedString(@"AddCaption", nil) forControlState:BTRControlStateNormal];
        [_captionButton setTitleColor:NSColorFromRGBWithAlpha(0xffffff, 1) forControlState:BTRControlStateNormal];
        [_captionButton setTitleFont:TGSystemFont(11) forControlState:BTRControlStateNormal];
        
        dispatch_block_t block = ^{
            [self mouseUp:[NSApp currentEvent]];
        };
        
        [_captionButton addBlock:^(BTRControlEvents events) {
            
            block();
            
        } forControlEvents:BTRControlEventClick];
        
        [_captionButton setAlphaValue:0.8];
        
        [_captionButton setOpacityHover:YES];
        [self addSubview:_captionButton];
        
    }
    
    return self;
}


-(TMView *)progressContainer {
    if(self->_progressContainer)
        return self->_progressContainer;
    
    self->_progressContainer = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(_imageView.frame), NSHeight(_imageView.frame))];
    
    
    self.progressContainer.wantsLayer = YES;
    self.progressContainer.layer.masksToBounds = YES;
    self.progressContainer.layer.cornerRadius = 4;
    self.progressContainer.layer.opacity = 0.7;
    
    [self.progressContainer setBackgroundColor:NSColorFromRGB(0x000000)];
    
    _loaderView = [[TMLoaderView alloc] initWithFrame:NSMakeRect(0, 0, 40, 40)];
    
    _loaderView.style = TMCircularProgressDarkStyle;
    
    [_loaderView setCurrentProgress:5];
    [_loaderView setProgress:5 animated:YES];
    
    [_loaderView setImage:image_LoadCancelWhiteIcon() forState:TMLoaderViewStateUploading];
    
    [_loaderView setState:TMLoaderViewStateUploading];
    
    [_loaderView setCenterByView:self.progressContainer];
    
    [_loaderView addTarget:self selector:@selector(cancelUploading)];
    
    [self.progressContainer addSubview:_loaderView];
    
    return self.progressContainer;
    
}

-(void)setDeleteAccept:(BOOL)accept {
    
    _acceptDelete = accept;
    
    [_close setHidden:!accept];
    [_captionButton setHidden:!accept || _item.thumb == nil];
    [_captionBackground setHidden:!accept || _item.thumb == nil];
    
    [_captionButton setTitle:_item.caption.length > 0 ? _item.caption : NSLocalizedString(@"AddAttachmentCaption", nil) forControlState:BTRControlStateNormal];
    
    [_captionButton setOpacityHover:_item.caption.length == 0];
    
}

-(void)cancelUploading {
    [self.controller removeItem:self animated:YES];
}

-(void)loadImage {
    
    if(_item.thumb) {
        [_imageView setImage:_item.thumb];
    } else {
        [_progress setHidden:NO];
        [_close setHidden:YES];
        [_progress startAnimation:self];
    }
    
    [_loaderView setCurrentProgress:0];
    
    if(_item.uploader) {
        [self didStartUploading:_item.uploader];
    }
    
    [_captionButton setTitle:_item.caption.length > 0 ? _item.caption : NSLocalizedString(@"AddAttachmentCaption", nil) forControlState:BTRControlStateNormal];
    
    [_captionButton setOpacityHover:_item.caption.length == 0];

   
    [_item prepare];
    
}



@end
