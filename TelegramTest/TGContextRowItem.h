//
//  TGContextRowItem.h
//  Telegram
//
//  Created by keepcoder on 23/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"
#import "TGWebpageObject.h"
#import "TGGeneralRowItem.h"
#import "TGExternalImageObject.h"
@interface TGContextRowItem : TGGeneralRowItem
@property (nonatomic,strong,readonly) TLWebPage *webpage;
@property (nonatomic,strong,readonly) NSMutableAttributedString *desc;
@property (nonatomic,strong) TGImageObject *imageObject;

-(id)initWithObject:(id)object bot:(NSString *)bot;

-(NSString *)outMessage;
@end
