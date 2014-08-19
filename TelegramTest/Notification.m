//
//  Notification.m
//  TelegramTest
//
//  Created by keepcoder on 29.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "Notification.h"
#import "NSNotificationCenter+MainThread.h"
#import "TGDialog+Extensions.h"

@implementation Notification

NSString *const APP_RUN = @"APP_RUN";
NSString *const PROTOCOL_UPDATED = @"protocol_updated";
NSString *const AUTH_COMPLETE = @"auth_complete";


NSString *const MESSAGE_SEND_EVENT = @"MESSAGE_SEND_EVENT";
NSString *const MESSAGE_SENT_EVENT = @"MESSAGE_SENT_EVENT";
NSString *const MESSAGE_RECEIVE_EVENT = @"MESSAGE_RECEIVE_EVENT";
NSString *const MESSAGE_READ_EVENT = @"MESSAGE_READ_EVENT";
NSString *const MESSAGE_DELETE_EVENT = @"MESSAGE_DELETE_EVENT";

NSString *const MESSAGE_CHANGED_DSTATE = @"MESSAGE_CHANGED_DSTATE";

NSString *const MESSAGE_FLUSH_HISTORY = @"MESSAGE_FLUSH_HISTORY";

NSString *const DELETE_MESSAGE = @"DELETE_MESSAGE";

NSString *const MESSAGE_LIST_SEND = @"MESSAGE_LIST_SEND";
NSString *const MESSAGE_LIST_RECEIVE = @"MESSAGE_LIST_RECEIVE";
NSString *const MESSAGE_LIST_UPDATE_TOP = @"MESSAGE_LIST_UPDATE_TOP";
NSString *const MESSAGE_UPDATE_TOP_MESSAGE = @"MESSAGE_UPDATE_TOP_MESSAGE";

NSString *const MEDIA_RECEIVE = @"MEDIA_RECEIVE";

NSString *const USER_ONLINE_CHANGED = @"USER_ONLINE_CHANGED";

NSString *const USER_UPDATE_PHOTO = @"USER_UPDATE_PHOTO";
NSString *const USER_UPDATE_NAME = @"USER_UPDATE_NAME";
NSString *const USER_STATUS = @"USER_STATUS";
NSString *const USER_TYPING = @"USER_TYPING";

NSString *const USER_BLOCK = @"USER_BLOCK";
NSString *const USER_CHANGE_TYPE = @"USER_CHANGE_TYPE";

NSString *const CHAT_UPDATE_PHOTO = @"CHAT_UPDATE_PHOTO";
NSString *const CHAT_UPDATE_TITLE = @"CHAT_UPDATE_TITLE";
NSString *const CHAT_UPDATE_PARTICIPANTS = @"CHAT_UPDATE_PARTICIPANTS";
NSString *const CHAT_UPDATE_TYPE = @"CHAT_UPDATE_TYPE";

NSString *const CHAT_STATUS = @"CHAT_STATUS";
NSString *const BROADCAST_STATUS = @"BROADCAST_STATUS";

NSString *const BROADCAST_UPDATE_TITLE = @"BROADCAST_UPDATE_TITLE";

NSString *const PUSHNOTIFICATION_UPDATE = @"PUSHNOTIFICATION_UPDATE";

NSString *const MODAL_VIEW_SHOW = @"MODAL_VIEW_SHOW";
NSString *const KEY_MODAL_VIEW = @"KEY_MODAL_VIEW";


NSString *const DIALOG_UPDATE = @"DIALOG_UPDATE";
NSString *const DIALOG_DELETE = @"DIALOG_DELETE";
NSString *const DIALOG_MOVE_POSITION = @"DIALOG_MOVE_POSITION";

NSString *const DIALOG_TO_TOP = @"DIALOG_TO_TOP";
NSString *const DIALOG_CREATE_NEW = @"DIALOG_CREATE_NEW";
NSString *const DIALOGS_NEED_FULL_RESORT = @"DIALOGS_NEED_FULL_RESORT";
NSString *const DIALOGS_NEED_SHOW = @"DIALOGS_NEED_SHOW";


NSString *const CONTACTS_MODIFIED = @"CONTACTS_MODIFIED";
NSString *const CONTACTS_NOT_REGISTRED_READY = @"CONTACTS_NOT_REGISTRED_READY";



NSString *const FULLCHAT_LOADED = @"FULLCHAT_LOADED";

NSString *const KEY_PREVIEW_OBJECT = @"preview_object";

NSString *const KEY_USER = @"user";
NSString *const KEY_PREVIOUS = @"previous";
NSString *const KEY_STATUS = @"status";
NSString *const KEY_SHORT_UPDATE = @"short_update";
NSString *const KEY_CHAT_ID = @"chat_id";
NSString *const KEY_USER_ID = @"user_id";
NSString *const KEY_CONTACTS = @"contacts";
NSString *const KEY_CONTACTS_NOT_REGISTRED = @"not_registered_contacts";
NSString *const KEY_MESSAGE = @"message";
NSString *const KEY_CHAT = @"chat";
NSString *const KEY_BROADCAST = @"broadcast";
NSString *const KEY_PHOTO = @"photo";
NSString *const KEY_MESSAGE_ID_LIST = @"message_id_list";
NSString *const KEY_MESSAGE_LIST = @"message_list";
NSString *const KEY_DIALOG = @"dialog";
NSString *const KEY_POSITION = @"position";
NSString *const KEY_DIALOGS = @"dialogs";
NSString *const KEY_MEDIA = @"media";
NSString *const KEY_PEER_ID = @"peer_id";
NSString *const KEY_IS_MUTE = @"is_mute";
NSString *const KEY_PARTICIPANTS = @"participants";

NSString *const LOGOUT_EVENT = @"logout";


+(NSNotificationCenter *)center {
    static NSNotificationCenter *center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[NSNotificationCenter alloc] init];
    });
    return center;
}

+(void)addObserver:(id)target selector:(SEL)selector name:(NSString *)name {
    //[LoopingUtils runOnMainQueueAsync:^{
         [[self center] addObserver:target selector:selector name:name object:NULL];
   // }];
    

}

+(void)removeObserver:(id)target {
    //[LoopingUtils runOnMainQueueAsync:^{
         [[self center] removeObserver:target];
   // }];
    
}


+(void)perform:(NSString *)name object:(id)object {
    
    [[self center] postNotificationNameOnMainThread:name object:object userInfo:object ? @{name:object} : nil];
}

+ (NSString *) notificationNameByDialog:(TL_conversation *)dialog
                                   action:(NSString *) action {
    return [NSString stringWithFormat:@"%@_%d_%d_%d", action, dialog.type, dialog.peer.chat_id, dialog.peer.user_id];
}

+ (NSString *)notificationForUser:(TGUser *)user action:(NSString *)action {
     return [NSString stringWithFormat:@"user_%@_%d", action, user.n_id];
}

+ (NSString *) notificationNameForStatusUserId:(int)user_id {
    return [NSString stringWithFormat:@"user_status_%d", user_id];
}


+ (NSString *) notificationNameForStatusChatId:(int)chat_id {
    return [NSString stringWithFormat:@"chat_status_%d", chat_id];
}


+(void)perform:(NSString *)name data:(NSDictionary *)data {
    [[self center] postNotificationNameOnMainThread:name object:nil userInfo:data];
}


@end
