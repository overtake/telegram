//
//  TGMessageCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 2/27/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGMessageCategory.h"
#import "TL_peerSecret.h"
#import "TGMessage+Extensions.h"
#import "HistoryFilter.h"
@implementation TGMessage (Category)


DYNAMIC_PROPERTY(DDialog);

- (TL_conversation *)dialog {
    
    TL_conversation *dialog = [self getDDialog];
    
    if(!dialog) {
         dialog = [[DialogsManager sharedManager] find:self.peer_id];
        [self setDDialog:dialog];
    }
    
    
    
    if(!dialog) {
        dialog = [[Storage manager] selectConversation:self.peer];
        
        if(!dialog)
            dialog = [[DialogsManager sharedManager] createDialogForMessage:self];
        else
            [[DialogsManager sharedManager] add:@[dialog]];
        
        [self setDDialog:dialog];
    }
    
    
    
    return dialog;
}

-(int)filterType {
    int mask = HistoryFilterNone;
    
    if([self.media isKindOfClass:[TL_messageMediaEmpty class]]) {
        mask|=HistoryFilterText;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaAudio class]]) {
        mask|=HistoryFilterAudio;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaDocument class]]) {
        mask|=HistoryFilterDocuments;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaVideo class]]) {
        mask|=HistoryFilterVideo;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaContact class]]) {
        mask|=HistoryFilterContact;
    }
    
    if([self.media isKindOfClass:[TL_messageMediaPhoto class]]) {
        mask|=HistoryFilterPhoto;
    }

    return mask;
    
}

@end
