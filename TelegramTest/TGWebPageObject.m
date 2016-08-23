//
//  TGWebPageObject.m
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageObject.h"
#import "TGDateUtils.h"
#import "TGWebpageIGObject.h"
#import "TGWebpageYTObject.h"
#import "TGWebpageTWObject.h"
#import "TGWebpageStandartObject.h"
#import "TGWebpageArticle.h"
#import "TGWebpageGifObject.h"
#import "TGWebpageDocumentObject.h"
#import "NSAttributedString+Hyperlink.h"

#import "TGArticleImageObject.h"
#import "NSImage+RHResizableImageAdditions.h"

@implementation TGWebpageObject



-(id)initWithWebPage:(TLWebPage *)webpage tableItem:(MessageTableItem *)item {
    if(self = [super init]) {
        
        _webpage = webpage;
        _tableItem = item;
        
        
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        style.alignment = NSLeftTextAlignment;
        
        if(webpage.author) {
            
            NSMutableAttributedString *author = [[NSMutableAttributedString alloc] init];
            
            
            [author appendString:webpage.author withColor:DARK_BLACK];
            
            [author setFont:[SettingsArchiver fontMedium13] forRange:author.range];
            
          //  [author addAttribute:NSParagraphStyleAttributeName value:style range:author.range];
            
            _author = author;
            
        }
        
        
        _date = webpage.date == 0 ? nil : [TGDateUtils stringForMessageListDate:webpage.date];
        
        if(webpage.title) {
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
            
            [title appendString:webpage.title withColor:[NSColor blackColor]];
            [title setFont:[SettingsArchiver fontMedium13] forRange:title.range];
            
            _title = title;
        }
        NSMutableAttributedString *siteName = [[NSMutableAttributedString alloc] init];
        
        [siteName appendString:webpage.site_name ? webpage.site_name : webpage.document ? NSLocalizedString(webpage.type, nil) : @"Link Preview" withColor:LINK_COLOR];

        [siteName setFont:[SettingsArchiver fontMedium13] forRange:siteName.range];
      //  [siteName addAttribute:NSParagraphStyleAttributeName value:style range:siteName.range];
        _siteName = siteName;
        
        
        if(webpage.n_description || webpage.title) {
            
            
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] init];
            
            [desc appendString:webpage.n_description withColor:NSColorFromRGB(0x000000)];
            [desc setFont:[SettingsArchiver font13] forRange:desc.range];
            
            
            NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSLeftTextAlignment;
            
            [desc addAttribute:NSParagraphStyleAttributeName value:style range:desc.range];
            
            
            
            NSString *t = webpage.title.length > 0 ? webpage.title : webpage.author;
            
            if(t.length > 0 && _author == nil)  {
                NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
                
                [title appendString:[NSString stringWithFormat:@"%@\n",t] withColor:NSColorFromRGB(0x000000)];
                [title setFont:[SettingsArchiver fontMedium13] forRange:title.range];
                
                
                [desc insertAttributedString:title atIndex:0];
            }
            
            _desc = desc;
            
            [desc detectAndAddLinks:URLFindTypeLinks];
            
            [desc setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x000000)];
            
        } else {
            _desc = [[NSAttributedString alloc] init];
        }
        
       
        if(webpage.n_description.length > 0) {
            _toolTip = [NSString stringWithFormat:@"%@",webpage.n_description];
        }
        
        
        
        if(![webpage.photo isKindOfClass:[TL_photoEmpty class]] && webpage.photo.sizes.count > 0) {
            NSArray *photo = [webpage.photo sizes];
            
            TLPhotoSize *photoSize = [photo lastObject];
            
            
            _imageObject = [[TGImageObject alloc] initWithLocation:photoSize.location placeHolder:gray_resizable_placeholder() sourceId:0 size:photoSize.size];
            
            
            NSSize imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), 320);
            
            
            _imageObject.imageSize = imageSize;
            
            
            _roundObject = [[TGArticleImageObject alloc] initWithLocation:photoSize.location placeHolder:gray_resizable_placeholder() sourceId:0 size:photoSize.size];
            _roundObject.imageProcessor = [ImageUtils c_processor];
            _roundObject.imageSize = NSMakeSize(60, 60);
        }
        
        
    }
    
    return self;
}




-(void)makeSize:(int)width {
    
    if(![self.webpage.type isEqualToString:@"profile"]) {
        _imageSize = strongsize(_imageObject.imageSize, MIN(320, width - 67));
        
        _titleSize = [self.title coreTextSizeForTextFieldForWidth: width-67];
        _descSize = [self.desc coreTextSizeForTextFieldForWidth: width-67];
        
        _size = _imageSize;
        
        _size.height+= _descSize.height + (_imageObject ? 5 : 0) ;
    } else {
        _imageSize = strongsize(_imageObject.imageSize, 60);
        
        _titleSize = [self.title coreTextSizeForTextFieldForWidth: width-132];
        _descSize = [self.desc coreTextSizeForTextFieldForWidth: width-132];
        
        _size = _imageSize;
    }
    
    _size.width = width - 60;
    
}

-(void)dealloc {
    
}

-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageContainer");
}

static NSCache *webpages;



+(id)objectForWebpage:(TLWebPage *)webpage tableItem:(MessageTableItem *)item {
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webpages = [[NSCache alloc] init];
        [webpages setCountLimit:150];
    });
    
    Class webpageClass = [NSNull class];
    
    if([webpage.site_name isEqualToString:@"YouTube"] && [webpage.type isEqualToString:@"video"])
        webpageClass = [TGWebpageYTObject class];
     else if([webpage.site_name isEqualToString:@"Instagram"])
         webpageClass = [TGWebpageIGObject class];
    else if([webpage.site_name isEqualToString:@"Twitter"])
        webpageClass = [TGWebpageTWObject class];
    else if([webpage.type isEqualToString:@"article"] || [webpage.type isEqualToString:@"app"])
        webpageClass = [TGWebpageArticle class];
    else if(webpage.document)
        webpageClass = [TGWebpageDocumentObject class];
    else
        webpageClass = [TGWebpageStandartObject class];
    
    
    NSString *key = [NSString stringWithFormat:@"%@_%ld",NSStringFromClass(webpageClass),webpage.n_id];
    
    TGWebpageObject *object = [webpages objectForKey:key];
    
    if(!object && webpageClass != [NSNull class])
    {
        object = [[webpageClass alloc] initWithWebPage:webpage tableItem:item];
        [webpages setObject:object forKey:key];
    } else if (object)
        object.tableItem = item;
    
    return object;
    
}

-(NSImage *)siteIcon  {
    return nil;
}

-(void)doAfterDownload {
    
}

-(int)blockHeight {
    return self.size.height + (self.author ? 30 : 14);
}


@end
