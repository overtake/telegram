//
//  TGModalCompressingView.h
//  Telegram
//
//  Created by keepcoder on 15/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGModalView.h"
#import "TGCompressItem.h"
#import "TGCompressVideoItem.h"
#import "TGCompressGifItem.h"
@interface TGModalCompressingView : TGModalView

@property (nonatomic,weak) MessagesViewController *controller;

-(void)compressAndSendAfterItems:(NSArray *)items;
-(void)addCompressItem:(TGCompressItem *)item;

@end
