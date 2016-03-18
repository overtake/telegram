//
//  TGMessageEditSender.h
//  Telegram
//
//  Created by keepcoder on 18/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TGInputMessageTemplate.h"
@interface TGMessageEditSender : NSObject


@property (nonatomic,strong) TGInputMessageTemplate *inputTemplate;
@property (nonatomic,strong) TL_conversation *conversation;
-(id)initWithTemplate:(TGInputMessageTemplate *)inputTemplate conversation:(TL_conversation *)conversation;

-(void)performEdit:(int)flags;

@end
