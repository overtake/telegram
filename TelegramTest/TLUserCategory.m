//
//  TLUserCategory.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/18/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLUserCategory.h"
#import "NSString+Extended.h"
#import "RMPhoneFormat.h"
#import "TLUserStatusCategory.h"
#import "TGDateUtils.h"


@implementation TLUser (Category)

/*
      TYPE
*/


DYNAMIC_PROPERTY(DType);

- (TLUserType)type {
    NSNumber *type = [self getDType];
    if(!type)
        type = [NSNumber numberWithInt:[self rebuildType]];
    return [type intValue];
}

- (void)setType:(TLUserType)type {
    [self setDType:[NSNumber numberWithInt:type]];
}

- (TLUserType)rebuildType {
    int type;
    
    
    if([self isKindOfClass:[TL_userContact class]])
        type = TLUserTypeContact;
    else if([self isKindOfClass:[TL_userDeleted class]])
        type = TLUserTypeDeleted;
    else if([self isKindOfClass:[TL_userEmpty class]])
        type = TLUserTypeEmpty;
    else if([self isKindOfClass:[TL_userForeign class]])
        type = TLUserTypeForeign;
    else if([self isKindOfClass:[TL_userSelf class]])
        type = TLUserTypeSelf;
    else
        type = TLUserTypeRequest;
    [self setType:type];
    
    return type;
}

/*
Online
*/
- (BOOL)isOnline {
    return [[MTNetwork instance] getTime] < self.status.lastSeenTime;
}

- (BOOL)isBlocked {
    return [[BlockedUsersManager sharedManager] isBlocked:self.n_id];
}

- (int)lastSeenTime {
    return self.status.lastSeenTime;
}

- (NSString *)lastSeen {
    if([self isOnline])
        return NSLocalizedString(@"Account.Online", nil);
    
    int time = self.lastSeenTime;
    if(time == -1)
        return  NSLocalizedString(@"LastSeen.longTimeAgo", nil);
    
    if(time == 0) {
        
        if(self.status.class == [TL_userStatusRecently class]) {
            return NSLocalizedString(@"LastSeen.Recently", nil);
        }
        if(self.status.class == [TL_userStatusLastWeek class]) {
            return NSLocalizedString(@"LastSeen.Weekly", nil);
        }
        if(self.status.class == [TL_userStatusLastMonth class]) {
            return NSLocalizedString(@"LastSeen.Monthly", nil);
        }

        return  NSLocalizedString(@"LastSeen.longTimeAgo", nil);
    }
    
    
    time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    return  [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Time.last_seen", nil), [TGDateUtils stringForRelativeLastSeen:time]];
}

DYNAMIC_PROPERTY(SEEN_UPDATE);

- (int)lastSeenUpdate {
    return [[self getSEEN_UPDATE] intValue];
}

- (void)setLastSeenUpdate:(int)seenUpdate {
    [self setSEEN_UPDATE:@(seenUpdate)];
}
/*
 Names
 */




- (void) rebuildNames {
    
    
    
    
    //Fullname
    NSString *fullName = [[[[NSString stringWithFormat:@"%@ %@", self.first_name, self.last_name] trim] singleLine] htmlentities];
    NSString *fullNameFull = fullName;
    if(fullName.length > 30)
        fullName = [fullName substringToIndex:30];
    
    [self setDFullName:fullName];
    
    
    NSString *fullNameOrPhone = fullName;
    
    NSColor *colorByNameOrPhone;
    if(self.type == TLUserTypeRequest) {
        fullNameOrPhone = self.phoneWithFormat;
        colorByNameOrPhone = BLUE_UI_COLOR;
    } else if(self.type == TLUserTypeForeign || self.type == TLUserTypeDeleted || self.type == TLUserTypeEmpty) {
        colorByNameOrPhone = BLUE_UI_COLOR;
    } else if(self.type == TLUserTypeSelf) {
        colorByNameOrPhone = BLUE_UI_COLOR;
    } else {
        colorByNameOrPhone = NSColorFromRGB(0x333333);
    }
    
    //Dialogs
    NSMutableAttributedString *dialogTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [dialogTitleAttributedString appendString:fullName withColor:colorByNameOrPhone];
    [dialogTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
    [dialogTitleAttributedString setSelectionColor:NSColorFromRGB(0xfffffe) forColor:BLUE_UI_COLOR];
    
    

    [dialogTitleAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:dialogTitleAttributedString.range];
    [self setDIALOGTITLE:dialogTitleAttributedString];
    
    NSMutableAttributedString *dialogEncryptedTitleAttributedString = [[NSMutableAttributedString alloc] init];
    [dialogEncryptedTitleAttributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:encryptedIconAttachment()]];
    [dialogEncryptedTitleAttributedString setSelectionAttachment:encryptedIconSelectedAttachment() forAttachment:encryptedIconAttachment()];
    
    [dialogEncryptedTitleAttributedString appendString:fullNameOrPhone withColor:DARK_GREEN];
    [dialogEncryptedTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:DARK_GREEN];
    [dialogEncryptedTitleAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:dialogEncryptedTitleAttributedString.range];
    [self setDIALOGTITLEENCRYPTED:dialogEncryptedTitleAttributedString];
    
    
    NSMutableAttributedString *chatInfoTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [chatInfoTitleAttributedString appendString:fullName withColor:DARK_BLACK];
    [chatInfoTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:DARK_BLACK];
    
    [chatInfoTitleAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:12.5] forRange:chatInfoTitleAttributedString.range];
    [self setCHATINFOTITLE:chatInfoTitleAttributedString];
    
    
    NSMutableAttributedString *userNameTitle = [[NSMutableAttributedString alloc] init];
    
    [userNameTitle appendString:[NSString stringWithFormat:@"%@%@",self.username.length > 0 ? @"@" : @"",self.username] withColor:GRAY_TEXT_COLOR];
    [userNameTitle setSelectionColor:NSColorFromRGB(0xffffff) forColor:GRAY_TEXT_COLOR];
    
    [userNameTitle setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:userNameTitle.range];
    [self setUserNameTitle:userNameTitle];
    
    
    NSMutableAttributedString *userNameProfileTitle = [[NSMutableAttributedString alloc] init];
    
    [userNameProfileTitle appendString:[NSString stringWithFormat:@"@%@",self.username] withColor:NSColorFromRGB(0x333333)];
    [userNameProfileTitle setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
    
    
    [userNameProfileTitle setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:14] forRange:userNameProfileTitle.range];
    [self setUserNameProfileTitle:userNameProfileTitle];
    
    
    
    NSMutableAttributedString *userNameSearchTitle = [[NSMutableAttributedString alloc] init];
    
    [userNameSearchTitle appendString:[NSString stringWithFormat:@"@%@",self.username] withColor:BLUE_UI_COLOR];
    [userNameSearchTitle setSelectionColor:NSColorFromRGB(0xffffff) forColor:BLUE_UI_COLOR];
    
    
    [userNameSearchTitle setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:userNameSearchTitle.range];
    [self setUserNameSearchTitle:userNameSearchTitle];
    
    //Message Tite
    
    NSMutableAttributedString *titleForMessageAttributedString = [[NSMutableAttributedString alloc] init];
    [titleForMessageAttributedString appendString:fullNameOrPhone withColor:NSColorFromRGB(0x222222)];
    [titleForMessageAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:titleForMessageAttributedString.range];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    [titleForMessageAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:titleForMessageAttributedString.range];
    [self setTITLE_FOR_MESSAGE:titleForMessageAttributedString];
    
    
    NSMutableAttributedString *profileAttributedString = [[NSMutableAttributedString alloc] init];
    [profileAttributedString appendString:fullNameOrPhone withColor:NSColorFromRGB(0x222222)];
    [profileAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:15] forRange:profileAttributedString.range];
    [profileAttributedString setAlignment:NSLeftTextAlignment range:profileAttributedString.range];
    [self setProfileTitle:profileAttributedString];
    
    NSMutableAttributedString *encryptedTitleForMessageAttributedString = [[NSMutableAttributedString alloc] init];
    [encryptedTitleForMessageAttributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:encryptedIconAttachmentBlack()]];
    [encryptedTitleForMessageAttributedString appendString:fullNameFull withColor:DARK_BLACK];
    [encryptedTitleForMessageAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:encryptedTitleForMessageAttributedString.range];
    [encryptedTitleForMessageAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:encryptedTitleForMessageAttributedString.range];
    [self setENCRYPTED_TITLE_FOR_MESSAGE:encryptedTitleForMessageAttributedString];
}

static NSTextAttachment *encryptedIconAttachment() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_secret() imageWithInsets:NSEdgeInsetsMake(0, 2, 0, 5)]];
    });
    return instance;
}

static NSTextAttachment *encryptedIconAttachmentBlack() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_secretBlack() imageWithInsets:NSEdgeInsetsMake(0, 2, 0, 5)]];
    });
    return instance;
}

static NSTextAttachment *encryptedIconSelectedAttachment() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_secretHiglighted() imageWithInsets:NSEdgeInsetsMake(0, 2, 0, 5)]];
    });
    return instance;
}


DYNAMIC_PROPERTY(UserNameTitle);
DYNAMIC_PROPERTY(UserNameProfileTitle);
DYNAMIC_PROPERTY(UserNameSearchTitle)

DYNAMIC_PROPERTY(CHATINFOTITLE);

DYNAMIC_PROPERTY(DIALOGTITLE);
DYNAMIC_PROPERTY(DIALOGTITLEENCRYPTED);

DYNAMIC_PROPERTY(ProfileTitle);

- (NSAttributedString *)dialogTitle {
    return [self getDIALOGTITLE];
}

- (NSAttributedString *)profileTitle {
    return [self getProfileTitle];
}

- (NSAttributedString *)dialogTitleEncrypted {
    return [self getDIALOGTITLEENCRYPTED];
}

- (NSAttributedString *)chatInfoTitle {
    return [self getCHATINFOTITLE];
}


- (NSAttributedString *)userNameTitle {
    return [self getUserNameTitle];
}

- (NSAttributedString *)userNameProfileTitle {
    return [self getUserNameProfileTitle];
}

- (NSAttributedString *)userNameSearchTitle {
    return [self getUserNameSearchTitle];
}

DYNAMIC_PROPERTY(TITLE_FOR_MESSAGE);
DYNAMIC_PROPERTY(ENCRYPTED_TITLE_FOR_MESSAGE);

- (NSAttributedString *) titleForMessage {
    return [self getTITLE_FOR_MESSAGE];
}

- (NSAttributedString *) encryptedTitleForMessage {
    return [self getENCRYPTED_TITLE_FOR_MESSAGE];
}




DYNAMIC_PROPERTY(DFullName);

- (NSString *)fullName {
    return [self getDFullName];
}

/*
 Phone
 */

- (NSString *)phoneWithFormat {
    if(!self.phone.length)
        return NSLocalizedString(@"User.Hidden", nil);
    
    return [RMPhoneFormat formatPhoneNumber:[NSString stringWithFormat:@"+%@", self.phone]];
}



/*
Statuses
 */

- (void)rebuidStatuses {
    [self setSTATUS_MESSAGES_HEADER_VIEW:nil];
//    [self statusForMessagesHeaderView];
}

- (NSAttributedString *)statusAttributedString {
    return [[NSMutableAttributedString alloc] initWithString:@"string"];
}



DYNAMIC_PROPERTY(STATUS_MESSAGES_HEADER_VIEW);

- (NSAttributedString *)statusForMessagesHeaderView {
    NSMutableAttributedString *str = [self getSTATUS_MESSAGES_HEADER_VIEW];
    if(!str) {
        str = [[NSMutableAttributedString alloc] init];
        NSString *string = self.lastSeen;
        NSRange range;
        if([string isEqualToString:NSLocalizedString(@"Account.Online", nil)]) {
            range = [str appendString:NSLocalizedString(@"Account.Online", nil) withColor:BLUE_UI_COLOR];
        } else {
            range = [str appendString:string withColor:NSColorFromRGB(0xa9a9a9)];
        }
        
        [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:range];
//        [self setSTATUS_MESSAGES_HEADER_VIEW:str];
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:2];
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
    return str;
}

- (NSAttributedString *)statusForUserInfoView {
    NSMutableAttributedString *str;
    if(!str) {
        str = [[NSMutableAttributedString alloc] init];
        NSString *string = self.lastSeen;
        NSRange range;
        if([string isEqualToString:NSLocalizedString(@"Account.Online", nil)]) {
            range = [str appendString:NSLocalizedString(@"Account.Online", nil) withColor:BLUE_UI_COLOR];
        } else {
            range = [str appendString:string withColor:NSColorFromRGB(0xa1a1a1)];
        }
        
        [str setFont:[NSFont fontWithName:@"Helvetica-Light" size:12.5] forRange:range];
    }
    return str;
}

- (NSAttributedString *)statusForSearchTableView {
    NSMutableAttributedString *str;
    if(!str) {
        str = [[NSMutableAttributedString alloc] init];
        NSString *string = self.lastSeen;
        NSRange range;
        if([string isEqualToString:NSLocalizedString(@"Account.Online", nil)]) {
            range = [str appendString:NSLocalizedString(@"Account.Online", nil) withColor:BLUE_UI_COLOR];
        } else {
            range = [str appendString:string withColor:NSColorFromRGB(0x9b9b9b)];
        }
        
        [str setSelectionColor:NSColorFromRGB(0xffffff) forColor:BLUE_UI_COLOR];
        [str setSelectionColor:NSColorFromRGB(0xfffffe) forColor:NSColorFromRGB(0x9b9b9b)];
        [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:13] forRange:range];
    }
    return str;
}

- (NSAttributedString *)statusForGroupInfo {
    NSMutableAttributedString *str;
    if(!str) {
        str = [[NSMutableAttributedString alloc] init];
        [str setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0xaeaeae)];
        [str setSelectionColor:NSColorFromRGB(0xffffff) forColor:GRAY_TEXT_COLOR];
        
        NSString *string = self.lastSeen;
        NSRange range;
        if([string isEqualToString:NSLocalizedString(@"Account.Online", nil)]) {
            range = [str appendString:NSLocalizedString(@"Account.Online", nil) withColor:BLUE_UI_COLOR];
        } else {
            range = [str appendString:string withColor:NSColorFromRGB(0xaeaeae)];
        }
        
        [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:12.5f] forRange:range];
    }
    return str;
}


- (NSAttributedString *)statusForProfile {
    NSMutableAttributedString *str;
    if(!str) {
        str = [[NSMutableAttributedString alloc] init];
        
        NSString *string = self.lastSeen;
        NSRange range;
        if([string isEqualToString:NSLocalizedString(@"Account.Online", nil)]) {
            range = [str appendString:NSLocalizedString(@"Account.Online", nil) withColor:GRAY_TEXT_COLOR];
        } else {
            range = [str appendString:string withColor:GRAY_TEXT_COLOR];
        }
        
        [str setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:14] forRange:range];
        
        [str setAlignment:NSLeftTextAlignment range:range];
    }
    return str;
}



- (NSString *) dialogFullName {
    
    NSString *userName = [self.first_name trim];
    
    if(userName.length == 0) {
        userName = [self.last_name trim];
    }
    
    if(userName.length == 0) {
        userName = NSLocalizedString(@"User.Deleted", nil);
    }
    
    
    userName = [userName singleLine];
    
    if(userName.length > 30)
        userName = [userName substringToIndex:30];
    
    
    return userName;
}

- (TL_conversation *)dialog {
    TL_conversation *dialog = [[DialogsManager sharedManager] find:self.n_id];
    if(!dialog) {
        dialog = [[DialogsManager sharedManager] createDialogForUser:self];
    }
    return dialog;
}


- (TLInputUser *)inputUser {
    switch (self.type) {
        case TLUserTypeContact:
            return [TL_inputUserContact createWithUser_id:self.n_id];
            break;
        case TLUserTypeDeleted:
            return [TL_inputUserEmpty create];
            break;
        case TLUserTypeEmpty:
            return [TL_inputUserEmpty create];
            break;
        case TLUserTypeForeign:
            return [TL_inputUserForeign createWithUser_id:self.n_id access_hash:self.access_hash];
        case TLUserTypeRequest:
            return [TL_inputUserForeign createWithUser_id:self.n_id access_hash:self.access_hash];
        case TLUserTypeSelf:
            return [TL_inputUserSelf create];
        default:
            return [TL_inputUserEmpty create];
            break;
    }
}

-(id)copy {
    switch (self.type) {
        case TLUserTypeContact:
            return [TL_userContact createWithN_id:self.n_id first_name:self.first_name last_name:self.last_name username:self.username access_hash:self.access_hash phone:self.phone photo:self.photo status:self.status];
            break;
        case TLUserTypeDeleted:
            return [TL_userDeleted createWithN_id:self.n_id first_name:self.first_name last_name:self.last_name username:self.username];
            break;
        case TLUserTypeEmpty:
            return [TL_userEmpty createWithN_id:self.n_id];
            break;
        case TLUserTypeForeign:
            return [TL_userForeign createWithN_id:self.n_id first_name:self.first_name last_name:self.last_name username:self.username access_hash:self.access_hash photo:self.photo status:self.status];
        case TLUserTypeRequest:
            return [TL_userRequest createWithN_id:self.n_id first_name:self.first_name last_name:self.last_name username:self.username access_hash:self.access_hash phone:self.phone photo:self.photo status:self.status];
        case TLUserTypeSelf:
            return [TL_userSelf createWithN_id:self.n_id first_name:self.first_name last_name:self.last_name username:self.username phone:self.phone photo:self.photo status:self.status];
        default:
            return [TL_userEmpty createWithN_id:self.n_id];
            break;
    }
}

-(BOOL)isEqual:(id)object {
    return [object isKindOfClass:[TLUser class]] ? [(TLUser *)object n_id] == self.n_id : object == self;
}

-(TLInputPeer *)inputPeer {
    if([self isKindOfClass:[TL_userContact class]]) {
        return [TL_inputPeerContact createWithUser_id:self.n_id];
    }
    return [TL_inputPeerForeign createWithUser_id:self.n_id access_hash:self.access_hash];
}

- (TL_contact *)contact {
    return [[NewContactsManager sharedManager] find:self.n_id];
}

@end
