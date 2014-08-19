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

-(void)syncContacts:(void (^)(void))callback;

- (void) fullReload;


- (void) remoteCheckContacts;

- (void) insertContact:(TGContact *)contact insertToDB:(BOOL)insertToDB;

- (void) removeContact:(TGContact *)contact removeFromDB:(BOOL)removeFromDB;

- (void) importContact:(TL_inputPhoneContact *)contact callback:(void (^)(BOOL isAdd, TL_importedContact *contact, TGUser *user))callback;

- (void) deleteContact:(TGUser *)user completeHandler:(void (^)(BOOL result))compleHandler;
@end
