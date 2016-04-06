//
//  TGContextRowItem.m
//  Telegram
//
//  Created by keepcoder on 23/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGContextRowItem.h"
#import "TGArticleImageObject.h"
#import "DownloadDocumentItem.h"
#import "DownloadExternalItem.h"
#import "DownloadQueue.h"
@interface TGContextRowItem ()
@property (nonatomic,strong) TL_localMessage *message;
@end

@implementation TGContextRowItem
-(id)initWithObject:(TLBotInlineResult *)botResult bot:(TLUser *)bot queryId:(long)queryId {
    if(self = [super initWithObject:bot]) {
        _bot = bot;
        _botResult = botResult;
        _queryId = queryId;
        
        botResult.title = priorityString(botResult.title, @"Empty title",[NSNull class]);
        
        if(botResult.n_description || botResult.title) {
            
            
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] init];
            
            [desc appendString:[botResult.n_description trim] withColor:NSColorFromRGB(0x808080)];
            [desc setFont:TGSystemFont(13) forRange:desc.range];
            
            
            NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSLeftTextAlignment;
            
            [desc addAttribute:NSParagraphStyleAttributeName value:style range:desc.range];
            
            
            NSString *t = [botResult.title trim];
            
            if(t.length > 0)  {
                NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
                
                [title appendString:[NSString stringWithFormat:@"%@%@",t,botResult.n_description.length > 0 ? @"\n" : @""] withColor:NSColorFromRGB(0x000000)];
                [title setFont:TGSystemMediumFont(13) forRange:title.range];
                
                
                [desc insertAttributedString:title atIndex:0];
            }
            
            _desc = desc;
            
            
            [desc setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x000000)];
            [desc setSelectionColor:NSColorFromRGB(0xfffffe) forColor:NSColorFromRGB(0x808080)];
        } else {
            _desc = [[NSMutableAttributedString alloc] init];
        }
        
        if([botResult.photo isKindOfClass:[TL_photo class]]) {
            
            TLPhotoSize *size = [botResult.photo.sizes lastObject];
            
            {
                _imageObject = [[TGImageObject alloc] initWithLocation:size.location placeHolder:nil sourceId:0 size:size.size];
                _imageObject.imageSize = NSMakeSize(60, 60);
            }
            
            
        } else if(botResult.document.thumb && ![botResult.document.thumb isKindOfClass:[TL_photoSizeEmpty class]]) {
            _imageObject = [[TGImageObject alloc] initWithLocation:botResult.document.thumb.location placeHolder:nil sourceId:0 size:botResult.document.thumb.size];
            _imageObject.imageSize = NSMakeSize(60, 60);
            
        } else if(botResult.thumb_url.length > 0) {
            _imageObject = [[TGExternalImageObject alloc] initWithURL:botResult.thumb_url];
            _imageObject.imageSize = NSMakeSize(60, 60);
        } else if(botResult.send_message.geo != nil) {
            _imageObject = [[TGExternalImageObject alloc] initWithURL:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true", botResult.send_message.geo.lat,  botResult.send_message.geo.n_long, ([NSScreen mainScreen].backingScaleFactor == 2 ? @"120x120" : @"60x60")]];
            _imageObject.imageSize = NSMakeSize(60, 60);
        }
        
        _imageObject.imageProcessor = [ImageUtils c_processor];
        _imageObject.placeholder = gray_resizable_placeholder();

        _domainSymbol = botResult.content_url.length > 0 ? first_domain_character(botResult.content_url) :  [[botResult.title substringToIndex:1] uppercaseString];
        
    }
    
    if([_botResult.type isEqualToString:kBotInlineTypeVoice] || [_botResult.type isEqualToString:kBotInlineTypeAudio]) {
        _audioController = [[TGAudioController alloc] init];
        [_audioController setPath:self.path];
    }
    
    _downloadEventListener = [[DownloadEventListener alloc] init];
    
    return self;
}



-(void)dealloc {
    [_audioController setDelegate:nil];
    [_audioController stop];
    
}

-(TL_localMessage *)fakeMessage {
    if(!_message)
    {
        TL_localMessage *fake = [[TL_localMessage alloc] init];
        
        if(_botResult.document) {
            fake.media = [TL_messageMediaDocument createWithDocument:_botResult.document caption:@""];
        } else {
            fake.media = [TL_messageMediaBotResult createWithBot_result:_botResult query_id:_queryId];
        }
        
        _message = fake;
    }
    
    return _message;
}

-(NSString *)outMessage {
    return nil;
}

-(void)startDownload:(BOOL)cancel {
    
    
    DownloadItem *downloadItem = self.downloadItem;
    
    if(!downloadItem) {
        
        if(_botResult.document) {
            
            TL_localMessage *fake = [[TL_localMessage alloc] init];
            fake.media = [TL_messageMediaDocument createWithDocument:_botResult.document caption:@""];
            downloadItem = [[DownloadDocumentItem alloc] initWithObject:fake];
            
            [downloadItem start];
            
        } else if(_botResult.content_url) {
            downloadItem = [[DownloadExternalItem alloc] initWithObject:_botResult.content_url];
            [downloadItem start];
        }
        
        [downloadItem addEvent:_downloadEventListener];
        
    } else if(cancel) {
        [downloadItem cancel];
        [downloadItem removeEvent:_downloadEventListener];
        
    } else {
        [downloadItem addEvent:_downloadEventListener];
    }
    
}

-(DownloadItem *)downloadItem {
    
    if(_botResult.document) {
        return [DownloadQueue find:_botResult.document.n_id];
    } else
        return [DownloadQueue find:[_botResult.content_url hash]];
    
    return nil;
}

-(NSString *)path {
    if(_botResult.document) {
        return _botResult.document.path_with_cache;
    } else
         return path_for_external_link(_botResult.content_url);
}

-(int)size {
    return _botResult.document ? _botResult.document.size : 1;
}

-(BOOL)isset {
    
    BOOL isset = isPathExists([self path]) && (fileSize([self path]) >= self.size);
    
    return isset;
}


-(BOOL)updateItemHeightWithWidth:(int)width {
    
    _descSize = [_desc sizeForTextFieldForWidth:width - 70];
    _descSize.height = MIN(54,_descSize.height);
    
    return NO;
}

-(Class)viewClass {
    return NSClassFromString(@"TGContextRowView");
}

-(int)height {
    return 60;
}

@end
