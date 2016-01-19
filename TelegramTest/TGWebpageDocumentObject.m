//
//  TGWebpageDocumentObject.m
//  Telegram
//
//  Created by keepcoder on 12/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGWebpageDocumentObject.h"
#import "DownloadDocumentItem.h"
#import "DownloadQueue.h"
#import "NSNumber+NumberFormatter.h"
@interface TGWebpageDocumentObject ()
@property (nonatomic,strong) DownloadItem *downloadItem;
@property (nonatomic,strong) TL_localMessage *fakeMessage;
@property (nonatomic,strong) NSAttributedString *downloadedDesc;
@end

@implementation TGWebpageDocumentObject

@synthesize size = _size;
@synthesize imageSize = _imageSize;
@synthesize imageObject = _imageObject;
@synthesize desc = _desc;
@synthesize descSize = _descSize;
-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super initWithWebPage:webpage]) {
        
        TL_localMessage *fake = [[TL_localMessage alloc] init];
        fake.media = [TL_messageMediaDocument createWithDocument:self.webpage.document caption:@""];
        
        _fakeMessage = fake;
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        TL_documentAttributeFilename *fileName = (TL_documentAttributeFilename *) [self.webpage.document attributeWithClass:[TL_documentAttributeFilename class]];
        
        NSRange range = [attr appendString:fileName.file_name withColor:DARK_BLACK];
        
        [attr setFont:TGSystemFont(15) forRange:range];
        
        [attr appendString:@" " withColor:DARK_BLACK];
        
        range = [attr appendString:[@(self.webpage.document.size) prettyNumber] withColor:GRAY_TEXT_COLOR];
        
        [attr setFont:TGSystemFont(13) forRange:range];
        
        
        [attr appendString:@"\n" withColor:GRAY_TEXT_COLOR];
        
        
        NSMutableAttributedString *downloadedStr = [attr mutableCopy];
        
        range = [attr appendString:NSLocalizedString(@"Message.File.Download", nil) withColor:LINK_COLOR];
        
        [attr setLink:NSLocalizedString(@"Message.File.Download", nil) forRange:range];
        
        [attr setFont:TGSystemFont(13) forRange:range];

        
        range = [downloadedStr appendString:NSLocalizedString(@"Message.File.ShowInFinder", nil) withColor:LINK_COLOR];
        
        
        [downloadedStr setLink:NSLocalizedString(@"Message.File.ShowInFinder", nil) forRange:range];
        
        [downloadedStr setFont:TGSystemFont(13) forRange:range];
        
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        style.lineSpacing = 4;
        
        [attr addAttribute:NSParagraphStyleAttributeName value:style range:attr.range];
        [downloadedStr addAttribute:NSParagraphStyleAttributeName value:style range:downloadedStr.range];
        
        
        _downloadedDesc = [downloadedStr copy];
        
        _desc = [attr copy];
        
        
    }
    
    return self;
}

-(DownloadItem *)downloadItem {
    return [DownloadQueue find:self.webpage.document.n_id];
}

-(BOOL)isset {
    return [self.webpage.document isset];
}

-(void)startDownload:(BOOL)cancel force:(BOOL)force {
    DownloadItem *downloadItem = self.downloadItem;
    
    if(!downloadItem) {
        
       downloadItem = [[DownloadDocumentItem alloc] initWithObject:self.fakeMessage];
    }
    
    if((downloadItem.downloadState == DownloadStateCanceled || downloadItem.downloadState == DownloadStateWaitingStart)) {
        [downloadItem start];
    } else if(cancel) {
        [downloadItem cancel];
    }
}

-(TL_localMessage *)fakeMessage {
    return _fakeMessage;
}


-(NSAttributedString *)desc {
    return self.isset ? _downloadedDesc : _desc;
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageDocumentContainer");
}

-(void)makeSize:(int)width {
    [super makeSize:width];
    _descSize = [_desc coreTextSizeForTextFieldForWidth:width - 60];
    _size = NSMakeSize(width , 50 );
        
}

@end
