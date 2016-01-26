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
#import "NSAttributedString+Hyperlink.h"

#import "TGArticleImageObject.h"

@implementation TGWebpageObject

NSImage *placeholder() {
    static NSImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSRect rect = NSMakeRect(0, 0, 1, 1);
        image = [[NSImage alloc] initWithSize:rect.size];
        [image lockFocus];
        
        [GRAY_BORDER_COLOR setFill];
        NSRectFill(rect);
        [image unlockFocus];
        
    });
    return image;
}

-(id)initWithWebPage:(TLWebPage *)webpage {
    if(self = [super init]) {
        
        _webpage = webpage;
        
        
        NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        style.alignment = NSLeftTextAlignment;
        
        if(webpage.author) {
            
            NSMutableAttributedString *author = [[NSMutableAttributedString alloc] init];
            
            
            [author appendString:webpage.author withColor:DARK_BLACK];
            
            [author setFont:TGSystemMediumFont(13) forRange:author.range];
            
          //  [author addAttribute:NSParagraphStyleAttributeName value:style range:author.range];
            
            _author = author;
            
        }
        
        
        _date = webpage.date == 0 ? nil : [TGDateUtils stringForMessageListDate:webpage.date];
        
        if(webpage.title) {
            NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
            
            [title appendString:webpage.title withColor:[NSColor blackColor]];
            [title setFont:TGSystemMediumFont(13) forRange:title.range];
            
            _title = title;
        }
//        
//        if(!_author) {
//            
//            NSMutableAttributedString *copy = [_title mutableCopy];
//            
//            [copy setFont:TGSystemMediumFont(12.5) forRange:copy.range];
//            [copy addAttribute:NSParagraphStyleAttributeName value:style range:copy.range];
//            _author = copy;
//            
//        }
        
        NSMutableAttributedString *siteName = [[NSMutableAttributedString alloc] init];
        
        [siteName appendString:webpage.site_name ? webpage.site_name : @"Link Preview" withColor:GRAY_TEXT_COLOR];

        [siteName setFont:TGSystemMediumFont(13) forRange:siteName.range];
      //  [siteName addAttribute:NSParagraphStyleAttributeName value:style range:siteName.range];
        _siteName = siteName;
        
        
        if(webpage.n_description || webpage.title) {
            
            
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] init];
            
            [desc appendString:webpage.n_description withColor:[NSColor blackColor]];
            [desc setFont:TGSystemFont(13) forRange:desc.range];
            
            NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSLeftTextAlignment;
            
            [desc addAttribute:NSParagraphStyleAttributeName value:style range:desc.range];
            
            
            NSString *t = webpage.title.length > 0 ? webpage.title : webpage.author;
            
            if(t.length > 0 && _author == nil)  {
                NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
                
                [title appendString:[NSString stringWithFormat:@"%@\n",t] withColor:[NSColor blackColor]];
                [title setFont:TGSystemMediumFont(13) forRange:title.range];
                
                [desc insertAttributedString:title atIndex:0];
            }
            
            
            _desc = desc;
            
            [desc detectAndAddLinks:URLFindTypeLinks];
        } else {
            _desc = [[NSAttributedString alloc] init];
        }
        
       
        if(webpage.n_description.length > 0) {
            _toolTip = [NSString stringWithFormat:@"%@",webpage.n_description];
        }
        
        
        
        if(![webpage.photo isKindOfClass:[TL_photoEmpty class]] && webpage.photo.sizes.count > 0) {
            NSArray *photo = [webpage.photo sizes];
            
            TLPhotoSize *photoSize = [photo lastObject];
            
            
            _imageObject = [[TGImageObject alloc] initWithLocation:photoSize.location placeHolder:placeholder() sourceId:0 size:photoSize.size];
            
            
            NSSize imageSize = strongsize(NSMakeSize(photoSize.w, photoSize.h), 320);
            
            
            _imageObject.imageSize = imageSize;
            
            
            _roundObject = [[TGArticleImageObject alloc] initWithLocation:photoSize.location placeHolder:placeholder() sourceId:0 size:photoSize.size];
            
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

+(id)objectForWebpage:(TLWebPage *)webpage {
    
    
#ifdef TGDEBUG
    
   // if(!ACCEPT_FEATURE)
     //   return nil;
    
#endif
    
    

    
    if([webpage.site_name isEqualToString:@"YouTube"] && [webpage.type isEqualToString:@"video"])
    {
        return [[TGWebpageYTObject alloc] initWithWebPage:webpage];
    }
    
    if([webpage.site_name isEqualToString:@"Instagram"])
    {
        return [[TGWebpageIGObject alloc] initWithWebPage:webpage];
    }
    
    if([webpage.site_name isEqualToString:@"Twitter"])
    {
        return [[TGWebpageTWObject alloc] initWithWebPage:webpage];
    }
    
    
    
    
    if([webpage.type isEqualToString:@"article"] || [webpage.type isEqualToString:@"app"])
    {
        return [[TGWebpageArticle alloc] initWithWebPage:webpage];
    }
    
    if([webpage.type isEqualToString:@"document"]) {
        if([webpage.document.mime_type isEqualToString:@"image/gif"])
            return [[TGWebpageGifObject alloc] initWithWebPage:webpage];
    }
    
    return [[TGWebpageStandartObject alloc] initWithWebPage:webpage];
    
    return nil;
}

-(NSImage *)siteIcon  {
    return nil;
}

-(int)blockHeight {
    return self.size.height + (self.author ? 30 : 14);
}


@end
