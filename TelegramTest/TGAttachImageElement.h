//
//  TGAttachImageElement.h
//  Telegram
//
//  Created by keepcoder on 18.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TGAttachImageElement : TMView


@property (nonatomic,strong,readonly) NSString *link;
@property (nonatomic,assign,readonly) NSRange range;


@property (nonatomic,copy) dispatch_block_t deleteCallback;

-(void)setLink:(NSString *)link range:(NSRange)range;

-(NSImage *)image;

@end
