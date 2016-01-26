//
//  TGProfileParamItem.m
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGProfileParamItem.h"

@implementation TGProfileParamItem


-(void)setHeader:(NSString *)header withValue:(NSString *)value {
    _header = header;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSLeftTextAlignment];
    
    NSAttributedString *attr = [[NSAttributedString alloc] initWithString:[value trim] attributes:@{NSForegroundColorAttributeName: NSColorFromRGB(0x333333), (NSString *)kCTFontAttributeName:TGSystemLightFont(14), NSParagraphStyleAttributeName: paragraphStyle}];
    

    _value = attr;
    
}

-(Class)viewClass {
    return NSClassFromString(@"TGProfileParamView");
}

-(BOOL)updateItemHeightWithWidth:(int)width {
    
    NSSize size = [_value coreTextSizeForTextFieldForWidth:roundf(width) - (self.xOffset * 2)];
    
    self.height = size.height + 33;
    _size = size;
    return YES;
}

@end
