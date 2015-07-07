//
//  TGPVDocumentObject.m
//  Telegram
//
//  Created by keepcoder on 06.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGPVDocumentObject.h"
#import "DownloadDocumentItem.h"

@interface TGPVDocumentObject ()
@property (nonatomic,strong) TL_localMessage *message;
@end

@implementation TGPVDocumentObject

-(id)initWithMessage:(TL_localMessage *)message placeholder:(NSImage *)placeholder {
    if(self = [super initWithLocation:nil placeHolder:placeholder]) {
        _message = message;
        self.imageSize = placeholder.size;
    }
    
    return self;
}

-(void)initDownloadItem {
    
    
    
}


-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"doc:%lu",_message.media.document.n_id];
}


@end
