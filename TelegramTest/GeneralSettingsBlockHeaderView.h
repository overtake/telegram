//
//  GeneralSettingsBlockHeaderView.h
//  Telegram
//
//  Created by keepcoder on 13.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMRowView.h"
#import "TGGeneralRowItem.h"
@interface GeneralSettingsBlockHeaderItem : TGGeneralRowItem
@property (nonatomic,strong,readonly) NSAttributedString *header;
@property (nonatomic,assign) BOOL isFlipped;
@property (nonatomic,assign) BOOL autoHeight;

-(void)setTextColor:(NSColor *)textColor;
-(void)setFont:(NSFont *)font;
-(void)setAligment:(NSTextAlignment)aligment;

-(id)initWithString:(NSString *)header height:(int)height flipped:(BOOL)flipped;

@end


@interface GeneralSettingsBlockHeaderView : TMRowView


@end
