//
//  TMSharedMediaButton.h
//  Telegram
//
//  Created by keepcoder on 03.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoShortButtonView.h"

@interface TMSharedMediaButton : UserInfoShortButtonView
@property (nonatomic,strong) TL_conversation *conversation;

@property (nonatomic,assign) BOOL isFiles;
@end
