//
//  TGForwardObject.m
//  Telegram
//
//  Created by keepcoder on 17.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGForwardObject.h"



@implementation TGForwardObject

-(id)initWithMessages:(NSArray *)messages {
    if(self = [super init]) {
        
        _messages = messages;
        
        
        NSMutableAttributedString *n = [[NSMutableAttributedString alloc] init];
        
        NSMutableArray *firstNames = [[NSMutableArray alloc] init];
        
        
        NSMutableArray *exception = [[NSMutableArray alloc] init];
        
        [messages enumerateObjectsUsingBlock:^(TL_localMessage  *obj, NSUInteger idx, BOOL *stop) {
            
            if([exception indexOfObject:obj.fromUser] == NSNotFound) {
                [firstNames addObject:obj.fromUser.first_name];
                [exception addObject:obj.fromUser];
            }
            
        }];
        
        
        [n appendString:[firstNames componentsJoinedByString:@", "] withColor:LINK_COLOR];
        
        [n setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13] forRange:n.range];
        
        _names = n;
        
        
        
         NSMutableAttributedString *d = [[NSMutableAttributedString alloc] init];
        
        [d appendString:[NSString stringWithFormat:@"%@ %lu %@", NSLocalizedString(@"Message.Action.Forwarding", nil), messages.count, messages.count == 1 ? NSLocalizedString(@"message", nil) : NSLocalizedString(@"messages", nil)] withColor:NSColorFromRGB(0x808080)];
        
        [d setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:d.range];
        
        _fwd_desc = d;
        

        
        
        
    }
    
    return self;
}

@end
