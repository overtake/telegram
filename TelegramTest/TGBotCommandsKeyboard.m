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


@property (nonatomic,strong) NSImageView *deleteImageView;

@property (nonatomic,strong) NSArray *rows;

@end

@implementation TGBotCommandsKeyboard


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _scrollView = [[NSScrollView alloc] initWithFrame:self.bounds];
        
        
        _deleteImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(NSWidth(self.frame) - image_CancelReply().size.width , NSHeight(self.frame) - image_CancelReply().size.height , image_CancelReply().size.width , image_CancelReply().size.height)];
        
        _deleteImageView.image = image_CancelReply();
        
        weak();
        
        [_deleteImageView setCallback:^{
            
            [weakSelf deleteKeyboard];
            
        }];
        
        [_deleteImageView setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin];
        
       
        
        [self addSubview:_scrollView];
        
        [self addSubview:_deleteImageView];
        
        
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


-(void)load {
    
    _rows = nil;

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
    
    
    
    int itemHeight = 22;
    
    NSUInteger height = f.count * itemHeight + ((f.count -1) * 5 ) + 6;
    
    NSUInteger maxHeight = MIN(height,3 * itemHeight + ((3 -1) * 5 ) + 6);
    
   
   
    
    [_scrollView setFrameSize:NSMakeSize(NSWidth(self.frame), maxHeight)];
    
    [_containerView setFrameSize:NSMakeSize(NSWidth(self.frame), height)];
    
    
    [f enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger idx, BOOL *stop) {
        
       
        [row enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            TGBotKeyboardItemView *itemView = [[TGBotKeyboardItemView alloc] initWithFrame:NSMakeRect(0, 0, 0, 22)];
            
            [itemView setKeyboardButton:button];
            [itemView setConversation:_conversation];
            
            [_containerView addSubview:itemView];
            
        }];
        
    }];
    
    
    _rows = f;
    
    
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), maxHeight+8)];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_deleteImageView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - image_CancelReply().size.width , NSHeight(self.frame) - image_CancelReply().size.height)];
    
    __block int x = 0;
    __block int y = 6;
    
    int itemHeight = 22;
    
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
