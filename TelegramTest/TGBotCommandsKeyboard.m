//
//  TGBotCommandsKeyboard.m
//  Telegram
//
//  Created by keepcoder on 05.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGBotCommandsKeyboard.h"
#import "TGTextLabel.h"
#import "ITProgressIndicator.h"
@interface TGDisableScrollView : BTRScrollView
@property (nonatomic,assign) BOOL disableScrolling;
@end

@implementation TGDisableScrollView

//-(void)scrollWheel:(NSEvent *)theEvent {
//    if(!_disableScrolling)
//        [super scrollWheel:theEvent];
//    else
//        [self.superview scrollWheel:theEvent];
//}

@end

@interface TGBotKeyboardItemView : TMView
@property (nonatomic,strong) TLKeyboardButton *keyboardButton;
@property (nonatomic,strong) TGTextLabel *textField;

@property (nonatomic,strong) TL_localMessage *keyboard;

@property (nonatomic,copy) void (^keyboardCallback)(TLKeyboardButton *command);

@property (nonatomic,strong) NSMutableAttributedString *string;

@property (nonatomic,assign) NSSize stringSize;

@property (nonatomic,strong) ITProgressIndicator *indicator;

@end


@implementation TGBotKeyboardItemView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        self.wantsLayer = YES;
        self.layer.cornerRadius = 4;
        self.layer.backgroundColor = [NSColor whiteColor].CGColor;
        self.layer.borderColor = GRAY_BORDER_COLOR.CGColor;
        self.layer.borderWidth = 1;
        _textField = [[TGTextLabel alloc] initWithFrame:NSZeroRect];
        [self addSubview:_textField];
        
        _indicator = [[ITProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
        
        
        _indicator.color = [NSColor whiteColor];
        
        [_indicator setIndeterminate:YES];
        
        _indicator.lengthOfLine = 5;
        _indicator.numberOfLines = 10;
        _indicator.innerMargin = 5;
        _indicator.widthOfLine = 2;
        
     
        
        [_indicator setHidden:YES];
        
        [self addSubview:_indicator];
        
    }
    
    return self;
}


-(void)setKeyboardButton:(TLKeyboardButton *)keyboardButton {
    _keyboardButton = keyboardButton;
    
    _string = [[NSMutableAttributedString alloc] init];
    
    [_string appendString:[_keyboardButton.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "] withColor:TEXT_COLOR];
    [_string setFont:TGSystemFont(13) forRange:_string.range];
    _stringSize = [_string coreTextSizeForTextFieldForWidth:INT32_MAX];
    
    [_textField setText:_string maxWidth:NSWidth(self.frame) - 10];
    
    [self setToolTip:NSWidth(self.frame) - 10 > NSWidth(_textField.frame) ? _keyboardButton.text : nil];
}

-(void)setProccessing:(BOOL)proccessing {
    [_indicator setHidden:!proccessing];
    
    [_indicator setCenterByView:self];
    
    [_textField setHidden:proccessing];
    
    [_indicator setAnimates:proccessing];
}

-(void)setTextColor:(NSColor *)textColor {
    [_string addAttribute:NSForegroundColorAttributeName value:textColor range:_string.range];
}

-(void)setBackgroundColor:(NSColor *)backgroundColor {
    self.layer.backgroundColor = backgroundColor.CGColor;
    [_textField setBackgroundColor:backgroundColor];
}

-(void)setBorderColor:(NSColor *)color {
    self.layer.borderColor = color.CGColor;
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [_textField setText:_string maxWidth:MIN(NSWidth(self.frame) - 10,_stringSize.width) height:_stringSize.height];
    [_textField setCenterByView:self];    
}

-(void)mouseUp:(NSEvent *)theEvent {
    
    self.layer.opacity = 1.0;
    
    if([self.superview mouse:[self.superview convertPoint:[theEvent locationInWindow] fromView:nil] inRect:self.frame]) {
        if(_keyboardCallback != nil) {
            _keyboardCallback(_keyboardButton);
        }
    }
}

-(void)mouseDragged:(NSEvent *)theEvent {
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    //[super mouseDown:theEvent];
    
    self.layer.opacity = 0.8;
}

@end

@interface TGBotCommandsKeyboard ()
@property (nonatomic,strong) TGDisableScrollView *scrollView;

@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) NSArray *rows;
@property (nonatomic,assign) BOOL fillToSize;
@property (nonatomic,copy) void (^keyboardCallback)(TLKeyboardButton *command);
@end

@implementation TGBotCommandsKeyboard


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _scrollView = [[TGDisableScrollView alloc] initWithFrame:self.bounds];
        
        
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



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setKeyboard:(TL_localMessage *)keyboard fillToSize:(BOOL)fillToSize keyboadrdCallback:(void (^)(TLKeyboardButton *command))keyboardCallback {
    _fillToSize = fillToSize;
  
    _keyboard = keyboard;
    
    _rows = @[];
    
    _keyboardCallback = [keyboardCallback copy];
    
     [_containerView removeAllSubviews];
     
     if(keyboard) {
         [self drawKeyboardWithKeyboard:keyboard];
     } else {
         [self setFrameSize:NSMakeSize(NSWidth(self.frame), 0)];
     }

}


-(void)setBackgroundColor:(NSColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _scrollView.backgroundColor = backgroundColor;
}

-(void)setButtonColor:(NSColor *)buttonColor {
    _buttonColor = buttonColor;
    
    [self updateButtons];
}

-(void)setButtonTextColor:(NSColor *)textColor {
    _buttonTextColor = textColor;
    
    [self updateButtons];
}

-(void)setButtonBorderColor:(NSColor *)buttonBorderColor {
    _buttonBorderColor = buttonBorderColor;
    
    [self updateButtons];
}


-(void)updateButtons {
    
    __block int k = 0;
    
    [_rows enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger rdx, BOOL *stop) {
        
        [row enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            
            if(_containerView.subviews.count > k) {
                TGBotKeyboardItemView *itemView = [_containerView.subviews objectAtIndex:k];
               
                [itemView setBackgroundColor:_buttonColor ? _buttonColor : [NSColor whiteColor]];
                [itemView setTextColor:_buttonTextColor ? _buttonTextColor : TEXT_COLOR];
                [itemView setBorderColor:_buttonBorderColor ? _buttonBorderColor : DIALOG_BORDER_COLOR];
            }
            
            ++k;
            
        }];
        
    }];
}

-(void)setProccessing:(BOOL)proccessing forKeyboardButton:(TLKeyboardButton *)keyboardButton {
    __block int k = 0;
    
    [_rows enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger rdx, BOOL *stop) {
        
        [row enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            
            if(_containerView.subviews.count > k) {
                TGBotKeyboardItemView *itemView = [_containerView.subviews objectAtIndex:k];
                
                if(itemView.keyboardButton == keyboardButton) {
                    [itemView setProccessing:proccessing];
                }
                
            }
            
            ++k;
            
        }];
        
    }];
}

-(BOOL)isCanShow {
    return _rows.count > 0;
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
    
    NSUInteger height = f.count * itemHeight + ((f.count -1) * 3 ) + (_fillToSize ? 0 : 6);
    
    NSUInteger maxHeight = _fillToSize ? height : MIN(height,3 * itemHeight + ((3 -1) * 3 ) + 6 + (itemHeight/2));
    
   
    _scrollView.verticalScrollElasticity = !_fillToSize;
    
    [_scrollView setFrameSize:NSMakeSize(NSWidth(self.frame), maxHeight)];
    
    [_containerView setFrameSize:NSMakeSize(NSWidth(self.frame), height)];
    
    
    [f enumerateObjectsUsingBlock:^(NSMutableArray *row, NSUInteger idx, BOOL *stop) {
        
       
        [row enumerateObjectsUsingBlock:^(TL_keyboardButton *button, NSUInteger idx, BOOL *stop) {
            
            TGBotKeyboardItemView *itemView = [[TGBotKeyboardItemView alloc] initWithFrame:NSMakeRect(0, 0, 0, 22)];
            
            [itemView setKeyboardButton:button];
            [itemView setKeyboard:keyboard];
            [itemView setKeyboardCallback:self.keyboardCallback];
            
            [itemView setBackgroundColor:_buttonColor ? _buttonColor : [NSColor whiteColor]];
            [itemView setTextColor:_buttonTextColor ? _buttonTextColor : TEXT_COLOR];
            [itemView setBorderColor:_buttonBorderColor ? _buttonBorderColor : DIALOG_BORDER_COLOR];
            
            [_containerView addSubview:itemView];
            
        }];
        
    }];
    
    
    _rows = f;
    
    
    [self setFrameSize:NSMakeSize(NSWidth(self.frame), _rows.count == 0 ? 0 : maxHeight+2)];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    __block int x = 0;
    __block int y = _fillToSize ? 0 : 3;
    
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
