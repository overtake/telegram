//
//  MessageTableitemMessagesHole.h
//  Telegram
//
//  Created by keepcoder on 27.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "MessageTableItem.h"

@interface MessageTableItemHole : MessageTableItem

@property (nonatomic,strong,readonly) NSAttributedString *text;
@property (nonatomic,assign,readonly) NSSize textSize;

-(void)updateWithHole:(TGMessageHole *)hole;

@end
