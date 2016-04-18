//
//  SelectUserItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 21.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "SelectUserItem.h"
#import "TLUserCategory.h"
@implementation SelectUserItem

- (id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {

      
        if([object isKindOfClass:[TLUser class]]) {
            _user = object;
        } else if([object isKindOfClass:[TLChat class]]) {
            _chat = object;
        }
        
        
    }
    return self;
}


-(id)copy {
    return [[SelectUserItem alloc] initWithObject:self.object];
}

-(id)object {
    return _user ? _user : _chat;
}

-(BOOL)acceptSearchWithString:(NSString *)searchString {
    if(self.chat != nil) {
        return [self.chat.title searchInStringByWordsSeparated:searchString];
    } else {
        return [[self.user fullName] searchInStringByWordsSeparated:searchString];
    }
}

-(NSUInteger)hash {
    return _user ? _user.n_id : -_chat.n_id;
}

@end
