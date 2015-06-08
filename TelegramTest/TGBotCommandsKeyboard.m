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
}

@end

@interface TGBotCommandsKeyboard ()
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TLUser *botUser;
@property (nonatomic,strong) NSScrollView *scrollView;

@property (nonatomic,strong) TMView *containerView;
@end

@implementation TGBotCommandsKeyboard


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
        
        
        self.autoresizingMask = NSViewWidthSizable;
        
        [self addSubview:_scrollView];
        
        
        _containerView = [[TMView alloc] initWithFrame:self.bounds];
        _containerView.backgroundColor = [NSColor clearColor];
        _scrollView.backgroundColor = NSColorFromRGB(0xfafafa);
        _scrollView.documentView = _containerView;
        
    }
    
    return self;
}




- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setConversation:(TL_conversation *)conversation botUser:(TLUser *)botUser {
    _botUser = botUser;
    _conversation = conversation;
    
    [_containerView removeAllSubviews];
    
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
    
    NSMutableArray *f = [[NSMutableArray alloc] init];
    
    [f addObject:[[NSMutableArray alloc] init]];
    
    __block int rowId = 0;
    
    [keyboard.rows enumerateObjectsUsingBlock:^(TL_keyboardButtonRow *obj, NSUInteger idx, BOOL *stop) {
        
        [obj.buttons enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            NSMutableArray *row = f[rowId];
            
            [row addObject:button];
            
            if(row.count == 2) {
                [f addObject:[[NSMutableArray alloc] init]];
                rowId++;
            }
            
        }];
        
        
    }];
    
    if([[f lastObject] count] == 0) {
        [f removeLastObject];
    }
    
    int itemHeight = 25;
    
    NSUInteger height = f.count * itemHeight + ((f.count -1) * 5 ) + 6;
    
    NSUInteger maxHeight = MIN(height,3 * itemHeight + ((3 -1) * 5 ) + 6);
    
   
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), maxHeight)];
    
    [_scrollView setFrameSize:NSMakeSize(NSWidth(self.frame), maxHeight)];
    
    [_containerView setFrameSize:NSMakeSize(NSWidth(self.frame), height)];
    
    
    
    __block int x = 0;
    __block int y = 3;
    
    [f enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger idx, BOOL *stop) {
        
        int itemWidth = floor(NSWidth(self.frame)/row.count) - ((row.count-1) * 6 )/row.count;
        
        x = 0;
       
        [row enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            TGBotKeyboardItemView *itemView = [[TGBotKeyboardItemView alloc] initWithFrame:NSMakeRect(x, y, itemWidth, itemHeight)];
            
            [itemView setKeyboardButton:button];
            [itemView setConversation:_conversation];
            
            x+=itemWidth+6;
            
            [_containerView addSubview:itemView];
            
        }];
        
        y+=itemHeight+6;
        
    }];
}


@end
