//
//  TGWebpageTWObject.h
//  Telegram
//
//  Created by keepcoder on 01.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGWebpageObject.h"
#import "XCDYouTubeKit.h"
@interface TGWebpageYTObject : TGWebpageObject


@property (nonatomic, strong) NSAttributedString *videoTimeAttributedString;
@property (nonatomic) NSSize videoTimeSize;

@property (nonatomic,strong,readonly) XCDYouTubeVideo *video;

-(void)loadVideo:(void (^)(XCDYouTubeVideo *video))callback;

@end
