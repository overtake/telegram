//
//  TGCirclularCounter.h
//  Telegram
//
//  Created by keepcoder on 12/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGCirclularCounter : TMView

@property (nonatomic,strong) NSString *stringValue;
@property (nonatomic, strong) NSFont *textFont;
@property (nonatomic, strong) NSColor *textColor;



@property (nonatomic,assign) BOOL animated;

@end
