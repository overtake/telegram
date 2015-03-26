//
//  MessageTableItemWebPage.h
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"

@interface MessageTableItemWebPage : MessageTableItem


@property (nonatomic,strong,readonly) NSAttributedString *title;
@property (nonatomic,strong,readonly) TGImageObject *imageObject;
@property (nonatomic,strong,readonly) NSAttributedString *desc;

@property (nonatomic,strong,readonly) NSAttributedString *textAttributed;

-(void)updateWebPage;

@end
