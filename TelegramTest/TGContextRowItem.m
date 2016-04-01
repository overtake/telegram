//
//  TGContextRowItem.m
//  Telegram
//
//  Created by keepcoder on 23/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGContextRowItem.h"
#import "TGArticleImageObject.h"
@interface TGContextRowItem ()

@end

@implementation TGContextRowItem
-(id)initWithObject:(TLBotInlineResult *)botResult bot:(TLUser *)bot queryId:(long)queryId {
    if(self = [super initWithObject:bot]) {
        _bot = bot;
        _botResult = botResult;
        _queryId = queryId;
        
        if(botResult.n_description || botResult.title) {
            
            
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] init];
            
            [desc appendString:botResult.n_description withColor:NSColorFromRGB(0x808080)];
            [desc setFont:TGSystemFont(13) forRange:desc.range];
            
            
            NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSLeftTextAlignment;
            
            [desc addAttribute:NSParagraphStyleAttributeName value:style range:desc.range];
            
            
            NSString *t = botResult.title;
            
            if(t.length > 0)  {
                NSMutableAttributedString *title = [[NSMutableAttributedString alloc] init];
                
                [title appendString:[NSString stringWithFormat:@"%@\n",t] withColor:NSColorFromRGB(0x000000)];
                [title setFont:TGSystemMediumFont(13) forRange:title.range];
                
                
                [desc insertAttributedString:title atIndex:0];
            }
            
            _desc = desc;
            
            
            [desc setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x000000)];
            [desc setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x808080)];
        } else {
            _desc = [[NSMutableAttributedString alloc] init];
        }
        
        if([botResult.photo isKindOfClass:[TL_photo class]]) {
            
            TLPhotoSize *size = [botResult.photo.sizes lastObject];
            
            {
                _imageObject = [[TGArticleImageObject alloc] initWithLocation:size.location placeHolder:nil sourceId:0 size:size.size];
                
                _imageObject.imageSize = NSMakeSize(60, 60);
            }
            
            
        } else if(botResult.thumb_url.length > 0) {
            _imageObject = [[TGExternalImageObject alloc] initWithURL:botResult.thumb_url];
            _imageObject.imageSize = NSMakeSize(60, 60);
            _imageObject.imageProcessor = [ImageUtils c_processor];
        } else if(botResult.send_message.geo != nil) {
            _imageObject = [[TGExternalImageObject alloc] initWithURL:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%f,%f&zoom=15&size=%@&sensor=true", botResult.send_message.geo.lat,  botResult.send_message.geo.n_long, ([NSScreen mainScreen].backingScaleFactor == 2 ? @"120x120" : @"60x60")]];
            _imageObject.imageSize = NSMakeSize(60, 60);
            _imageObject.imageProcessor = [ImageUtils c_processor];
        }

    }
    
    return self;
}

-(NSString *)outMessage {
    return nil;
}


-(BOOL)updateItemHeightWithWidth:(int)width {
    return NO;
}

-(Class)viewClass {
    return NSClassFromString(@"TGContextRowView");
}

-(int)height {
    return 60;
}

@end
