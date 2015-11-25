//
//  TGProfileHeaderRowView.m
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGProfileHeaderRowView.h"
#import "TGProfileHeaderRowItem.h"
#import "UserInfoShortTextEditView.h"
#import "ChatAvatarImageView.h"
@interface TGProfileHeaderRowView () <TMNameTextFieldProtocol,TMStatusTextFieldProtocol,NSTextFieldDelegate>
@property (nonatomic,strong) ChatAvatarImageView *imageView;
@property (nonatomic,strong) TMNameTextField *nameTextField;
@property (nonatomic,strong) TMStatusTextField *statusTextField;

@property (nonatomic,strong) TMView *editableContainerView;


@property (nonatomic,strong) UserInfoShortTextEditView *firstNameView;
@property (nonatomic,strong) UserInfoShortTextEditView *lastNameView;

@end

@implementation TGProfileHeaderRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(self.item.conversation.isVerified) {
        [image_Verify() drawInRect:NSMakeRect(NSMaxX(_nameTextField.frame),NSMinY(_nameTextField.frame) , image_Verify().size.width, image_Verify().size.height) fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1];
    }
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _imageView = [[ChatAvatarImageView alloc] initWithFrame:NSMakeRect(0, 0, 70, 70)];
        
        _nameTextField = [[TMNameTextField alloc] initWithFrame:NSZeroRect];
        [[_nameTextField cell] setTruncatesLastVisibleLine:YES];
        [[_nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        
        _statusTextField = [[TMStatusTextField alloc] init];
        [[_nameTextField cell] setTruncatesLastVisibleLine:YES];
        [[_nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [_statusTextField setSelector:@selector(statusForMessagesHeaderView)];
        
        [self addSubview:_statusTextField];
        [self addSubview:_nameTextField];
        [self addSubview:_imageView];
        
        
        _editableContainerView = [self createEditContainerView];
        
        [self addSubview:_editableContainerView];
    }
    
    return self;
}

-(TGProfileHeaderRowItem *)item {
    return (TGProfileHeaderRowItem *)[self rowItem];
}


- (void)TMStatusTextFieldDidChanged:(TMStatusTextField *)textField {
    [_statusTextField sizeToFit];
    [self setFrameSize:self.frame.size];
}


- (void)TMNameTextFieldDidChanged:(TMNameTextField *)textField {
    [_nameTextField sizeToFit];
    [self setFrameSize:self.frame.size];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    self.item.firstChangedValue = _firstNameView.textView.stringValue;
    self.item.secondChangedValue = _lastNameView.textView.stringValue;
}

-(void)redrawRow {
    [super redrawRow];
    
    [_imageView setEditable:self.item.isEditable && self.item.conversation.type != DialogTypeUser && self.item.conversation.type != DialogTypeSecretChat];
    
    [_imageView updateWithConversation:self.item.conversation];
    [_nameTextField updateWithConversation:self.item.conversation];
    [_statusTextField updateWithConversation:self.item.conversation];
    
    
    _firstNameView.textView.delegate = self;
    _lastNameView.textView.delegate = self;
    
    [_firstNameView.textView setStringValue:self.item.conversation.user.first_name];
    [_lastNameView.textView setStringValue:self.item.conversation.user.last_name];
    
    if(self.item.conversation.chat) {
        [_firstNameView.textView setStringValue:self.item.conversation.chat.title];
    }
    
    [_nameTextField sizeToFit];
    [_statusTextField sizeToFit];
    
    _nameTextField.nameDelegate = self;
    _statusTextField.statusDelegate = self;
    
    [self setFrameSize:self.frame.size];
    
    [_editableContainerView setHidden:!self.item.isEditable];
    [_nameTextField setHidden:self.item.isEditable];
    [_statusTextField setHidden:self.item.isEditable];
    
    
}



-(TMView *)createEditContainerView {
    
   TMView *container = [[TMView alloc] initWithFrame:NSMakeRect(100, 0, 100, 70)];
    
    container.isFlipped = YES;
    
    container.wantsLayer = YES;
    
    
    self.firstNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
    [self.firstNameView setFrameOrigin:NSMakePoint(10, 5)];
    [self.firstNameView setFrameSize:NSMakeSize(100, 30)];
    
    [container addSubview:self.firstNameView];
    
    
    
    self.lastNameView = [[UserInfoShortTextEditView alloc] initWithFrame:NSZeroRect];
    [self.lastNameView setFrameOrigin:NSMakePoint(10, self.firstNameView.bounds.size.height + 5)];
    [self.lastNameView setFrameSize:NSMakeSize(100, 30)];
    [container addSubview:self.lastNameView];
    
    [self.firstNameView.textView setNextKeyView:self.lastNameView.textView];
    [self.firstNameView.textView setTarget:self];
    [self.firstNameView.textView setAction:@selector(enterClick)];
    
    
    
    [self.lastNameView.textView setNextKeyView:self.firstNameView.textView];
    [self.lastNameView.textView setTarget:self];
    [self.lastNameView.textView setAction:@selector(enterClick)];
    
    [self.firstNameView.textView setFont:TGSystemFont(14)];
    [self.lastNameView.textView setFont:TGSystemFont(14)];
    
    [self.firstNameView.textView setAlignment:NSLeftTextAlignment];
    [self.lastNameView.textView setAlignment:NSLeftTextAlignment];
    
    [self.firstNameView.textView setFrameOrigin:NSMakePoint(0, 2)];
    [self.lastNameView.textView setFrameOrigin:NSMakePoint(0, 2)];
    
    
    [self.firstNameView.textView setStringValue:@"Mikhail"];
    [self.lastNameView.textView setStringValue:@"Filimonov"];
    
    [container setAutoresizingMask:NSViewWidthSizable];
    
    return container;
}

-(void)enterClick {
    
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_imageView setCenteredYByView:self];
    [_imageView setFrameOrigin:NSMakePoint(self.item.xOffset, NSMinY(_imageView.frame))];
    
    
    [_nameTextField setFrameSize:NSMakeSize(MIN(NSWidth(_nameTextField.frame), newSize.width - NSMaxX(_imageView.frame) - self.item.xOffset - 10), NSHeight(_nameTextField.frame))];
    [_statusTextField setFrameSize:NSMakeSize(MIN(NSWidth(_statusTextField.frame), newSize.width - NSMaxX(_imageView.frame) - self.item.xOffset - 8), NSHeight(_statusTextField.frame))];

    
    int totalHeight = NSHeight(_nameTextField.frame) + NSHeight(_statusTextField.frame);
    
    [_statusTextField setFrameOrigin:NSMakePoint(NSMaxX(_imageView.frame) + 8, roundf((newSize.height - totalHeight)/2))];
    [_nameTextField setFrameOrigin:NSMakePoint(NSMaxX(_imageView.frame) + 10, roundf((newSize.height - totalHeight)/2 + NSHeight(_statusTextField.frame)))];
    
    
    [_editableContainerView setFrame:NSMakeRect(NSMaxX(_imageView.frame) + 10, 0, newSize.width - NSMaxX(_imageView.frame) - self.item.xOffset - 10, 72)];
   
    [_editableContainerView setCenteredYByView:self];
    
    
    if(self.item.conversation.type != DialogTypeUser && self.item.conversation.type != DialogTypeSecretChat) {
        [_lastNameView setHidden:YES];
        [_firstNameView setCenteredYByView:_firstNameView.superview];
    } else {
        [_lastNameView setHidden:NO];
        [self.firstNameView setFrameOrigin:NSMakePoint(10, 5)];
    }
    
}


@end
