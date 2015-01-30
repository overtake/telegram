//
//  TGDocumentMediaRowView.m
//  Telegram
//
//  Created by keepcoder on 27.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGDocumentMediaRowView.h"
#import "MessageTableItemDocument.h"
#import "TGSharedMediaFileThumbnailView.h"
#import "TGImageView.h"
#import "TMPreviewDocumentItem.h"
#import "TMMediaController.h"
#define s_dox 30

@interface TGDocumentMediaRowView () <TMHyperlinkTextFieldDelegate,NSMenuDelegate>
@property (nonatomic,strong) TMTextField *nameField;
@property (nonatomic,strong) TMHyperlinkTextField *descriptionField;
@property (nonatomic,strong) NSImageView *downloadImageView;
@property (nonatomic,strong) TGSharedMediaFileThumbnailView *thumbView;
@property (nonatomic,strong) TMTextField *extField;
@property (nonatomic,strong) TGImageView *thumbImageView;
@end

@implementation TGDocumentMediaRowView


NSImage *pauseImage() {
    static NSImage *img;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGContextRef context = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                     11,
                                                     11,
                                                     8 /*bitsPerComponent*/,
                                                     0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                     [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                     kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
        

        CGContextSetFillColorWithColor(context, NSColorFromRGB(0x0080fc).CGColor);
        CGContextFillRect(context, CGRectMake(2.0f, 0.0f, 2.0f, 11.0f - 1.0f));
        CGContextFillRect(context, CGRectMake(2.0f + 2.0f + 2.0f, 0.0f, 2.0f, 11.0f - 1.0f));
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        
        
        CGContextRelease(context);
        img = [[NSImage alloc] initWithCGImage:cgImage size:NSMakeSize(11, 11)];
        
    });
    
    return img;
}

static NSDictionary *colors;

-(instancetype)initWithFrame:(NSRect)frameRect
{
    if(self = [super initWithFrame:frameRect]) {
        _nameField = [[TMTextField alloc] init];
        [_nameField setEditable:NO];
        [_nameField setBordered:NO];
        [_nameField setBackgroundColor:[NSColor clearColor]];
        [_nameField setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12]];
        [[_nameField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_nameField cell] setTruncatesLastVisibleLine:YES];
        
        [_nameField setFrame:NSMakeRect(s_dox + 50, 32, NSWidth(frameRect) - s_dox * 2 - 50, 20)];
        
        [self addSubview:_nameField];
        
        _descriptionField = [[TMHyperlinkTextField alloc] init];
        [_descriptionField setEditable:NO];
        [_descriptionField setBordered:NO];
        [_descriptionField setBackgroundColor:[NSColor clearColor]];
        [_descriptionField setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [[_descriptionField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_descriptionField cell] setTruncatesLastVisibleLine:YES];
        
        [_descriptionField setTextColor:NSColorFromRGB(0x999999)];
        
        [_descriptionField setFrame:NSMakeRect(s_dox + 50, 13, NSWidth(frameRect) - s_dox * 2 - 50, 20)];
        
        [_descriptionField setUrl_delegate:self];
                
        [self addSubview:_descriptionField];
        
        _downloadImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(s_dox + 50, 15, image_SharedMediaDocumentStatusDownload().size.width, image_SharedMediaDocumentStatusDownload().size.height)];
        
        _downloadImageView.image = image_SharedMediaDocumentStatusDownload();
        
        [self addSubview:_downloadImageView];
        
        _thumbView = [[TGSharedMediaFileThumbnailView alloc] initWithFrame:NSMakeRect(s_dox, 10, 40, 40)];
        
        [self addSubview:_thumbView];
        
        
        
        
        _extField = [TMTextField defaultTextField];
        
        [_extField setTextColor:[NSColor whiteColor]];
        [_extField setAlignment:NSCenterTextAlignment];
        
        [_extField setFrameSize:NSMakeSize(40, 18)];
        [_extField setFrameOrigin:NSMakePoint(0, 12)];
        
        [_thumbView addSubview:_extField];
        
        
        
        _thumbImageView = [[TGImageView alloc] initWithFrame:_thumbView.frame];
        
        [self addSubview:_thumbImageView];
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSArray *redColors = @[NSColorFromRGB(0xf0625d), NSColorFromRGB(0xde524e)];
            NSArray *greenColors = @[NSColorFromRGB(0x72ce76), NSColorFromRGB(0x54b658)];
            NSArray *blueColors = @[NSColorFromRGB(0x60b0e8), NSColorFromRGB(0x4597d1)];
            NSArray *yellowColors = @[NSColorFromRGB(0xf5c565), NSColorFromRGB(0xe5a64e)];
            colors = @{
                       @"ppt": redColors,
                       @"pptx": redColors,
                       @"pdf": redColors,
                       @"key": redColors,
                       
                       @"xls": greenColors,
                       @"xlsx": greenColors,
                       @"csv": greenColors,
                       
                       @"doc": blueColors,
                       @"docx": blueColors,
                       @"txt": blueColors,
                       @"psd": blueColors,
                       @"mp3": blueColors,
                       
                       @"zip": yellowColors,
                       @"rar": yellowColors,
                       @"ai": yellowColors,
                       
                       @"*": blueColors
            };
        });

        
        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    [super drawRect:dirtyRect];
    
    [LIGHT_GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(s_dox + 50, 0, NSWidth(self.frame) - s_dox * 2 - 50, 1));
    
    if(self.item.downloadItem.downloadState == DownloadStateDownloading) {
        
        int max = NSWidth(self.frame) - s_dox * 2 - 50;
        
        float current = max*(self.item.downloadItem.progress/100.0f);
        
        [BLUE_COLOR_SELECT set];
        NSRectFill(NSMakeRect(s_dox + 50, 0, current, 2));
    }
    
    
}

-(void)setItem:(MessageTableItemDocument *)item {
    
    [super setItem:item];
    
    [self.nameField setStringValue:item.fileName];
    
    NSString *ext = [item.fileName pathExtension];
    
    NSArray *c = colors[ext];
    
    [_extField setStringValue:ext];
    
    if(!c) c = colors[@"*"];
    
    [self.thumbView setStyle:TGSharedMediaFileThumbnailViewStyleRounded colors:c];
    
    [_thumbImageView setObject:item.thumbObject];
    
    [self updateCellState];
}


-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    if(![self.item isset]) {
        [self startDownload];
    } else {
        NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
        if(NSPointInRect(point, self.thumbImageView.frame)) {
            [self open];
        }
    }
}


-(void)updateCellState {
    
    MessageTableItemDocument *item = (MessageTableItemDocument *) self.item;
    
    if([item isset]) {
        [self.descriptionField setAttributedStringValue:docLoadedAttributedString()];
    } else {
        
        if(self.item.downloadItem.downloadState == DownloadStateDownloading) {
            NSString *downloadString = [NSString stringWithFormat:NSLocalizedString(@"Document.Downloading", nil), self.item.downloadItem.progress];
            
            [self.descriptionField setAttributedStringValue:[[NSAttributedString alloc] initWithString:downloadString attributes:@{NSFontAttributeName: [NSFont fontWithName:@"HelveticaNeue" size:12], NSForegroundColorAttributeName: NSColorFromRGB(0x9b9b9b)}]];
         } else {
            [self.descriptionField setStringValue:[NSString stringWithFormat:@"%@ • %@",item.fileSize,item.fullDate]];
        }
    }
    
    [self.downloadImageView setHidden:item.isset];
    
    self.downloadImageView.image = item.downloadItem.downloadState == DownloadStateDownloading ? pauseImage() : image_SharedMediaDocumentStatusDownload();
    
    [self.descriptionField setFrameOrigin:NSMakePoint(s_dox + 50 + (self.downloadImageView.isHidden ? 0 : NSWidth(self.downloadImageView.frame)), NSMinY(self.descriptionField.frame))];
    
}



-(void)updateDownloadState {
    
    
    [self updateCellState];
    
    weak();
    
    if(self.item.downloadItem) {
        
        [self.item.downloadListener setCompleteHandler:^(DownloadItem * item) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                weakSelf.item.downloadItem = nil;
                [weakSelf updateCellState];
                [weakSelf setNeedsDisplay:YES];
            }];
            
        }];
        
        [self.item.downloadListener setProgressHandler:^(DownloadItem * item) {
            
            [ASQueue dispatchOnMainQueue:^{
                [weakSelf updateCellState];
                
                [weakSelf setNeedsDisplay:YES];
            }];
        }];
        
    }
    
}

-(void)startDownload {
    if(self.item.downloadItem.downloadState == DownloadStateDownloading) {
        [self.item.downloadItem cancel];
        self.item.downloadItem = nil;
    } else {
        [self.item startDownload:NO force:YES];
    }
    
    [self updateDownloadState];
    
    [self setNeedsDisplay:YES];
}


- (void)open {
    PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:self.item.message.n_id media:self.item.message peer_id:self.item.message.peer_id];
    
    TMPreviewDocumentItem *item = [[TMPreviewDocumentItem alloc] initWithItem:previewObject];
    [[TMMediaController controller] show:item];
}

- (void) textField:(id)textField handleURLClick:(NSString *)url {
    if([url isEqualToString:@"finder"]) {
        if(self.item.isset)
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:((MessageTableItemDocument *)self.item).path]]];
        else
            [self startDownload];
    }
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    
    NSMenu *contextMenu = [self contextMenu];
    
    if(contextMenu && self.messagesViewController.state == MessagesViewControllerStateNone) {
        
        contextMenu.delegate = self;
        
        [NSMenu popUpContextMenu:contextMenu withEvent:theEvent forView:self];
    } else {
        [super rightMouseDown:theEvent];
    }
}


- (NSMenu *)contextMenu {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Documents menu"];
    
    if([self.item isset]) {
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.OpenInFinder", nil) withBlock:^(id sender) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:((MessageTableItemDocument *)self.item).path]]];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [self performSelector:@selector(saveAs:) withObject:self];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [self performSelector:@selector(copy:) withObject:self];
        }]];
        
        
        [menu addItem:[NSMenuItem separatorItem]];
    }
    
    [self.defaultMenuItems enumerateObjectsUsingBlock:^(NSMenuItem *item, NSUInteger idx, BOOL *stop) {
        [menu addItem:item];
    }];
    
    
    return menu;
}

- (void)copy:(id)sender {
    
    if(![self.item.message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
        NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        [pasteboard writeObjects:[NSArray arrayWithObject:[NSURL fileURLWithPath:mediaFilePath(self.item.message.media)]]];
    }
}


- (void)saveAs:(id)sender {
    
    if(![self.item.message.media isKindOfClass:[TL_messageMediaEmpty class]]) {
        
        NSSavePanel *panel = [NSSavePanel savePanel];
        
        NSString *path = mediaFilePath(self.item.message.media);
        
        NSString *fileName = [path lastPathComponent];
        
        [panel setNameFieldStringValue:fileName];
        
        
        [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
            if (result == NSFileHandlingPanelOKButton) {
                
                NSURL *file = [panel URL];
                if ( [[NSFileManager defaultManager] isReadableFileAtPath:path] ) {
                    
                    [[NSFileManager defaultManager] copyItemAtURL:[NSURL fileURLWithPath:path] toURL:file error:nil];
                }
            } else if(result == NSFileHandlingPanelCancelButton) {
                
            }
        }];
    }
    
}

-(NSArray *)defaultMenuItems {
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    if(self.item.message.conversation.type != DialogTypeSecretChat) {
        [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Forward", nil) withBlock:^(id sender) {
            
            [[Telegram rightViewController].messagesViewController setState:MessagesViewControllerStateNone];
            [[Telegram rightViewController].messagesViewController unSelectAll:NO];
            
            
            
            [[Telegram rightViewController].messagesViewController setSelectedMessage:self.item selected:YES];
            
            
            [[Telegram rightViewController] showForwardMessagesModalView:[Telegram rightViewController].messagesViewController.conversation messagesCount:1];
            
            
        }]];
    }
    
    
    [items addObject:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Delete", nil) withBlock:^(id sender) {
        
        [[Telegram rightViewController].messagesViewController setState:MessagesViewControllerStateNone];
        [[Telegram rightViewController].messagesViewController unSelectAll:NO];
        
        [[Telegram rightViewController].messagesViewController setSelectedMessage:self.item selected:YES];
        
        [[Telegram rightViewController].messagesViewController deleteSelectedMessages];
        
        
    }]];
    
    return items;
    
}


- (void)menuWillOpen:(NSMenu *)menu {
    self.layer.backgroundColor =  NSColorFromRGB(0xf7f7f7).CGColor;
}


- (void)menuDidClose:(NSMenu *)menu {
    self.layer.backgroundColor = NSColorFromRGB(0xffffff).CGColor;
}



static NSAttributedString *docLoadedAttributedString() {
    static NSAttributedString *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
        
        NSRange range = [mutableAttributedString appendString:NSLocalizedString(@"Message.File.ShowInFinder", nil) withColor:BLUE_UI_COLOR];
        [mutableAttributedString setLink:@"finder" forRange:range];
        
        [mutableAttributedString setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:mutableAttributedString.range];
        
        instance = mutableAttributedString;
    });
    return instance;
}

@end
