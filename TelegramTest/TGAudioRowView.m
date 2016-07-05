//
//  TGAudioRowView.m
//  Telegram
//
//  Created by keepcoder on 01.06.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAudioRowView.h"
#import "MessageTableItemAudioDocument.h"
#import "TGImageView.h"
@interface TGAudioRowView ()
@property (nonatomic,strong) TMTextField *nameField;
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMView *backgroundView;
@end

@implementation TGAudioRowView


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        
        
        _nameField = [TMTextField defaultTextField];
        
        [self addSubview:_nameField];
        
        
        _imageView = [[TGImageView alloc] initWithFrame:NSMakeRect(12, 10, 36, 36)];
        
        _imageView.wantsLayer = YES;
        _imageView.cornerRadius = 4;
        [self addSubview:_imageView];
    }
    
    return self;
}

-(NSImage *)image {
    return _imageView.image;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
     TGAudioRowItem *item = (TGAudioRowItem *) [self rowItem];
    
    if(item.isSelected) {
        [LINK_COLOR set];
        NSRectFill(dirtyRect);
    }
    
    // Drawing code here.
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    [NSMenu popUpContextMenu:[self menuForEvent:theEvent] withEvent:theEvent forView:self];
}

-(NSMenu *)menuForEvent:(NSEvent *)event {
    return [self contextMenu];
}

- (NSMenu *)contextMenu {
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Context"];
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    return menu;
}

-(NSArray *)defaultMenuItems {
    
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    
    weak();
    

    if(self.item.document.message.conversation.type != DialogTypeSecretChat) {
        [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Forward", nil) withBlock:^(id sender) {
            
            [appWindow().navigationController.messagesViewController setState:MessagesViewControllerStateNone];
            [appWindow().navigationController.messagesViewController unSelectAll:NO];
            [appWindow().navigationController.messagesViewController setSelectedMessage:weakSelf.item.document selected:YES];
            [appWindow().navigationController.messagesViewController showForwardMessagesModalView];
            
            
            [appWindow() makeKeyAndOrderFront:self.window];
            
        }]];
    }
    
    if([MessagesViewController canDeleteMessages:@[self.item.document.message] inConversation:self.item.document.message.conversation]) {
        [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Delete", nil) withBlock:^(id sender) {
            
            
            [self.window makeKeyAndOrderFront:self];
            
            [appWindow().navigationController.messagesViewController setState:MessagesViewControllerStateNone];
            [appWindow().navigationController.messagesViewController unSelectAll:NO];
            [appWindow().navigationController.messagesViewController setSelectedMessage:weakSelf.item.document selected:YES];
            [appWindow().navigationController.messagesViewController deleteSelectedMessages];
            
            
            
        }]];
    }
    
    
    NSMenuItem *gotoMessage = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"PhotoViewer.Goto", nil) withBlock:^(id sender) {
        
        
        [appWindow().navigationController showMessagesViewController:self.item.document.message.conversation withMessage:self.item.document.message];
        [appWindow() makeKeyAndOrderFront:self.window];
        
    }];
    
    [items addObject:gotoMessage];
    

    
    return items;
    
}

-(TGAudioRowItem *)item {
    return (TGAudioRowItem *)self.rowItem;
}

-(void)redrawRow {
    [super redrawRow];
    
    TGAudioRowItem *item = (TGAudioRowItem *) [self rowItem];
    
    
    if( item.imageObject) {
        _imageView.object = item.imageObject;
        [_imageView setFrameSize:item.imageObject.imageSize];
        
    } 
    
    
    [_imageView setCenteredYByView:self];
    
        
    [item.document.id3AttributedString setSelected:[item isSelected]];
    
    [_nameField setAttributedStringValue:item.document.id3AttributedString];
    
    [_nameField sizeToFit];
    
    [_nameField setFrameSize:NSMakeSize(NSWidth(self.frame) - NSMaxX(_imageView.frame) - 22, NSHeight(_nameField.frame))];
    
    [_nameField setFrameOrigin:NSMakePoint(NSMaxX(_imageView.frame) + 10, 7)];
    
    
    [_nameField setCenteredYByView:self];
    
    
    [self setNeedsDisplay:YES];
    
}



@end
