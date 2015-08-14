//
//  MessageTableItemText.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"
#import "TGCTextMark.h"
#import "TGWebpageObject.h"
@interface MessageTableItemText : MessageTableItem

@property (nonatomic, strong) NSMutableAttributedString *textAttributed;
@property (nonatomic,strong) NSDictionary *textAttributes;

@property (nonatomic,strong) SearchSelectItem *mark;

@property (nonatomic,assign) NSSize textSize;

@property (nonatomic,strong,readonly) TGWebpageObject *webpage;
@property (nonatomic,strong,readonly) NSArray *links;
@property (nonatomic,strong,readonly) NSAttributedString *allAttributedLinks;
@property (nonatomic,assign,readonly) NSSize allAttributedLinksSize;

-(void)updateMessageFont;

-(void)updateWebPage;
-(void)updateEntities;

-(BOOL)isWebPage;


@end
