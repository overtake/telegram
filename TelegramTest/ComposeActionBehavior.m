
//
//  ComposeActionObserver.m
//  Telegram
//
//  Created by keepcoder on 28.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ComposeActionBehavior.h"

@implementation ComposeActionBehavior

-(id)initWithAction:(ComposeAction *)action {
    if(self = [super init]) {
        _action = action;
    }
    
    return self;
}

-(void)composeDidChangeSelected {
    
}
-(void)composeDidCancel {
    
}
-(void)composeDidDone {
    
}



-(NSString *)leftEditTitle {
    return NSLocalizedString(@"Compose.Cancel", nil);
}
-(NSString *)rightEditTitle {
    return NSLocalizedString(@"Compose.Done", nil);
}

-(NSString *)doneTitle {
    return NSLocalizedString(@"Compose.Done", nil);
}



-(NSAttributedString *)centerTitle {
    return [[NSMutableAttributedString alloc] initWithString:@"Title"];
}

-(NSUInteger)limit {
    return 1;
}

@end
