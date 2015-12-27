//
//  TGGifKeyboardView.h
//  Telegram
//
//  Created by keepcoder on 22/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGGifKeyboardView : TMView

@property (nonatomic,strong) MessagesViewController *messagesViewController;


-(void)prepareSavedGifvs;
-(void)clear;
@end
