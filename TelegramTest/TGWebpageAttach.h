//
//  TGWebpageAttach.h
//  Telegram
//
//  Created by keepcoder on 06.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGWebpageAttach : TMView

@property (nonatomic,strong,readonly) TLWebPage *webpage;

@property (nonatomic,strong,readonly) NSString *link;

@property (nonatomic,strong) TGInputMessageTemplate *inputTemplate;

-(id)initWithFrame:(NSRect)frameRect webpage:(TLWebPage *)webpage link:(NSString *)link inputTemplate:(TGInputMessageTemplate *)inputTemplate;


@end
