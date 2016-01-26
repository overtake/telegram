//
//  Notification.h
//  TelegramTest
//
//  Created by keepcoder on 29.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

extern NSString *const APP_RUN;
extern NSString *const PROTOCOL_UPDATED;
extern NSString *const AUTH_COMPLETE;
// в нотификации приходят userInfo в них находятся ключи с информацией, в основном имя ключа совпадает с первым префиксом ивента, то есть {MESSAGE}_SENT_EVENT собержит в себе KEY_MESSAGE (@"message").

extern NSString *const MESSAGE_SEND_EVENT; // событие проихсодит когда сообщение вроде как отправилось, просто поставлено в очередь на отправку
extern NSString *const MESSAGE_SENT_EVENT; // событие проихсодит когда сообщение отправено
extern NSString *const MESSAGE_RECEIVE_EVENT; // событие: пришло сообщение
extern NSString *const MESSAGE_UPDATE_MESSAGE_ID;
extern NSString *const MESSAGE_READ_EVENT; // сообщение прочитенно сообщение

extern NSString *const MESSAGE_CHANGED_DSTATE; // поменялось состояние отправления сообщения

extern NSString *const MESSAGE_DELETE_EVENT; // сообщение удалено
extern NSString *const MESSAGE_FLUSH_HISTORY; //удаление всей истории


extern NSString *const DELETE_MESSAGE;
extern NSString *const MESSAGE_LIST_RECEIVE; // пришло много сообщений
extern NSString *const MESSAGE_LIST_SEND;  //отправлен список сообщений
extern NSString *const MESSAGE_UPDATE_TOP_MESSAGE; // новое сообщение которое нужно поднять на вверх, нужно обновилть в диалогах // уже работает
extern NSString *const MESSAGE_LIST_UPDATE_TOP; // список новых сообщений которые нужно обновить в диалогах // уже работает

extern NSString *const MEDIA_RECEIVE;

//extern NSString *const MESSAGES_CHANGE_DIALOG;
extern NSString *const KEY_LAST_CONVRESATION_DATA;
extern NSString *const DIALOG_UPDATE; // просто обновить содержимое диалога
extern NSString *const DIALOG_TO_TOP; // надо поднять диалог на самый верх.
extern NSString *const DIALOG_DELETE; // надо поднять диалог на самый верх.
extern NSString *const DIALOG_MOVE_POSITION; // сменить позацию диалога

extern NSString *const DIALOGS_NEED_FULL_RESORT; // надо полностью обновить список всех диалогов (многое изменилось)
extern NSString *const DIALOG_CREATE_NEW; // создан новй диалог, надо его отобразить сверху
extern NSString *const DIALOGS_NEED_SHOW; // можно показать диалоги K
extern NSString *const CONTACTS_MODIFIED; // контакты модифицированны
extern NSString *const CONTACTS_SORT_CHANGED; // сортировка контактов обновлена
extern NSString *const CONTACTS_NOT_REGISTRED_READY; // список неразеганных контактов

extern NSString *const MODAL_VIEW_SHOW;
extern NSString *const KEY_MODAL_VIEW;


extern NSString *const FULLCHAT_LOADED; //загружен полный чат

extern NSString *const USER_ONLINE_CHANGED;

extern NSString *const USER_UPDATE_PHOTO;
extern NSString *const USER_TYPING;
extern NSString *const USER_STATUS;
extern NSString *const USER_UPDATE_NAME;
extern NSString *const USER_BLOCK;

extern NSString *const USER_CHANGE_TYPE;

extern NSString *const CHAT_UPDATE_PHOTO;
extern NSString *const CHAT_UPDATE_TITLE;
extern NSString *const BROADCAST_UPDATE_TITLE;
extern NSString *const CHAT_UPDATE_PARTICIPANTS;
extern NSString *const CHAT_UPDATE_TYPE;
extern NSString *const CHAT_STATUS;
extern NSString *const BROADCAST_STATUS;
extern NSString *const PUSHNOTIFICATION_UPDATE;

extern NSString *const UPDATE_MESSAGE_ITEM;

extern NSString *const UPDATE_WEB_PAGE_ITEMS;
extern NSString *const UPDATE_NEW_AUTH;
extern NSString *const UPDATE_WEB_PAGES;

extern NSString *const UPDATE_READ_CONTENTS;
extern NSString *const UPDATE_AUDIO_PLAYER_STATE;
extern NSString *const UPDATE_MESSAGE_ENTITIES;
extern NSString *const UPDATE_MESSAGE_GROUP_HOLE;
extern NSString *const UPDATE_MESSAGE_VIEWS;

extern NSString *const CHAT_FLAGS_UPDATED;

extern NSString *const KEY_PREVIEW_OBJECT;

extern NSString *const KEY_USER;
extern NSString *const KEY_PREVIOUS;
extern NSString *const KEY_STATUS;
extern NSString *const KEY_SHORT_UPDATE;
extern NSString *const KEY_CHAT_ID;
extern NSString *const KEY_USER_ID;
extern NSString *const KEY_CONTACTS;
extern NSString *const KEY_CONTACTS_NOT_REGISTRED;
extern NSString *const KEY_MESSAGE;
extern NSString *const KEY_CHAT;
extern NSString *const KEY_BROADCAST;
extern NSString *const KEY_PHOTO;
extern NSString *const KEY_MESSAGE_ID_LIST;
extern NSString *const KEY_MESSAGE_LIST;
extern NSString *const KEY_DATA;
extern NSString *const KEY_DIALOG;
extern NSString *const KEY_POSITION;
extern NSString *const KEY_DIALOGS;
extern NSString *const KEY_MEDIA;
extern NSString *const KEY_PEER_ID;
extern NSString *const KEY_IS_MUTE;
extern NSString *const KEY_PARTICIPANTS;
extern NSString *const KEY_GROUP_HOLE;
extern NSString *const KEY_WEBPAGE;
extern NSString *const KEY_MESSAGE_ID;
extern NSString *const KEY_RANDOM_ID;
extern NSString *const KEY_ORDER;
extern NSString *const KEY_STICKERSET;
extern NSString *const KEY_PRIVACY;
extern NSString *const PRIVACY_UPDATE;
extern NSString *const LOGOUT_EVENT;


extern NSString *const LAYOUT_CHANGED;
extern NSString *const UNREAD_COUNT_CHANGED;


extern NSString *const STICKERS_REORDER;
extern NSString *const STICKERS_NEW_PACK;
extern NSString *const STICKERS_ALL_CHANGED;



+ (void)addObserver:(id)target selector:(SEL)selector name:(NSString *)name;

+ (void)removeObserver:(id)target;

+ (NSString *) notificationNameByDialog:(TL_conversation *)dialog action:(NSString *) action;

+ (NSString *)notificationForUser:(TLUser *)user action:(NSString *)action;
//+ (NSString *) notificationNameForStatusUserId:(int)user_id;
//+ (NSString *) notificationNameForStatusChatId:(int)chat_id;


+ (void)perform:(NSString *)name object:(id)object;
+ (void)perform:(NSString *)name data:(NSDictionary *)data;

+(void)performOnStageQueue:(NSString *)name object:(id)object;
+(void)performOnStageQueue:(NSString *)name data:(NSDictionary *)data;

extern NSString *const USER_ACTIVITY_CONVERSATION;

@end
