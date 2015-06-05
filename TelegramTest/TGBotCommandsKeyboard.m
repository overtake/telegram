//
//  TGBotCommandsKeyboard.m
//  Telegram
//
//  Created by keepcoder on 05.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGBotCommandsKeyboard.h"


@interface TGBotKeyboardItemView : TMView
@property (nonatomic,strong) TLKeyboardButton *keyboardButton;
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TMTextField *textField;
@end


@implementation TGBotKeyboardItemView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.wantsLayer = YES;
        self.layer.cornerRadius = 4;
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        self.layer.borderColor = GRAY_BORDER_COLOR.CGColor;
        self.layer.borderWidth = 1;
        _textField = [TMTextField defaultTextField];
        
        [_textField setFont:TGSystemFont(13)];
        [_textField setAlignment:NSCenterTextAlignment];
        [_textField setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:_textField];
        
    }
    
    return self;
}



-(void)setKeyboardButton:(TLKeyboardButton *)keyboardButton {
    _keyboardButton = keyboardButton;
    [_textField setStringValue:_keyboardButton.text];
    
    [_textField setFrame:self.bounds];
}

-(void)mouseUp:(NSEvent *)theEvent {
    [[Telegram rightViewController].messagesViewController sendMessage:_keyboardButton.text forConversation:_conversation];
    
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        [transaction removeObjectForKey:_conversation.cacheKey inCollection:BOT_COMMANDS];
    }];
    
    [Notification perform:[Notification notificationNameByDialog:_conversation action:@"botKeyboard"] data:@{KEY_DIALOG:_conversation}];
}

@end

@interface TGBotCommandsKeyboard ()
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TLUser *botUser;
@end

@implementation TGBotCommandsKeyboard

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setConversation:(TL_conversation *)conversation botUser:(TLUser *)botUser {
    _botUser = botUser;
    _conversation = conversation;
    
    [self removeAllSubviews];
    
    [self load];
}


-(void)load {
    

    __block TL_replyKeyboardMarkup *keyboard;
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
        
         keyboard = [transaction objectForKey:_conversation.cacheKey inCollection:BOT_COMMANDS];
        
        if(keyboard) {
            keyboard = [TLClassStore deserialize:(NSData *)keyboard];
        }
        
    }];
    
    if(keyboard) {
        [self drawKeyboardWithKeyboard:keyboard];
    } else {
        [self setFrameSize:NSMakeSize(NSWidth(self.frame), 0)];
    }
    
}


-(void)drawKeyboardWithKeyboard:(TL_replyKeyboardMarkup *)keyboard {
    
    NSMutableArray *f = keyboard.rows;
    
    int itemHeight = 25;
    
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), f.count * itemHeight + ((f.count -1) * 5 ) + 6)];
    
    __block int x = 0;
    __block int y = 0;
    
    [f enumerateObjectsUsingBlock:^(TL_keyboardButtonRow *row, NSUInteger idx, BOOL *stop) {
        
        int itemWidth = floor(NSWidth(self.frame)/row.buttons.count) - ((row.buttons.count-1) * 6 )/row.buttons.count;
        
        x = 0;
       
        [row.buttons enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            TGBotKeyboardItemView *itemView = [[TGBotKeyboardItemView alloc] initWithFrame:NSMakeRect(x, y, itemWidth, itemHeight)];
            
            [itemView setKeyboardButton:button];
            [itemView setConversation:_conversation];
            
            x+=itemWidth+6;
            
            [self addSubview:itemView];
            
        }];
        
        y+=itemHeight+6;
        
    }];
}

-(void)clear {
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        [transaction removeObjectForKey:_conversation.cacheKey inCollection:BOT_COMMANDS];
    }];
    
     [Notification perform:[Notification notificationNameByDialog:_conversation action:@"botKeyboard"] data:@{KEY_DIALOG:_conversation}];

}

@end
