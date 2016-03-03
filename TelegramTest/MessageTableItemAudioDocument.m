//
//  MessageTableItemAudioDocument.m
//  Telegram
//
//  Created by keepcoder on 17.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItemAudioDocument.h"
#import "DownloadDocumentItem.h"
#import "NSStringCategory.h"
#import "NSString+Extended.h"
#import <AVFoundation/AVFoundation.h>
#import "DownloadQueue.h"
#import "MessageTablecellAudioDocumentView.h"
@implementation MessageTableItemAudioDocument

- (id)initWithObject:(TLMessage *)object {
    self = [super initWithObject:object];
    if(self) {
        self.blockSize = NSMakeSize(200, 60);
       
       _fileSize = [[NSString sizeToTransformedValuePretty:self.message.media.document.size] trim];
       
       
        [self doAfterDownload];
    
    }
    return self;
}

-(void)checkStartDownload:(SettingsMask)setting size:(int)size {
    [super checkStartDownload:[self.message.to_id isKindOfClass:[TL_peerChat class]] || [self.message.to_id isKindOfClass:[TL_peerChannel class]] ? AutoGroupDocuments : AutoPrivateDocuments size:[self size]];
}

-(BOOL)canShare {
    return [self isset];
}

-(id)thumbObject {
    return nil;
}

-(void)doAfterDownload {
    
    TL_documentAttributeAudio *audio = (TL_documentAttributeAudio *) [self.message.media.document attributeWithClass:[TL_documentAttributeAudio class]];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    if(audio && ([audio.title trim].length > 0 && [audio.performer trim].length > 0)) {
        NSRange range = [attr appendString:[audio.performer trim] withColor:TEXT_COLOR];
        [attr setFont:TGSystemMediumFont(13) forRange:range];
        
        [attr appendString:@"\n"];
        
        range = [attr appendString:[audio.title trim] withColor:GRAY_TEXT_COLOR];
        [attr setFont:TGSystemFont(13) forRange:range];
        
    } else {
        
        [attr appendString:self.message.media.document.file_name withColor:TEXT_COLOR];
        [attr setFont:TGSystemMediumFont(13) forRange:attr.range];
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    [attr addAttribute:NSParagraphStyleAttributeName value:style range:attr.range];

    
    _nameAttributedString = attr;
    
    [self regenerate];
}


-(void)regenerate {
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    TL_documentAttributeAudio *audio = (TL_documentAttributeAudio *) [self.message.media.document attributeWithClass:[TL_documentAttributeAudio class]];
    
    NSString *perfomer = [audio.performer trim];
    NSString *title = [audio.title trim];
    

    if(audio && (title.length > 0 || perfomer.length > 0)) {
        
        
        
        if(perfomer.length > 0)
            [attr appendString:perfomer withColor:TEXT_COLOR];
        else
            [attr appendString:@"Unknown Artist" withColor:TEXT_COLOR];
        [attr setFont:TGSystemMediumFont(13) forRange:attr.range];
        
        if(title.length > 0) {
            [attr appendString:@"\n"];
        }
        
        if(title.length > 0) {
            NSRange range = [attr appendString:title withColor:NSColorFromRGB(0x7F7F7F)];
            [attr setFont:TGSystemFont(13) forRange:range];
        }
        
        
        
        
    } else {
        [attr appendString:self.message.media.document.file_name withColor:TEXT_COLOR];
        [attr setFont:TGSystemFont(13) forRange:attr.range];
    }
    
    [attr setSelectionColor:NSColorFromRGB(0xfffffe) forColor:TEXT_COLOR];
    [attr setSelectionColor:[NSColor whiteColor] forColor:NSColorFromRGB(0x7F7F7F)];
    
    
    
    _id3AttributedString = attr;
    
    
    NSMutableAttributedString *copy = [attr mutableCopy];
    
    [copy setAlignment:NSCenterTextAlignment range:copy.range];
    
    _id3AttributedStringHeader = copy;

}

- (Class)downloadClass {
    return [DownloadDocumentItem class];
}

- (BOOL)canDownload {
    return self.message.media.document.dc_id != 0;
}

-(void)setDownloadItem:(DownloadItem *)downloadItem {
    [super setDownloadItem:downloadItem];
    
    _secondDownloadListener = [[DownloadEventListener alloc] init];
}

-(DownloadItem *)downloadItem {
    if(super.downloadItem == nil)
        [super setDownloadItem:[DownloadQueue find:self.message.media.document.n_id]];
    
    return [super downloadItem];
}

-(void)dealloc {
    [self.downloadItem removeAllEvents];
}

- (int)size {
    return self.message.media.document.size;
}

-(NSString *)fileName {
    return self.message.media.document.file_name;
}

-(BOOL)makeSizeByWidth:(int)width {
    [super makeSizeByWidth:width];
    
    self.blockSize = NSMakeSize(width, 50);
    _nameSize = [_nameAttributedString coreTextSizeForTextFieldForWidth:width - 60];
    return YES;
}

-(Class)viewClass {
    return [MessageTablecellAudioDocumentView class];
}

@end
