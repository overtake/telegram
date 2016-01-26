//
//  TLClassStore.m
//  TelegramTest
//
//  Created by Dmitry Kondratyev on 10/26/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TLClassStore.h"
#import "TL_localMessage_old32.h"
#import "TL_localMessage_old34.h"
#import "TL_conversation_old34.h"
#import "TL_localMessageService_old34.h"
@implementation TLClassStore


- (id)init {
    self = [super init];
    if(self) {
        
      
    }
    return self;
}

+(void)initialize {
    [super initialize];
    
    [self.cs_classes setObject:[TL_messageActionEncryptedChat class] forKey:[NSNumber numberWithInt:1]];
    [self.cs_classes setObject:[TL_peerSecret class] forKey:[NSNumber numberWithInt:2]];
    [self.cs_classes setObject:[TL_localMessage_old32 class] forKey:[NSNumber numberWithInt:3]];
    [self.cs_classes setObject:[TL_destructMessage class] forKey:[NSNumber numberWithInt:4]];
    [self.cs_classes setObject:[TL_conversation_old34 class] forKey:[NSNumber numberWithInt:5]];
    
    
    [self.cs_classes setObject:[TL_outDocument class] forKey:[NSNumber numberWithInt:6]];
    [self.cs_classes setObject:[TL_localMessageService_old34 class] forKey:[NSNumber numberWithInt:8]];
    [self.cs_classes setObject:[TL_peerBroadcast class] forKey:[NSNumber numberWithInt:9]];
    [self.cs_classes setObject:[TL_broadcast class] forKey:[NSNumber numberWithInt:10]];
    [self.cs_classes setObject:[TL_messageActionSetMessageTTL class] forKey:[NSNumber numberWithInt:11]];
    [self.cs_classes setObject:[TL_secretServiceMessage class] forKey:[NSNumber numberWithInt:12]];
    [self.cs_classes setObject:[TL_messageActionBotDescription class] forKey:[NSNumber numberWithInt:13]];
    
    [self.cs_classes setObject:[TL_localMessage_old34 class] forKey:[NSNumber numberWithInt:14]];
    [self.cs_classes setObject:[TL_localMessage class] forKey:[NSNumber numberWithInt:15]];
    
    [self.cs_classes setObject:[TL_conversation class] forKey:[NSNumber numberWithInt:16]];
    
    [self.cs_classes setObject:[TL_localEmptyMessage class] forKey:[NSNumber numberWithInt:17]];
    [self.cs_classes setObject:[TL_localMessageService class] forKey:[NSNumber numberWithInt:18]];
    
    for(NSNumber* number in [self.cs_classes allKeys]) {
        [self.cs_constuctors setObject:number forKey:[self.cs_classes objectForKey:number]];
    }

}


@end

