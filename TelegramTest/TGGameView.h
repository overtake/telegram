//
//  TGGameView.h
//  Telegram
//
//  Created by keepcoder on 27/09/2016.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGGameObject.h"
@interface TGGameView : TMView

@property (nonatomic,strong) TGGameObject *game;

-(void)setGame:(TGGameObject *)game;
-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color;
@end
