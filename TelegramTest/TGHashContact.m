//
//  TGContact.m
//  Telegram
//
//  Created by keepcoder on 28.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGHashContact.h"
#import <MtProtoKit/MTEncryption.h>

@interface TGHashContact ()
@property (nonatomic,strong) TLUser *user;
@end


@implementation TGHashContact

-(id)initWithHash:(NSString *)hash {
    if(self = [super init]) {
        _hashObject = hash;
    }
    
    return self;
}

-(id)initWithHash:(NSString *)hash user_id:(int)user_id {
    if(self = [self initWithHash:hash]) {
        _user_id = user_id;
    }
    
    return self;
}

-(NSString *)description {
    return _hashObject;
}

-(NSUInteger)hash {
    return [_hashObject hash];
}

-(BOOL)isEqual:(TGHashContact *)object {
    return [self.hashObject isEqualToString:object.hashObject];
}



-(TLUser *)user {
    if(!_user && _user_id != 0)
        _user = [[UsersManager sharedManager] find:_user_id];
    return _user;
}


@end
