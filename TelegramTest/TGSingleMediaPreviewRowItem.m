//
//  TGSingleMediaPreviewRowItem.m
//  Telegram
//
//  Created by keepcoder on 21/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGSingleMediaPreviewRowItem.h"

@interface TGSingleMediaPreviewRowItem ()
@property (nonatomic,strong) NSString *filepath;
@end

@implementation TGSingleMediaPreviewRowItem


-(id)initWithObject:(id)object ptype:(PasteBoardItemType)ptype data:(NSData *)data {
    if(self = [super initWithObject:object]) {
        _filepath = object;
        _ptype = ptype;
        _data = data;
        self.height = 140;

        _thumbSize = NSMakeSize(80, 80);
        if(ptype == PasteBoardItemTypeVideo) {
            
            NSDictionary *params = [MessageSender videoParams:_filepath thumbSize:NSMakeSize(300, 300)];
            
            _thumbImage = params[@"image"];
            
        } else if(ptype == PasteBoardItemTypeDocument) {
            _thumbImage = previewImageForDocument(_filepath);
        } else if(ptype == PasteBoardItemTypeImage) {
            _thumbImage = [[NSImage alloc] initWithData:data];
            _thumbSize = convertSize(_thumbImage.size, NSMakeSize(300, 150));
            
            self.height = _thumbSize.height + 40;
            
        }
        
        if(ptype != PasteBoardItemTypeImage) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
            
            [attr appendString:[_filepath lastPathComponent] withColor:TEXT_COLOR];
            
            [attr appendString:@"\n\n"];
            
            [attr appendString: [NSString sizeToTransformedValue:fileSize(_filepath)] withColor:GRAY_TEXT_COLOR];
            
            [attr setFont:TGSystemFont(14) forRange:attr.range];
            
            _text = [attr copy];
            
            _textSize = [attr coreTextSizeForTextFieldForWidth:INT32_MAX];
        }
        

       
    }
    
    return self;
}

-(Class)viewClass {
    return NSClassFromString(@"TGSingleMediaPreviewRowView");
}

@end
