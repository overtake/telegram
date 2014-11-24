//
//  DialogTableObject.h
//  Telegram
//
//  Created by keepcoder on 13.11.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DialogTableObject : NSObject
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) TL_conversation *dialog;
@property (nonatomic,assign) int n_id;
@property (nonatomic,strong) TLFileLocation *location;
@property (nonatomic,strong) TL_localMessage *lastMessage;
@property (nonatomic,strong) NSAttributedString *message;
-(id)initWithDialog:(TL_conversation *)dialog;
@end
