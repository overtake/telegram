//
//  PrivacyArchiver.h
//  Telegram
//
//  Created by keepcoder on 19.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrivacyArchiver : NSObject<NSCoding>

typedef enum {
    PrivacyAllowTypeEverbody,
    PrivacyAllowTypeContacts,
    PrivacyAllowTypeNobody
} PrivacyAllowType;

extern NSString *const kStatusTimestamp;


@property (nonatomic,strong) NSArray *allowUsers;
@property (nonatomic,strong) NSArray *disallowUsers;
@property (nonatomic,assign) PrivacyAllowType allowType;

@property (nonatomic,strong,readonly) NSString *privacyType;

-(id)initWithType:(PrivacyAllowType)type allowUsers:(NSArray *)allowUsers disallowUsers:(NSArray *)disallowUsers privacyType:(NSString *)privacyType;

+(PrivacyArchiver *)privacyForType:(NSString *)type;


+(PrivacyArchiver *)privacyFromRules:(NSArray *)rules forKey:(NSString *)key;

-(NSArray *)rules;

- (void)_save;
@end
