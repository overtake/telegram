//
//  SteckersPanelView.h
//  Telegram
//
//  Created by keepcoder on 19.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface StickersPanelView : TMView


-(void)showAndSearch:(NSString *)emotion animated:(BOOL)animated;
-(void)hide:(BOOL)animated;
+(void)saveResponse:(TL_messages_allStickers *)response;
@end
