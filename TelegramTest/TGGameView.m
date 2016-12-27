//
//  TGGameView.m
//  Telegram
//
//  Created by keepcoder on 27/09/2016.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGGameView.h"
#import "TGTextLabel.h"
#import "TGCTextView.h"
#import "TGImageView.h"
#import "MessageTableItem.h"
#import "TGModernMessageCellContainerView.h"
#import "MessageCellDescriptionView.h"
@interface TGGameView ()
@property (nonatomic,strong) TGTextLabel *textLabel;
@property (nonatomic,strong) TGCTextView *textView;
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TGModernMessageCellContainerView *cellView;
@property (nonatomic, strong) MessageCellDescriptionView *gameMarkView;
@end

@implementation TGGameView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [BLUE_SEPARATOR_COLOR set];
    NSRectFill(NSMakeRect(0, 0, 2, NSHeight(self.frame)));
    
    // Drawing code here.
}

-(BOOL)isFlipped {
    return YES;
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [[TGTextLabel alloc] initWithFrame:NSZeroRect];
        self.textView = [[TGCTextView alloc] initWithFrame:NSZeroRect];
        [self.textView setEditable:YES];
        [self addSubview:self.textLabel];
        [self addSubview:self.textView];
        
        
        static NSSize markSize;
        static NSAttributedString *text;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            

            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
            
            [attr appendString:NSLocalizedString(@"Game.Mark", nil) withColor:NSColorFromRGB(0xffffff)];
            
            [attr setFont:TGSystemFont(13) forRange:attr.range];
            
            text = attr;
            
            NSSize size = [attr size];
            size.width = ceil(size.width + 10);
            size.height = ceil(size.height + 4);
            markSize = size;
            
        });
        
        _gameMarkView = [[MessageCellDescriptionView alloc] initWithFrame:NSMakeRect(5, 5, markSize.width, markSize.height)];
        [_gameMarkView setString:text];
        
    }
    return self;
}

-(void)setGame:(TGGameObject *)game {
    _game = game;
    
    [_textLabel setText:game.title maxWidth:game.size.width];
    [_textLabel setFrameOrigin:NSMakePoint(10, 0)];
    
    _textView.frame = NSMakeRect(10, NSMaxY(_textLabel.frame) + 2, game.descSize.width, game.descSize.height);
    _textView.attributedString = game.desc;
    
    if (game.imageObject) {
        if (_imageView == nil) {
            self.imageView = [[TGImageView alloc] initWithFrame:NSZeroRect];
            self.imageView.cornerRadius = 4;
            [self addSubview:_imageView];
        }
        
        _imageView.frame = NSMakeRect(10, NSMaxY(_textView.frame) + 4, game.imageObject.imageSize.width, game.imageObject.imageSize.height);
        _imageView.object = game.imageObject;

        
    } else {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
    }
    
    if (game.gifItem) {
        if(!_cellView || _cellView.class != game.gifItem.viewClass) {
            
            [_cellView.containerView removeFromSuperview];
            _cellView = [[game.gifItem.viewClass alloc] initWithFrame:NSZeroRect];
            [self addSubview:_cellView.containerView];
        }
        
        [_cellView setItem:game.gifItem];
        
        [_cellView.containerView setFrameOrigin:NSMakePoint(10, NSMaxY(_textView.frame) + 4)];
        
    } else {
        [_cellView.containerView removeFromSuperview];
        _cellView = nil;
    }
    
    if (_cellView != nil || _imageView != nil) {
        [_gameMarkView setFrameOrigin:NSMakePoint(MAX(NSMinX(_cellView.containerView.frame) + 2,NSMinX(_imageView.frame)) + 5, MAX(NSMinY(_cellView.containerView.frame) + 2,NSMinY(_imageView.frame)) + 5)];
        [self addSubview:_gameMarkView];
    } else {
        [_gameMarkView removeFromSuperview];
    }
    
}

-(void)_didChangeBackgroundColorWithAnimation:(POPBasicAnimation *)anim toColor:(NSColor *)color {
    if(!anim) {
        _textView.backgroundColor = color;
        _textLabel.backgroundColor = color;
 
    } else {
        [_textView pop_addAnimation:anim forKey:@"background"];
        [_textLabel pop_addAnimation:anim forKey:@"background"];
    }
}


-(void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [_cellView viewDidMoveToWindow];
}

-(void)mouseDown:(NSEvent *)event {
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    
    if ([[self hitTest:point] isKindOfClass:[TGImageView class]]) {
        [MessageSender proccessInlineKeyboardButton:[TL_keyboardButtonGame createWithText:self.game.game.short_name] messagesViewController:appWindow().navigationController.messagesViewController conversation:appWindow().navigationController.messagesViewController.conversation message:self.game.message handler:^(TGInlineKeyboardProccessType type) {
            
        }];
    }
}

-(void)mouseUp:(NSEvent *)event {
    
}

@end
