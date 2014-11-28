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


- (void) fullReload;


- (void) remoteCheckContacts;

- (void) insertContact:(TLContact *)contact insertToDB:(BOOL)insertToDB;

- (void) removeContact:(TLContact *)contact removeFromDB:(BOOL)removeFromDB;

- (void) importContact:(TL_inputPhoneContact *)contact callback:(void (^)(BOOL isAdd, TL_importedContact *contact, TLUser *user))callback;

- (void) deleteContact:(TLUser *)user completeHandler:(void (^)(BOOL result))compleHandler;

-(void)getStatuses:(dispatch_block_t)callback;
@end
