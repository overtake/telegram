//
//  TMWebImagesSearchPicker.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/16/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMImagePicker.h"
#import "Telegram.h"
#import "TMImagesSearchController.h"

@interface TMImagePicker()
@property (nonatomic) BOOL isInitialize;
@property (nonatomic, strong) NSTableView *leftTableView;
@property (nonatomic, strong) NSMenuItem *webSearchMenuItem;
@property (nonatomic, strong) NSView *rootView;
@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL isFirstShow;
@property (nonatomic) NSUInteger lastSelection;
@property (nonatomic, strong) NSView *centerContainerView;
@property (nonatomic, strong) NSTextField *titleTextField;

@property (nonatomic, strong) TMImagesSearchController *searchController;
@end

@interface IKPictureTaker(Category)
- (void)doneButton:(id)action;
@end

@implementation TMImagePicker


static NSSize webViewSize() {
    return NSMakeSize(600, 500);
}

- (id)init {
    self = [super init];
    if(self) {
//        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
//        [self initialize];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];
    if(self) {
//        [self initialize];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen];
    if(self) {
//        [self initialize];
    }
    return self;
}

- (void)performRemoveLeftItemAtIndex:(NSUInteger)index {
    SEL sel = @selector(removeItemAtIndex:);
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.leftTableView methodSignatureForSelector:sel]];
    [inv setSelector:sel];
    [inv setTarget:self.leftTableView];
    [inv setArgument:&index atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
    [inv invoke];
}

- (void)performSelectLeftItemAtIndex:(NSUInteger)index {
    SEL sel = @selector(selectItemAtIndex:);
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self.leftTableView methodSignatureForSelector:sel]];
    [inv setSelector:sel];
    [inv setTarget:self.leftTableView];
    [inv setArgument:&index atIndex:2]; //arguments 0 and 1 are self and _cmd respectively, automatically set by NSInvocation
    [inv invoke];
}

- (NSImage *)outputImage {
    if(self.type == TMImagePickerWebSearchDefaultSelection) {
        if([self.inputImage.name isEqualTo:@"webImage"]) {
            return self.inputImage;
        }
    }
    return super.outputImage;
}

- (void)doneButton:(id)action {
    
    
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(2000, 200)];
    [image setName:@"webImage"];
    [image lockFocus];
    [[NSColor redColor] set];
    NSRectFill(NSMakeRect(0, 0, 2000, 200));
    [image unlockFocus];
    [self setInputImage:image];
    
  
    
    
    [super doneButton:action];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [super performSelector:@selector(doneButton:) withObject:action];
//    });
//    self.outputImage
    
//    MTLog(@"log %@", self.outputImage);

}

- (NSRect)rectForSize:(NSSize)size {
    NSRect telegramRect = [Telegram delegate].window.frame;
    NSRect telegramViewFrame = ((NSView *)[Telegram delegate].window.contentView).frame;
    
    return NSMakeRect(telegramRect.origin.x + floor((telegramRect.size.width - size.width) / 2.0), telegramRect.origin.y + floor(telegramViewFrame.size.height - size.height), size.width, size.height);
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    

    
    if(self.type == TMImagePickerWebSearchDefaultSelection) {
        
        dispatch_block_t block = ^{
            [self.centerContainerView setHidden:self.leftTableView.selectedRow == 3];
            [self.searchController.view setHidden:self.leftTableView.selectedRow != 3];
            
            if(self.leftTableView.selectedRow == 3) {
                [self.searchController becomeFirstResponder];
            }
        };
        
        if(self.leftTableView.selectedRow == 3) {
            block();
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    block();
                });
            });
        }
        
    }
    
    BOOL animation = YES;
    if(self.type == TMImagePickerWebSearchDefaultSelection) {
        if(self.isFirstShow) {
            if(self.leftTableView.selectedRow != 3) {
                [self.leftTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:3] byExtendingSelection:NO];
            } else {
                self.isFirstShow = NO;
            }
            animation = NO;
        }
    } else {
        self.isFirstShow = NO;
    }
    
    
    
    if(self.leftTableView.selectedRow == 3) {
        
        dispatch_block_t block = ^{
            NSRect frame = [self rectForSize:webViewSize()];
            [self setFrame:frame display:YES animate:animation];
            if(!NSEqualRects(self.frame, frame)) {
                [self setFrame:frame display:YES animate:animation];
            }
        };

//        if(self.lastSelection == 1) {
            dispatch_async(dispatch_get_main_queue(), block);
//        } else {
//            block();
//        }
        

    } else {
        NSRect frame = [self rectForSize:NSMakeSize(325, 271)];
        [self setFrame:frame display:YES animate:animation];
        
        [((NSView *)[((NSView *)[self.rootView.subviews objectAtIndex:0]).subviews objectAtIndex:0]) setFrameSize:NSMakeSize(228, 250)];
        
//        NSView *view = ((NSView *)[((NSView *)[self.rootView.subviews objectAtIndex:0]).subviews objectAtIndex:0]) ;
//        NSScrollView *scrollView = [view.subviews objectAtIndex:3];
//        NSView *lol = scrollView.documentView;
//        MTLog(@"log");
    }

    if(self.lastSelection != self.leftTableView.selectedRow)
        self.lastSelection = self.leftTableView.selectedRow;
}

- (void)initialize {
    self.styleMask |= NSTitledWindowMask;
    
    [super beginPictureTakerWithDelegate:nil didEndSelector:NULL contextInfo:nil];
    [super close];

    NSView *contentView = self.contentView;
    NSView *backgroundView = [contentView.subviews objectAtIndex:0];
    
    NSView *leftTopView = [contentView.subviews objectAtIndex:2];
    [leftTopView setAutoresizingMask:NSViewMinYMargin];
    
    [backgroundView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    self.rootView = [backgroundView.subviews objectAtIndex:0];
    [self.rootView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    
    self.titleTextField = [contentView.subviews objectAtIndex:3];
    [self.titleTextField setHidden:YES];
    
    self.centerContainerView = [self.rootView.subviews objectAtIndex:0];
    
    NSScrollView *leftScrollView = [self.rootView.subviews objectAtIndex:1];
    [leftScrollView setAutoresizingMask:NSViewHeightSizable];

    self.leftTableView = (NSTableView *)[leftScrollView documentView];
    
    
    self.searchController = [[TMImagesSearchController alloc] initWithFrame:self.centerContainerView.frame];
    [self.centerContainerView.superview addSubview:self.searchController.view];
    

    //Delete DefaultButton
    [self performRemoveLeftItemAtIndex:0];
    
    //Create WebSearch Button
    [self.leftTableView performSelector:@selector(addItemWithTitle:) withObject:NSLocalizedString(@"Attach.WebSearch", nil)];
    self.webSearchMenuItem = [self.leftTableView performSelector:@selector(itemWithTitle:) withObject:NSLocalizedString(@"Attach.WebSearch", nil)];
    self.webSearchMenuItem.tag = 3;
    
    
    self.leftTableView.delegate = self;
    [self.leftTableView reloadData];
    
    self.isInitialize = YES;
}

- (void)beginPictureTakerSheetForWindow:(NSWindow *)aWindow withDelegate:(id)delegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo {
    
    if(!self.isInitialize)
        [self initialize];
    
    if(self.isOpen)
        return;

    if(self.type == TMImagePickerWebSearchDefaultSelection)
        [self.leftTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:3] byExtendingSelection:NO];
    
    self.isFirstShow = YES;
    [super beginPictureTakerSheetForWindow:aWindow withDelegate:delegate didEndSelector:didEndSelector contextInfo:contextInfo];
    self.isOpen = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isFirstShow = NO;
    });
}

- (void)close {
    [super close];
    self.isOpen = NO;
}

- (void)orderOut:(id)sender {
    self.isOpen = NO;
    [super orderOut:sender];
}

+ (TMImagePicker *)sharedInstance {
    static TMImagePicker *picker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        picker = [[TMImagePicker alloc] init];
    });
    return picker;
}

@end
