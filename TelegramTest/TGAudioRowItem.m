//
//  TGAudioRowItem.m
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAudioRowItem.h"
#import "MessageTableItemAudioDocument.h"
@interface TGAudioRowItem ()
@property (nonatomic,strong) MessageTableItemAudioDocument *documentItem;
@end

@implementation TGAudioRowItem


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        _documentItem = object;
    }
    
    return self;
}

-(MessageTableItemAudioDocument *)document {
    return _documentItem;
}

-(NSString *)trackName {
    return _documentItem.fileName;
}

-(NSUInteger)hash {
    return _documentItem.message.randomId;
}

@end
