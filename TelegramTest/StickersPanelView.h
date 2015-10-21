//
//  SteckersPanelView.h
//  Telegram
//
//  Created by keepcoder on 19.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface StickersPanelView : TMView


@property (nonatomic,weak) MessagesViewController *messagesViewController;

-(void)showAndSearch:(NSString *)emotion animated:(BOOL)animated;
-(void)hide:(BOOL)animated;


void setRemoteStickersLoaded(BOOL loaded);
bool isRemoteStickersLoaded();

+(void)addLocalSticker:(TLDocument *)document;
+(BOOL)hasSticker:(TLDocument *)document;
@end
