//
//  TMSharedMediaButton.h
//  Telegram
//
//  Created by keepcoder on 03.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserInfoShortButtonView.h"

typedef enum {
    TMSharedMediaPhotoVideoType,
    TMSharedMediaDocumentsType,
    TMSharedMediaSharedLinksType
} TMSharedMediaType;

@interface TMSharedMediaButton : UserInfoShortButtonView
@property (nonatomic,strong) TL_conversation *conversation;

@property (nonatomic,assign) TMSharedMediaType type;
@end
