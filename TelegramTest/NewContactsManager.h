//
//  NewContactsManager.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharedManager.h"
typedef enum {
    ContactsStateLoading,
    ContactsStateSync
} ContactsState;

@interface NewContactsManager : SharedManager

-(void)iCloudSync;

- (void) fullReload;

- (void) insertContact:(TLContact *)contact;

- (void) removeContact:(TLContact *)contact;

- (void) importContact:(TL_inputPhoneContact *)contact callback:(void (^)(BOOL isAdd, TL_importedContact *contact, TLUser *user))callback;

- (void) deleteContact:(TLUser *)user completeHandler:(void (^)(BOOL result))compleHandler;

-(void)getStatuses:(dispatch_block_t)callback;
@end
