//
//  TMTypingObject.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/30/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTypingObject.h"
#import "TGTimer.h"

@implementation TLSendMessageAction (Extension)

-(NSComparisonResult)compare:(TLSendMessageAction *)anotherObject {
    
    
    static NSArray *actions;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @[NSStringFromClass([TL_sendMessageTypingAction class]),
                    NSStringFromClass([TL_sendMessageUploadPhotoAction class]),
                    
                    NSStringFromClass([TL_sendMessageRecordVideoAction class]),
                    NSStringFromClass([TL_sendMessageUploadVideoAction class]),
                    
                    NSStringFromClass([TL_sendMessageRecordAudioAction class]),
                    NSStringFromClass([TL_sendMessageUploadAudioAction class]),
                    
                    NSStringFromClass([TL_sendMessageUploadDocumentAction class]),
                    NSStringFromClass([TL_sendMessageGeoLocationAction class]),
                    NSStringFromClass([TL_sendMessageChooseContactAction class]),
                    
                    ];
    });
    
    NSNumber *sidx = @([actions indexOfObject:NSStringFromClass(self.class)]);
    NSNumber *oidx = @([actions indexOfObject:NSStringFromClass(anotherObject.class)]);
    
    return [sidx compare:oidx];
    
}

@end




@implementation TGActionTyping

-(id)initWithAction:(TLSendMessageAction *)action time:(int)time user:(TLUser *)user {
    if(self = [super init]) {
        _action = action;
        _time = time;
        _user = user;
    }
    
    return self;
}

-(NSComparisonResult)compare:(TGActionTyping *)anotherObject {
    return [self.action compare:anotherObject.action];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ : %ld",NSStringFromClass(_action.class), _time];
}

@end


@interface TMTypingObject()
@property (nonatomic, strong) NSMutableDictionary *actions;
@property (nonatomic, weak) TL_conversation *conversation;
@property (nonatomic, strong) TGTimer *timer;
@end

@implementation TMTypingObject

- (id) initWithDialog:(TL_conversation *)dialog {
    self = [super init];
    if(self) {
        self.conversation = dialog;
        self.actions = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) addMember:(TLUser *)user withAction:(TLSendMessageAction *)action {
    
    TGActionTyping *taction = [[TGActionTyping alloc] initWithAction:action time:[[NSDate date] timeIntervalSince1970] + 5 user:user];
    
    
    NSMutableDictionary *actions = [self.actions objectForKey:@(user.n_id)];
    if(!actions)
    {
        actions = [[NSMutableDictionary alloc] init];
        [self.actions setObject:actions forKey:@(user.n_id)];
    }
    
    if(![action isKindOfClass:[TL_sendMessageCancelAction class]]) {
        NSUInteger count = actions.count;
        
        [actions setObject:taction forKey:NSStringFromClass(taction.action.class)];
        
        if(count != actions.count)
            [self performNotification];
        
        [self check];
    } else {
        [self.actions removeAllObjects];
        [self performNotification];
    }
    
   
    
    
}


-(void)check {
    
    [self.timer invalidate];
    self.timer = nil;
    
    self.timer = [[TGTimer alloc] initWithTimeout:3 repeat:YES completion:^{
        
        __block BOOL checkNext = NO;
        
        NSMutableArray *userActionsToRemove = [[NSMutableArray alloc] init];
        
        [self.actions enumerateKeysAndObjectsUsingBlock:^(NSNumber *userKey, NSMutableDictionary *obj, BOOL *stop) {
            
            NSMutableArray *actionsToRemove = [[NSMutableArray alloc] init];
            
            [obj enumerateKeysAndObjectsUsingBlock:^(NSString *key, TGActionTyping *typing, BOOL *stop) {
                
                if(typing.time < [[NSDate date] timeIntervalSince1970]) {
                    [actionsToRemove addObject:key];
                }
                
            }];
            
            [obj removeObjectsForKeys:actionsToRemove];
            
            if(obj.count > 0)
                checkNext = YES;
            else
                [userActionsToRemove addObject:userKey];
            
        }];
        
        
        [self.actions removeObjectsForKeys:userActionsToRemove];
        
        [self performNotification];

        if(!checkNext) {
            [self.timer invalidate];
            self.timer = nil;
        }
        
        
    } queue:[ASQueue globalQueue].nativeQueue];
    
    [self.timer start];
    
}

-(void)removeMember:(NSUInteger)uid {
    [ASQueue dispatchOnStageQueue:^{
        [self.actions removeObjectForKey:@(uid)];
        
        [self performNotification];
    }];
}

-(NSArray *)currentActions {
    
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    
    
    [self.actions enumerateKeysAndObjectsUsingBlock:^(NSNumber *userKey, NSMutableDictionary *obj, BOOL *stop) {
        
        NSArray *allObjects = obj.allValues;
        
        allObjects = [allObjects sortedArrayUsingSelector:@selector(compare:)];
        
        
        [actions addObject:allObjects[0]];
        
    }];
    
    return actions;
    
}

- (void) performNotification {
    [Notification perform:[Notification notificationNameByDialog:self.conversation action:@"typing"] data:@{@"users":[self currentActions]}];
}

- (NSArray *) writeArray {
    return self.actions.allKeys;
}

- (void) dealloc {
    [Notification removeObserver:self];
}

@end
