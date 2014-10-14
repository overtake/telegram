//
//  TGUserCategory.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/18/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGUserCategory.h"
#import "NSString+Extended.h"
#import "RMPhoneFormat.h"
#import "TGUserStatusCategory.h"
#import "TGDateUtils.h"


@implementation TGUser (Category)

/*
      TYPE
*/


DYNAMIC_PROPERTY(DType);

- (TGUserType)type {
    NSNumber *type = [self getDType];
    if(!type)
        type = [NSNumber numberWithInt:[self rebuildType]];
    return [type intValue];
}

- (void)setType:(TGUserType)type {
    [self setDType:[NSNumber numberWithInt:type]];
}

- (TGUserType)rebuildType {
    int type;
    if([self isKindOfClass:[TL_userContact class]])
        type = TGUserTypeContact;
    else if([self isKindOfClass:[TL_userDeleted class]])
        type = TGUserTypeDeleted;
    else if([self isKindOfClass:[TL_userEmpty class]])
        type = TGUserTypeEmpty;
    else if([self isKindOfClass:[TL_userForeign class]])
        type = TGUserTypeForeign;
    else if([self isKindOfClass:[TL_userSelf class]])
        type = TGUserTypeSelf;
    else
        type = TGUserTypeRequest;
    [self setType:type];
    
    return type;
}

/*
Online
*/
- (BOOL)isOnline {
    if(self.n_id == UsersManager.currentUserId)
        return YES;
    
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
        return NSLocalizedString(@"Account.Invisible", nil);
    
    if(time == 0)
        return NSLocalizedString(@"Account.Offline", nil);
    
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
    if(self.type == TGUserTypeRequest) {
        fullNameOrPhone = self.phoneWithFormat;
        colorByNameOrPhone = BLUE_UI_COLOR;
    } else if(self.type == TGUserTypeForeign || self.type == TGUserTypeDeleted || self.type == TGUserTypeEmpty) {
        colorByNameOrPhone = BLUE_UI_COLOR;
    } else if(self.type == TGUserTypeSelf) {
        colorByNameOrPhone = BLUE_UI_COLOR;
    } else {
        colorByNameOrPhone = NSColorFromRGB(0x333333);
    }
    
    //Dialogs
    NSMutableAttributedString *dialogTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [dialogTitleAttributedString appendString:fullName withColor:colorByNameOrPhone];
    [dialogTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
    [dialogTitleAttributedString setSelectionColor:NSColorFromRGB(0xfffffe) forColor:BLUE_UI_COLOR];
    [dialogTitleAttributedString setSelectionColor:NSColorFromRGB(0xfffffd) forColor:BLUE_UI_COLOR];

    [dialogTitleAttributedString setFont:[NSFont fontWithName:@"Helvetica" size:14] forRange:dialogTitleAttributedString.range];
    [self setDIALOGTITLE:dialogTitleAttributedString];
    
    NSMutableAttributedString *dialogEncryptedTitleAttributedString = [[NSMutableAttributedString alloc] init];
    [dialogEncryptedTitleAttributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:encryptedIconAttachment()]];
    [dialogEncryptedTitleAttributedString setSelectionAttachment:encryptedIconSelectedAttachment() forAttachment:encryptedIconAttachment()];
    
    [dialogEncryptedTitleAttributedString appendString:fullNameOrPhone withColor:DARK_GREEN];
    [dialogEncryptedTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:DARK_GREEN];
    [dialogEncryptedTitleAttributedString setFont:[NSFont fontWithName:@"Helvetica" size:14] forRange:dialogEncryptedTitleAttributedString.range];
    [self setDIALOGTITLEENCRYPTED:dialogEncryptedTitleAttributedString];
    
    
    NSMutableAttributedString *chatInfoTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [chatInfoTitleAttributedString appendString:fullName withColor:NSColorFromRGB(0x222222)];
    [chatInfoTitleAttributedString setSelectionColor:NSColorFromRGB(0xaaaaaa) forColor:NSColorFromRGB(0x222222)];
    [chatInfoTitleAttributedString setFont:[NSFont fontWithName:@"Helvetica" size:12.5] forRange:chatInfoTitleAttributedString.range];
    [self setCHATINFOTITLE:chatInfoTitleAttributedString];
    
    
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
    [profileAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:18] forRange:profileAttributedString.range];
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
        
        [str setFont:[NSFont fontWithName:@"Helvetica-Light" size:12] forRange:range];
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
        [str setSelectionColor:NSColorFromRGBWithAlpha(0xaeaeae, 0.5) forColor:NSColorFromRGB(0xaeaeae)];
        [str setSelectionColor:NSColorFromRGBWithAlpha(0x3395cc, 0.5) forColor:BLUE_UI_COLOR];

        
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
            range = [str appendString:NSLocalizedString(@"Account.Online", nil) withColor:NSColorFromRGB(0x999999)];
        } else {
            range = [str appendString:string withColor:NSColorFromRGB(0x999999)];
        }
        
        [str setFont:[NSFont fontWithName:@"HelveticaNeue" size:12.5f] forRange:range];
        
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


- (TGInputUser *)inputUser {
    switch (self.type) {
        case TGUserTypeContact:
            return [TL_inputUserContact createWithUser_id:self.n_id];
            break;
        case TGUserTypeDeleted:
            return [TL_inputUserEmpty create];
            break;
        case TGUserTypeEmpty:
            return [TL_inputUserEmpty create];
            break;
        case TGUserTypeForeign:
            return [TL_inputUserForeign createWithUser_id:self.n_id access_hash:self.access_hash];
        case TGUserTypeRequest:
            return [TL_inputUserForeign createWithUser_id:self.n_id access_hash:self.access_hash];
        case TGUserTypeSelf:
            return [TL_inputUserSelf create];
        default:
            return [TL_inputUserEmpty create];
            break;
    }
}

-(TGInputPeer *)inputPeer {
    if([self isKindOfClass:[TL_userContact class]]) {
        return [TL_inputPeerContact createWithUser_id:self.n_id];
    }
    return [TL_inputPeerForeign createWithUser_id:self.n_id access_hash:self.access_hash];
}

@end
