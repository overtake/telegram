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

@property (nonatomic,strong) TL_localMessage *keyboard;



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
        [[_textField cell] setTruncatesLastVisibleLine:YES];
        [self addSubview:_textField];
        
       
        
    }
    
    return self;
}


-(void)setKeyboardButton:(TLKeyboardButton *)keyboardButton {
    _keyboardButton = keyboardButton;
    
    
    [_textField setStringValue:[_keyboardButton.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "]];
    [_textField sizeToFit];
    [self setToolTip:NSWidth(self.frame) - 10 > NSWidth(_textField.frame) ? _keyboardButton.text : nil];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_textField setFrameSize:NSMakeSize(newSize.width-10, NSHeight(_textField.frame))];
    [_textField setCenteredYByView:self];
    [_textField setFrameOrigin:NSMakePoint(5, NSMinY(self.textField.frame) +2)];
    
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    NSString *command = _keyboardButton.text;
    
    [[Telegram rightViewController].messagesViewController sendMessage:command forConversation:_conversation];
    
    
    if(_keyboard.reply_markup.flags & (1 << 1) ) {
        
        _keyboard.reply_markup.flags|= (1 << 5);
        
        [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
            [transaction setObject:_keyboard forKey:_conversation.cacheKey inCollection:BOT_COMMANDS];
        }];
        
        [Notification perform:[Notification notificationNameByDialog:_conversation action:@"hideBotKeyboard"] data:@{KEY_DIALOG:_conversation}];
    }
}

@end

@interface TGBotCommandsKeyboard ()
@property (nonatomic,strong) TL_conversation *conversation;
@property (nonatomic,strong) TLUser *botUser;
@property (nonatomic,strong) NSScrollView *scrollView;

@property (nonatomic,strong) TMView *containerView;


@property (nonatomic,strong) NSArray *rows;
@property (nonatomic,strong) TL_localMessage *keyboard;

@end

@implementation TGBotCommandsKeyboard


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
        
       
        
        [self addSubview:_scrollView];

        
        _containerView = [[TMView alloc] initWithFrame:self.bounds];
        _containerView.backgroundColor = [NSColor clearColor];
        _containerView.isFlipped = YES;
        _scrollView.backgroundColor = NSColorFromRGB(0xfafafa);
        _scrollView.documentView = _containerView;
        
        
        _containerView.autoresizingMask = _scrollView.autoresizingMask = self.autoresizingMask = NSViewWidthSizable;
        
    }
    
    return self;
}

-(void)deleteKeyboard {
    [[Storage yap] readWriteWithBlock:^(YapDatabaseReadWriteTransaction * __nonnull transaction) {
        [transaction removeObjectForKey:_conversation.cacheKey inCollection:BOT_COMMANDS];
    }];
    
    [Notification perform:[Notification notificationNameByDialog:_conversation action:@"botKeyboard"] data:@{KEY_DIALOG:_conversation}];
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

-(BOOL)isCanShow {
    return _rows.count > 0;
}

-(void)load {
    
    _rows = nil;

    __block TL_localMessage *keyboard;
    
    [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction * __nonnull transaction) {
        
         keyboard = [transaction objectForKey:_conversation.cacheKey inCollection:BOT_COMMANDS];
        
    }];
    
    _keyboard = keyboard;
    
    if(keyboard) {
        [self drawKeyboardWithKeyboard:keyboard];
    } else {
        [self setFrameSize:NSMakeSize(NSWidth(self.frame), 0)];
    }
    
}


-(void)drawKeyboardWithKeyboard:(TL_localMessage *)keyboard {
    
    NSMutableArray *f = [[NSMutableArray alloc] init];
    
    [f addObject:[[NSMutableArray alloc] init]];
    
    __block int rowId = 0;
    
    [keyboard.reply_markup.rows enumerateObjectsUsingBlock:^(TL_keyboardButtonRow *obj, NSUInteger idx, BOOL *stop) {
        
        [f addObject:[[NSMutableArray alloc] init]];
        NSMutableArray *row = f[rowId];
        
        [obj.buttons enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            [row addObject:button];
            
        }];
        
        
        rowId++;
        
    }];
    
    if([[f lastObject] count] == 0) {
        [f removeLastObject];
    }
    
    
    
    int itemHeight = 33;
    
    NSUInteger height = f.count * itemHeight + ((f.count -1) * 3 ) + 6;
    
    NSUInteger maxHeight = MIN(height,3 * itemHeight + ((3 -1) * 3 ) + 6 + (itemHeight/2));
    
   
   
    
    [_scrollView setFrameSize:NSMakeSize(NSWidth(self.frame), maxHeight)];
    
    [_containerView setFrameSize:NSMakeSize(NSWidth(self.frame), height)];
    
    
    [f enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger idx, BOOL *stop) {
        
       
        [row enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            TGBotKeyboardItemView *itemView = [[TGBotKeyboardItemView alloc] initWithFrame:NSMakeRect(0, 0, 0, 22)];
            
            [itemView setKeyboardButton:button];
            [itemView setConversation:_conversation];
            [itemView setKeyboard:keyboard];
            [_containerView addSubview:itemView];
            
        }];
        
    }];
    
    
    _rows = f;
    
    
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), _rows.count == 0 ? 0 : maxHeight+2)];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    __block int x = 0;
    __block int y = 3;
    
    int itemHeight = 33;
    
    __block int k = 0;
    
    [_rows enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger rdx, BOOL *stop) {
        
        __block int itemWidth = floor(NSWidth(self.frame)/row.count) - ((row.count-1) * 3 )/row.count;
        
        x = 0;
        
        [row enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            
            if(_containerView.subviews.count > k) {
                TGBotKeyboardItemView *itemView = [_containerView.subviews objectAtIndex:k];
                
                int dif = (itemWidth + x) - NSWidth(_containerView.frame) ;
                
                if(dif > 0) {
                    itemWidth-=dif;
                }
                
                [itemView setFrame:NSMakeRect(x, y, itemWidth, itemHeight)];
                
                x+=itemWidth+3;
            }
            
            ++k;
            
        }];
        
        y+=itemHeight+3;
        
    }];
}

@end
