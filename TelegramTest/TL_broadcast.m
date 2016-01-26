//
//  TL_broadcast.m
//  Telegram
//
//  Created by keepcoder on 06.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TL_broadcast.h"

@implementation TL_broadcast

+(TL_broadcast *)createWithN_id:(int)n_id participants:(NSArray *)participants title:(NSString *)title date:(int)date {
    TL_broadcast *broadcast = [[TL_broadcast alloc] init];
    
    broadcast.n_id = n_id;
    broadcast.participants = [participants mutableCopy];
    broadcast.title = title;
    broadcast.date = date;
    
    return broadcast;
}

-(void)addParticipants:(NSArray *)ids {

    
    [ids enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([self.participants indexOfObject:obj] == NSNotFound)
            [self.participants addObject:obj];
    }];
    
    
    
    [[Storage manager] insertBroadcast:self];
    
    if(self.title.length == 0) {
        [Notification perform:BROADCAST_UPDATE_TITLE data:@{KEY_BROADCAST:self}]; 
    }
    
    
   
}

-(void)removeParticipant:(int)n_id {
    [self.participants removeObject:@(n_id)];
    
    [[Storage manager] insertBroadcast:self];
}

- (NSMutableArray *)inputContacts {
    NSMutableArray *input = [[NSMutableArray alloc] init];
    
    [self.participants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TLUser *user = [[UsersManager sharedManager] find:[obj intValue]];
        [input addObject:user.inputUser];
    }];
    
    return input;
}

- (NSMutableArray *)generateRandomIds {
    NSMutableArray *random = [[NSMutableArray alloc] initWithCapacity:self.participants.count];
    
    [self.participants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [random addObject:@(rand_long())];
    }];
    
    
    return random;
}

-(NSString *)partString {
    return [NSString stringWithFormat:self.participants.count > 1 ? NSLocalizedString(@"Broadcast.participantsTitle", nil) : NSLocalizedString(@"Broadcast.participantTitle", nil),self.participants.count];
}


- (void)serialize:(SerializedData *)stream {
	[stream writeInt:self.n_id];
    
	[stream writeInt:(int)self.participants.count];
	{
		NSInteger tl_count = [self.participants count];
		
		for(int i = 0; i < (int)tl_count; i++) {
			[stream writeInt:[self.participants[i] intValue]];
		}
	}
	[stream writeString:self.title];
    [stream writeInt:self.date];
}
- (void)unserialize:(SerializedData *)stream {
	self.n_id = [stream readInt];
    
	int count = [stream readInt];
	{
		if(!self.participants)
			self.participants = [[NSMutableArray alloc] init];
		for(int i = 0; i < count; i++) {
			
			[self.participants addObject:@([stream readInt])];
		}
	}
	
    self.title = [stream readString];
    
    self.date = [stream readInt];
}



DYNAMIC_PROPERTY(DIALOGTITLE);

- (NSAttributedString *) dialogTitle {
    
    
    NSString *title = [self title];
    
    if(title.length == 0)
    {
        title = [self partString];
    }
    
    
    NSMutableAttributedString *dialogTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [dialogTitleAttributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:chatIconAttachment()]];
    [dialogTitleAttributedString setSelectionAttachment:chatIconSelectedAttachment() forAttachment:chatIconAttachment()];
    
    [dialogTitleAttributedString appendString:title withColor:NSColorFromRGB(0x333333)];
    [dialogTitleAttributedString setSelectionColor:NSColorFromRGB(0xffffff) forColor:NSColorFromRGB(0x333333)];
    [dialogTitleAttributedString setFont:TGSystemFont(14) forRange:dialogTitleAttributedString.range];
    
    [self setDIALOGTITLE:dialogTitleAttributedString];
    
    return [self getDIALOGTITLE];
}

DYNAMIC_PROPERTY(TITLEFORMESSAGE);

- (NSAttributedString *) titleForMessage {
    
    NSString *title = [self title];
    
    if(title.length == 0)
    {
        title = [self partString];
    }
    
    NSMutableAttributedString *dialogTitleAttributedString = [[NSMutableAttributedString alloc] init];
    
    [dialogTitleAttributedString appendString:title withColor:NSColorFromRGB(0x222222)];
    [dialogTitleAttributedString setFont:TGSystemFont(14) forRange:dialogTitleAttributedString.range];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    [dialogTitleAttributedString addAttribute:NSParagraphStyleAttributeName value:style range:dialogTitleAttributedString.range];
    
    [self setTITLEFORMESSAGE:dialogTitleAttributedString];
    
    return [self getTITLEFORMESSAGE];
}

- (NSAttributedString *)titleForChatInfo {
    
    NSString *title = [self title];
    
    if(title.length == 0)
    {
        title = [self partString];
    }
    
    return [[NSAttributedString alloc] initWithString:title];
}

- (NSAttributedString *)statusAttributedString {
    return [[NSMutableAttributedString alloc] initWithString:@"string"];
}


static NSTextAttachment *chatIconAttachment() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_chat() imageWithInsets:NSEdgeInsetsMake(0, 1, 0, 4)]];
    });
    return instance;
}

static NSTextAttachment *chatIconSelectedAttachment() {
    static NSTextAttachment *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NSMutableAttributedString textAttachmentByImage:[image_chatHighlighted() imageWithInsets:NSEdgeInsetsMake(0, 1, 0, 4)]];
    });
    return instance;
}

-(void)setTitle:(NSString *)title {
    if(title.length > 50)
        title = [title substringToIndex:50];
    
    self->_title = title;
}


-(TL_conversation *)conversation {
    
    TL_conversation *conversation = [[DialogsManager sharedManager]find:self.n_id];
    
    if(!conversation) {
        conversation = [[Storage manager] selectConversation:[TL_peerBroadcast createWithChat_id:self.n_id]];
        
        [[DialogsManager sharedManager] add:@[conversation]];
    }
    
    return conversation;
}

- (NSAttributedString *)statusForMessagesHeaderView {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    
    NSMutableArray *names = [[NSMutableArray alloc] init];
    
    [self.participants enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        TLUser *user = [[UsersManager sharedManager] find:[obj intValue]];
        
        NSString *name = user.first_name.length == 0 ? user.last_name : user.first_name;
        
        [names addObject:name];
    }];
    
    
    [attributedString appendString:[names componentsJoinedByString:@", "] withColor:NSColorFromRGB(0xa9a9a9)];
    
    

    
    [attributedString setFont:TGSystemFont(12) forRange:attributedString.range];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:2];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    
    
    return attributedString;
}


@end
