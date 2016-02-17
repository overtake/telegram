//
//  TL_secretWebpage.m
//  Telegram
//
//  Created by keepcoder on 27/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TL_secretWebpage.h"

@implementation TL_secretWebpage

+(TL_secretWebpage *)createWithUrl:(NSString *)url date:(int)date {
    TL_secretWebpage *obj = [[TL_secretWebpage alloc] init];
    obj.url = url;
    obj.date = date;
    return obj;
}

-(void)serialize:(SerializedData *)stream {
    [stream writeString:self.url];
    [stream writeInt:self.date];
}

-(void)unserialize:(SerializedData *)stream {
    self.url = [stream readString];
    self.date = [stream readInt];
}

@end
