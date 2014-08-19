//
//  NotSelectedDialogsViewController.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/28/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NotSelectedDialogsViewController.h"
#import "TMGifImageView.h"
#import <AVFoundation/AVFoundation.h>

@interface NotSelectedDialogsViewController()
@end

@implementation NotSelectedDialogsViewController

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.isNavigationBarHidden = YES;
    }
    return self;
}

- (void) loadView {
    [super loadView];
    
    [self.view setWantsLayer:YES];
    
    NSView *containerView = [[NSView alloc] init];
    [self.view addSubview:containerView];

    
    NSImage *noDialogsImage = image_noDialogs();
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, noDialogsImage.size.width, noDialogsImage.size.height)];
    [imageView setWantsLayer:YES];
    imageView.image = noDialogsImage;
    [containerView addSubview:imageView];

    
    TMTextField *textField = [[TMTextField alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];
    [textField setEditable:NO];
    [textField setBordered:NO];
    [textField setSelectable:NO];
    NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
    [mutParaStyle setAlignment:NSCenterTextAlignment];
    [mutParaStyle setLineSpacing:3];
    [textField setAttributedStringValue:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Conversation.SelectConversation", nil) attributes:@{NSForegroundColorAttributeName: BLUE_UI_COLOR, NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:14], NSParagraphStyleAttributeName: mutParaStyle}]];
    [textField sizeToFit];
    [imageView setFrameOrigin:NSMakePoint(roundf((textField.frame.size.width - imageView.frame.size.width) / 2), textField.frame.size.height + 20)];
    

    [containerView addSubview:textField];
    
    [containerView setFrameSize:NSMakeSize(textField.frame.size.width, textField.frame.size.height + imageView.frame.size.height + imageView.frame.origin.y - textField.frame.size.height)];
    [containerView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinYMargin];
    [containerView setFrameOrigin:NSMakePoint(roundf((self.view.bounds.size.width - containerView.frame.size.width) / 2), roundf((self.view.bounds.size.height - containerView.frame.size.height) / 2))];
    [self.view setAutoresizesSubviews:YES];

    
    
//    id object = [[NSClassFromString(@"IKImageCropView") alloc] init];
//    BTRImage *image = [BTRImage animatedImage:@"5_14"];
//    [self createMovieFromGif:image];
//    [object setImage:image];
//    [self.view addSubview:object];
    
//    TMGifImageView *gifImageView = [[TMGifImageView alloc] init];
//    [gifImageView setFrameSize:NSMakeSize(320, 320)];
//    [gifImageView setImageWithURL:[NSURL fileURLWithPath:@"/Users/dmitry/Downloads/IMG_0283.GIF"] force:YES];
//    [self.view addSubview:gifImageView];
}

//- (void)createMovieFromGif:(BTRImage *)gifImage {
//    NSError *error = nil;
//    NSURL *fileUrl = [NSURL fileURLWithPath:@"/Users/dmitry/test2.mp4"];
//    
//    [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:NULL];
//    
//    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:fileUrl fileType:AVFileTypeQuickTimeMovie error:&error];
//    NSParameterAssert(videoWriter);
//    
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   AVVideoCodecH264, AVVideoCodecKey,
//                                   @(gifImage.size.width), AVVideoWidthKey,
//                                   @(gifImage.size.height), AVVideoHeightKey,
//                                   nil];
//    AVAssetWriterInput *videoWriterInput = [AVAssetWriterInput
//                                            assetWriterInputWithMediaType:AVMediaTypeVideo
//                                            outputSettings:videoSettings];
//    
//    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
//                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
//                                                     sourcePixelBufferAttributes:nil];
//    
//    NSParameterAssert(videoWriterInput);
//    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
//    
//    videoWriterInput.expectsMediaDataInRealTime = YES;
//    
//    [videoWriter addInput:videoWriterInput];
//    [videoWriter startWriting];
//    [videoWriter startSessionAtSourceTime:kCMTimeZero];
//    
//    
//    // create the image somehow, load from file, draw into it...
//    int frameCount = 0;
//    int kRecordingFPS = 30;
//    
//    CVPixelBufferRef buffer = NULL;
//    for(AnimatedFrameImage *image in gifImage.cacheFrames)
//    {
//        CGImageSourceRef source;
//        source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
//        CGImageRef maskRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
//        
//        buffer = [self newPixelBufferFromCGImage:maskRef frameSize:gifImage.size];
//        
//        CGImageRelease(maskRef);
//        
//        
//        BOOL append_ok = NO;
//        int j = 0;
//        while (!append_ok && j < 30 && buffer)
//        {
//            if (adaptor.assetWriterInput.readyForMoreMediaData)
//            {
//                printf("appending %d attemp %d\n", 0, j);
//                
//                CMTime frameTime = CMTimeMake(frameCount,(int32_t) kRecordingFPS);
//                CMTimeShow(frameTime);
//                
//                frameCount += image.duration * kRecordingFPS;
//                
//                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
//                
//                if(buffer) {
//                    CVBufferRelease(buffer);
//                    buffer = NULL;
//                }
////                [NSThread sleepForTimeInterval:0.05];
//            }
//            else
//            {
//                printf("adaptor not ready %d, %d\n", frameCount, j);
////                [NSThread sleepForTimeInterval:0.1];
//            }
//            j++;
//        }
//        if (!append_ok) {
//            printf("error appending image %d times %d\n", frameCount, j);
//        }
////        break;
////        frameCount++;
//    }
//    [videoWriterInput markAsFinished];
//    [videoWriter finishWriting];
//
//}

- (CGSize)  fixSize:(CGSize) forSize{
    NSInteger w = (NSInteger) forSize.width;
    NSInteger h = (NSInteger) forSize.height;
    return CGSizeMake(w, h);
}

- (CVPixelBufferRef) newPixelBufferFromCGImage: (CGImageRef) image frameSize:(CGSize)frameSize
{
    
    frameSize = [self fixSize:frameSize];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                                 frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                                 kCGBitmapAlphaInfoMask);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view.window makeFirstResponder:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view.window makeFirstResponder:nil];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.view.window makeFirstResponder:nil];
    
    [Notification perform:@"ChangeDialogSelection" data:@{KEY_DIALOG:[NSNull null], @"sender":self}];
}


@end
