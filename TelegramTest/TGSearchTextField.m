//
//  TGSearchTextField.m
//  Telegram
//
//  Created by keepcoder on 08/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGSearchTextField.h"

@interface _TGSearchTextField : NSTextField

@end

@implementation _TGSearchTextField


@end


@interface TGSearchTextField () <NSTextFieldDelegate>
@property (nonatomic,strong) TMView *containerView;
@property (nonatomic,strong) _TGSearchTextField *searchField;
@property (nonatomic,strong) TMButton *clearView;
@end

@implementation TGSearchTextField

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.containerView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self.containerView setAutoresizingMask:NSViewWidthSizable];
        [self addSubview:self.containerView];
        
        NSImage *image = image_searchIcon();
        NSImageView *searchIconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(13, roundf((self.bounds.size.height - image.size.height) / 2), image.size.width, image.size.height)];
        searchIconImageView.image = image;
        [self.containerView addSubview:searchIconImageView];
        
        
        _searchField = [[_TGSearchTextField alloc] initWithFrame:NSZeroRect];
        [_searchField setDelegate:self];
        NSAttributedString *placeholderAttributed = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Search", nil) attributes:@{NSForegroundColorAttributeName: NSColorFromRGB(0xaeaeae), NSFontAttributeName: TGSystemLightFont(12)}];
        [[_searchField cell] setPlaceholderAttributedString:placeholderAttributed];
        
        [_searchField setBackgroundColor:[NSColor clearColor]];
        [_searchField setFont:TGSystemLightFont(12)];
        [_searchField setStringValue:NSLocalizedString(@"Search", nil)];
        [_searchField sizeToFit];
        [_searchField setStringValue:@""];
        
        
        [_searchField setBordered:NO];
        
        [_searchField setFocusRingType:NSFocusRingTypeNone];
        [[_searchField cell] setTruncatesLastVisibleLine:NO];
        [[_searchField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        
        [self.containerView addSubview:_searchField];
        
        
        
        _clearView = [[TMButton alloc] initWithFrame:NSZeroRect];
        [_clearView setAutoresizingMask:NSViewMinXMargin];
        [_clearView setImage:image_clear() forState:TMButtonNormalState];
        [_clearView setImage:image_clearActive() forState:TMButtonPressedState];
        
        [_clearView setFrameSize:image_clear().size];
        [_clearView setFrameOrigin:NSMakePoint(self.frame.size.width - _clearView.frame.size.width - 10, roundf((self.bounds.size.height - _clearView.bounds.size.height) / 2))];
        [_clearView setNeedsDisplay:YES];
        [_clearView setHidden:YES];
        [_clearView setTarget:self selector:@selector(clearAction:)];
        [self addSubview:_clearView];
        [self.containerView setWantsLayer:YES];

    }
    
    return self;
    
}

-(BOOL)becomeFirstResponder {
    return [_searchField becomeFirstResponder];
}


-(void)clearAction {
    
}

@end
