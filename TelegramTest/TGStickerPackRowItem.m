//
//  TGStickerPackRowItem.m
//  Telegram
//
//  Created by keepcoder on 24/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGStickerPackRowItem.h"
@implementation TGStickerPackRowItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _pack = object;
        
        NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
        
        _set = object[@"set"];
        
        NSArray *stickers = object[@"stickers"];
        
        TL_document *sticker;
        
        _stickers = stickers;
        
        if(stickers.count > 0)
        {
            sticker = stickers[0];
            
            TL_documentAttributeSticker *s_attr = (TL_documentAttributeSticker *) [sticker attributeWithClass:[TL_documentAttributeSticker class]];
            
            _inputSet = s_attr.stickerset;
            
            NSImage *placeholder = [[NSImage alloc] initWithData:sticker.thumb.bytes];
            
            if(!placeholder)
                placeholder = [NSImage imageWithWebpData:sticker.thumb.bytes error:nil];
            
            _imageObject = [[TGMessagesStickerImageObject alloc] initWithLocation:sticker.thumb.location placeHolder:placeholder];
            
            _imageObject.imageSize = strongsize(NSMakeSize(sticker.thumb.w, sticker.thumb.h), 35);
        }
        
        BOOL unread = [object[@"unread"] boolValue];
        
        if(unread){
            [attrs appendString:@"    "];
        }
        
        NSRange range = [attrs appendString:_set.title withColor:TEXT_COLOR];
        
        [attrs setFont:TGSystemMediumFont(13) forRange:range];
        
        [attrs appendString:@"\n" withColor:[NSColor whiteColor]];
        
        range = [attrs appendString:[NSString stringWithFormat:NSLocalizedString(@"Stickers.StickersCount", nil),stickers.count] withColor:GRAY_TEXT_COLOR];
        
        [attrs setFont:TGSystemFont(13) forRange:range];
        
        _title = attrs;
        
    }
    
    return self;
}

-(BOOL)updateItemHeightWithWidth:(int)width {
    return NO;
}

-(NSUInteger)hash {
    return [[_pack[@"set"] valueForKey:@"n_id"] longValue];
}

-(Class)viewClass {
    return NSClassFromString(@"TGStickerPackRowView");
}

-(int)height {
    return 50;
}

@end