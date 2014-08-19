//
//  TMNameTextField.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/26/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMTextField.h"
#import "TL_broadcast.h"
typedef enum {
    TMNameTextFieldChat,
    TMNameTextFieldUser,
    TMNameTextFieldEncryptedChat,
    TMNameTextFieldBroadcast
} TMNameTextFieldType;

@class TMNameTextField;

@protocol TMNameTextFieldProtocol <NSObject>

- (void) TMNameTextFieldDidChanged:(TMNameTextField *)textField;

@end

@interface TMNameTextField : TMTextField

@property (nonatomic,strong) NSString *selectText;
@property (nonatomic,assign,readonly) NSRange searchRange;

@property (nonatomic) TMNameTextFieldType type;
@property (nonatomic, strong) id<TMNameTextFieldProtocol> nameDelegate;

@property (nonatomic, strong) TGUser *user;
@property (nonatomic, strong) TGChat *chat;
@property (nonatomic, strong) TL_broadcast *broadcast;

@property (nonatomic) SEL selector;
@property (nonatomic) SEL encryptedSelector;

@property (nonatomic) BOOL selected;

- (void) setUser:(TGUser *)user isEncrypted:(BOOL)isEncrypted;

- (void)update;
@end
