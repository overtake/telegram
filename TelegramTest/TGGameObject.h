//
//  TGGameObject.h
//  Telegram
//
//  Created by keepcoder on 27/09/2016.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageTableItem.h"
@interface TGGameObject : NSObject

@property (nonatomic,strong,readonly) NSAttributedString *title;
@property (nonatomic,strong,readonly) NSAttributedString *desc;

@property (nonatomic,assign,readonly) NSSize descSize;

@property (nonatomic,strong,readonly) TGImageObject *imageObject;

@property (nonatomic,strong,readonly) TLGame *game;
@property (nonatomic,assign,readonly) NSSize size;
@property (nonatomic,weak,readonly) TL_localMessage *message;

@property (nonatomic,strong) MessageTableItem *gifItem;

- (instancetype)initWithGame:(TLGame *)game message:(TL_localMessage *)message text:(NSAttributedString *)text;

-(void)makeSize:(int)width;

@end
