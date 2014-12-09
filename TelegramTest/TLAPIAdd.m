//
//  TLAPIAdd.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 4/7/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLAPIAdd.h"

@implementation TL_initConnection

- (NSData*)getData {
    SerializedData* stream = [TLClassStore streamWithConstuctor:1769565673];
    
    [stream writeInt:API_ID];
    [stream writeString:self.device_model];
    [stream writeString:self.system_version];
    [stream writeString:self.app_version];
    [stream writeString:self.lang_code];
    
    [stream writeData:[self.query getData]];
    
	return [stream getOutput];
}
@end



@implementation TLAPI_photos_deletePhotos


+(TLAPI_photos_deletePhotos *)createWithN_id:(NSArray *)n_id {
    TLAPI_photos_deletePhotos *obj = [[TLAPI_photos_deletePhotos alloc] init];
    obj.n_id = n_id;
    
    return obj;
}

- (NSData*)getData {
    SerializedData* stream = [TLClassStore streamWithConstuctor:0x87cf7f2f];
    
    [stream writeInt:0x1cb5c415];
    {
        NSInteger tl_count = [self.n_id count];
        [stream writeInt:(int)tl_count];
        for(int i = 0; i < (int)tl_count; i++) {
            id obj = [self.n_id objectAtIndex:i];
            [TLClassStore TLSerialize:obj stream:stream];
        }
    }

    return [stream getOutput];
}

@end