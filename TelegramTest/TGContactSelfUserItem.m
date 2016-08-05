//
//  TGContactSelfUserItem.m
//  Telegram
//
//  Created by keepcoder on 05/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGContactSelfUserItem.h"

@implementation TGContactSelfUserItem

-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        
    }
    
    return self;
}

-(Class)viewClass {
    return NSClassFromString(@"TGContactSelfUserRowView");
}

-(int)height {
    return 60;
}

-(NSUInteger)hash {
    return [UsersManager currentUserId];
}

@end
