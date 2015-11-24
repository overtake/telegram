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
#import "TGDocumentsMediaTableView.h"
#define s_dox 30

@interface TGDocumentMediaRowView () <TMHyperlinkTextFieldDelegate,NSMenuDelegate>
@property (nonatomic,strong) TMTextField *nameField;
@property (nonatomic,strong) TMHyperlinkTextField *descriptionField;
@property (nonatomic,strong) TMView *downloadImageView;
@property (nonatomic,strong) TGSharedMediaFileThumbnailView *thumbView;
@property (nonatomic,strong) TMTextField *extField;
@property (nonatomic,strong) TGImageView *thumbImageView;

@property (nonatomic,assign,getter=isEditable,readonly) BOOL editable;

@property (nonatomic,strong) BTRButton *selectButton;

@property (nonatomic,strong) DownloadEventListener *downloadEventListener;


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
        [_nameField setFont:TGSystemMediumFont(12)];
        [[_nameField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_nameField cell] setTruncatesLastVisibleLine:YES];
        
        [_nameField setFrame:NSMakeRect(s_dox + 50, 32, NSWidth(frameRect) - s_dox * 2 - 50, 20)];
        
        [self addSubview:_nameField];
        
        _descriptionField = [[TMHyperlinkTextField alloc] init];
        [_descriptionField setEditable:NO];
        [_descriptionField setBordered:NO];
        [_descriptionField setBackgroundColor:[NSColor clearColor]];
        [_descriptionField setFont:TGSystemFont(12)];
        [[_descriptionField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [[_descriptionField cell] setTruncatesLastVisibleLine:YES];
        
        [_descriptionField setTextColor:GRAY_TEXT_COLOR];
        
        [_descriptionField setFrame:NSMakeRect(s_dox + 50, 8, NSWidth(frameRect) - s_dox * 2 - 50, 20)];
        
        [_descriptionField setUrl_delegate:self];
                
        [self addSubview:_descriptionField];
        
    
        
        _downloadImageView = [[TMView alloc] initWithFrame:NSMakeRect(s_dox + 50, 15, image_SharedMediaDocumentStatusDownload().size.width, image_SharedMediaDocumentStatusDownload().size.height)];
        
        
        [_downloadImageView addSubview:imageViewWithImage(image_SharedMediaDocumentStatusDownload())];
        
        [self addSubview:_downloadImageView];
        
        _thumbView = [[TGSharedMediaFileThumbnailView alloc] initWithFrame:NSMakeRect(s_dox, 10, 40, 40)];
        
        [self addSubview:_thumbView];
        
        
        [self setEditable:YES animated:YES];
        
        _extField = [TMTextField defaultTextField];
        
        [_extField setTextColor:[NSColor whiteColor]];
        [_extField setAlignment:NSCenterTextAlignment];
        
        [_extField setFrameSize:NSMakeSize(40, 18)];
        [_extField setFrameOrigin:NSMakePoint(0, 12)];
        
        [_thumbView addSubview:_extField];
        
        
        
        _thumbImageView = [[TGImageView alloc] initWithFrame:_thumbView.bounds];
        
        [_thumbView addSubview:_thumbImageView];
        
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

        
         self.selectButton = [[BTRButton alloc] initWithFrame:NSMakeRect(20, roundf((60 - image_ComposeCheckActive().size.height )/ 2), image_ComposeCheckActive().size.width, image_ComposeCheckActive().size.height)];
        
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateNormal];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHover];
        [self.selectButton setBackgroundImage:image_ComposeCheck() forControlState:BTRControlStateHighlighted];
        [self.selectButton setBackgroundImage:image_ComposeCheckActive() forControlState:BTRControlStateSelected];
        
        [self.selectButton setUserInteractionEnabled:NO];
        
        [self addSubview:self.selectButton];

        
        
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
    if(!self.isEditable) {
        [super mouseDown:theEvent];
        
        if(![self.item isset]) {
            [self startDownload];
        } else {
            NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            
          //  if(NSPointInRect(point, self.thumbImageView.frame)) {
                [self open];
            //}
        }
    } else {
        
        TGDocumentsMediaTableView *table = (TGDocumentsMediaTableView *) self.item.table;
        
        [table setSelected:![table isSelectedItem:self.item] forItem:self.item];
        
        [self setSelected:[table isSelectedItem:self.item]];
    }
}


-(void)updateCellState {
    
    MessageTableItemDocument *item = (MessageTableItemDocument *) self.item;
    
    if([item isset]) {
        [self.descriptionField setAttributedStringValue:docLoadedAttributedString()];
    } else {
        
        if(self.item.downloadItem.downloadState == DownloadStateDownloading) {
            NSString *downloadString = [NSString stringWithFormat:NSLocalizedString(@"Document.Downloading", nil), self.item.downloadItem.progress];
            
            [self.descriptionField setAttributedStringValue:[[NSAttributedString alloc] initWithString:downloadString attributes:@{NSFontAttributeName: TGSystemFont(12), NSForegroundColorAttributeName: NSColorFromRGB(0x9b9b9b)}]];
         } else {
            [self.descriptionField setStringValue:[NSString stringWithFormat:@"%@ • %@",item.fileSize,item.fullDate]];
        }
    }
    
    [self.downloadImageView setHidden:item.isset];
    
    NSImageView *imageView = [self.downloadImageView subviews][0];
    
    imageView.image = item.downloadItem.downloadState == DownloadStateDownloading ? pauseImage() : image_SharedMediaDocumentStatusDownload();
    
    
    int editableOffset = (self.isEditable ? 30 : 0);
    
   // [self.thumbImageView setFrameOrigin:NSMakePoint(s_dox + editableOffset, NSMinY(self.thumbImageView.frame))];
    [self.thumbView setFrameOrigin:NSMakePoint(s_dox + editableOffset, NSMinY(self.thumbView.frame))];
    [self.nameField setFrameOrigin:NSMakePoint(s_dox + 50 + editableOffset, NSMinY(self.nameField.frame))];
    [self.downloadImageView setFrameOrigin:NSMakePoint(s_dox + 50 + editableOffset, NSMinY(self.downloadImageView.frame))];
    [self.descriptionField setFrameOrigin:NSMakePoint(s_dox + 50 + (self.item.isset ? 0 : NSWidth(self.downloadImageView.frame)) + editableOffset, NSMinY(self.descriptionField.frame))];
    [self.selectButton setFrameOrigin:NSMakePoint(!self.isEditable ? 0 : 20, NSMinY(self.selectButton.frame))];
    
    
    
    
    [self.selectButton setHidden:!self.isEditable];
    
    [self.selectButton setSelected:self.isSelected];
}



-(void)updateDownloadState {
    
    
    [self updateCellState];
    
    weak();
    
    if(self.item.downloadItem) {
        
        [self.item.downloadItem removeEvent:_downloadEventListener];
        
         _downloadEventListener = [[DownloadEventListener alloc] init];
        
        [self.item.downloadItem addEvent:_downloadEventListener];
        
       
        
        [_downloadEventListener setCompleteHandler:^(DownloadItem * item) {
            
            [[ASQueue mainQueue] dispatchOnQueue:^{
                weakSelf.item.downloadItem = nil;
                [weakSelf updateCellState];
                [weakSelf setNeedsDisplay:YES];
            }];
            
        }];
        
        [_downloadEventListener setProgressHandler:^(DownloadItem * item) {
            
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
    
    if(self.isEditable) {
        [self mouseDown:[NSApp currentEvent]];
        return;
    }
    
    if([url isEqualToString:@"finder"]) {
        if(self.item.isset)
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:((MessageTableItemDocument *)self.item).path]]];
        else
            [self startDownload];
    }
}

-(void)rightMouseDown:(NSEvent *)theEvent {
    
    if(self.isEditable)
        return;
    
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
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Message.File.ShowInFinder", nil) withBlock:^(id sender) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:((MessageTableItemDocument *)self.item).path]]];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.SaveAs", nil) withBlock:^(id sender) {
            [self performSelector:@selector(saveAs:) withObject:self];
        }]];
        
        [menu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.CopyToClipBoard", nil) withBlock:^(id sender) {
            [self performSelector:@selector(copy:) withObject:self];
        }]];
        
        
        NSArray *apps = [FileUtils appsForFileUrl:((MessageTableItemDocument *)self.item).path];
        
        NSMenuItem *openWithItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.OpenWith", nil) withBlock:nil];
        
        NSMenu *openWithMenu = [[NSMenu alloc] initWithTitle:@"Open"];
        
         [openWithItem setSubmenu:openWithMenu];
        
        if(apps.count > 0) {
            
           
            
            for (OpenWithObject *a in apps) {
                NSMenuItem *item = [NSMenuItem menuItemWithTitle:[a fullname] withBlock:^(id sender) {
                    
                    [[NSWorkspace sharedWorkspace] openFile:((MessageTableItemDocument *)self.item).path withApplication:[a.app path]];
                    
                    
                }];
                
                [item setImage:[a icon]];
                
                [openWithMenu addItem:item];
                
            }
            
            [openWithMenu addItem:[NSMenuItem separatorItem]];
            
           
        }
        
        [openWithMenu addItem:[NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Other", nil) withBlock:^(id sender) {
            
            NSOpenPanel *openPanel = [NSOpenPanel openPanel];
            
            
            NSArray *appsPaths = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationDirectory inDomains:NSLocalDomainMask];
            if ([appsPaths count]) [openPanel setDirectoryURL:[appsPaths firstObject]];
            
            [openPanel setCanChooseDirectories:NO];
            [openPanel setCanChooseFiles:YES];
            [openPanel setAllowsMultipleSelection:NO];
            [openPanel setResolvesAliases:YES];
            
            [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
                if (result == NSFileHandlingPanelOKButton) {
                    if ([[openPanel URLs] count] > 0) {
                        NSURL *app = [[openPanel URLs] objectAtIndex:0];
                        NSString *path = [app path];
                        
                        [[NSWorkspace sharedWorkspace] openFile:((MessageTableItemDocument *)self.item).path withApplication:path];
                    }
                }
            }];
            
            
        }]];
        
        
        [menu addItem:openWithItem];
        
        
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

-(void)setSelected:(BOOL)selected {
    [self.selectButton setSelected:selected];
}

-(BOOL)isSelected {
    return [(TGDocumentsMediaTableView *)self.item.table isSelectedItem:self.item];
}

-(BOOL)isEditable {
    return [(TGDocumentsMediaTableView *)self.item.table isEditable];
}

-(void)setEditable:(BOOL)editable animated:(BOOL)animated {
    
    [self.selectButton setSelected:self.isSelected];
    
    
    if(animated) {
        
        [self.selectButton setHidden:NO];
        
        [self.selectButton setAlphaValue:1];
        
        if(editable){
            [self.selectButton setAlphaValue:0];
        }
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            
            [context setDuration:0.2];
            
            int editableOffset = (self.isEditable ? 30 : 0);
            
           // [[self.thumbImageView animator] setFrameOrigin:NSMakePoint(s_dox + editableOffset, NSMinY(self.thumbImageView.frame))];
            [[self.thumbView animator] setFrameOrigin:NSMakePoint(s_dox + editableOffset, NSMinY(self.thumbView.frame))];
            [[self.nameField animator] setFrameOrigin:NSMakePoint(s_dox + 50 + editableOffset, NSMinY(self.nameField.frame))];
            [[self.downloadImageView animator] setFrameOrigin:NSMakePoint(s_dox + editableOffset + 50, NSMinY(self.downloadImageView.frame))];
            [[self.descriptionField animator] setFrameOrigin:NSMakePoint(s_dox + 50 + (self.item.isset ? 0 : NSWidth(self.downloadImageView.frame)) + editableOffset, NSMinY(self.descriptionField.frame))];
            [[self.selectButton animator] setFrameOrigin:NSMakePoint(!self.isEditable ? 0 : 20, NSMinY(self.selectButton.frame))];
            
            [[self.selectButton animator] setAlphaValue:editable ? 1 : 0];
            
        } completionHandler:^{
            [self setItem:self.item];
        }];

        
//        if(self.selectButton.layer.anchorPoint.x != 0.5) {
//            CGPoint point = self.selectButton.layer.position;
//            
//            point.x += roundf(image_ComposeCheckActive().size.width / 2);
//            point.y += roundf(image_ComposeCheckActive().size.height / 2);
//            
//            self.selectButton.layer.position = point;
//            self.selectButton.layer.anchorPoint = CGPointMake(0.5, 0.5);
//        }
//        
//        if(animated) {
//            
//            float duration = 1 / 18.f;
//            float to = 0.9;
//            
//            POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//            scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
//            scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(to, to)];
//            scaleAnimation.duration = duration / 2;
//            [scaleAnimation setCompletionBlock:^(POPAnimation *anim, BOOL result) {
//                if(result) {
//                    POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//                    scaleAnimation.fromValue  = [NSValue valueWithCGSize:CGSizeMake(to, to)];
//                    scaleAnimation.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
//                    scaleAnimation.duration = duration / 2;
//                    [self.selectButton.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
//                }
//            }];
//            
//            [self.selectButton.layer pop_addAnimation:scaleAnimation forKey:@"scale"];
//            
//            
//        }
        
        
        
        
    } else {
        [self setItem:self.item];
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
    
    if([self.item canShare]) {
        
        
        NSArray *shareServiceItems = [NSSharingService sharingServicesForItems:@[self.item.shareObject]];
        
        NSMenu *shareMenu = [[NSMenu alloc] initWithTitle:@"Share"];
        
        
        for (NSSharingService *currentService in shareServiceItems) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:currentService.title action:@selector(selectedSharingServiceFromMenuItem:) keyEquivalent:@""];
            item.image = currentService.image;
            item.representedObject = currentService;
            [shareMenu addItem:item];
        }
        
        NSMenuItem *shareSubItem = [NSMenuItem menuItemWithTitle:NSLocalizedString(@"Context.Share",nil) withBlock:nil];
        
        [shareSubItem setSubmenu:shareMenu];
        
        [items addObject:shareSubItem];
        
        [items addObject:[NSMenuItem separatorItem]];
        
    }
    
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

- (void)selectedSharingServiceFromMenuItem:(NSMenuItem *)menuItem
{
    NSURL *fileURL = self.item.shareObject;
    if (!fileURL) return;
    
    NSSharingService *service = menuItem.representedObject;
    if (![service isKindOfClass:[NSSharingService class]]) return; // just to make sure…
    
    [service performWithItems:@[fileURL]];
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
        
        [mutableAttributedString setFont:TGSystemFont(12) forRange:mutableAttributedString.range];
        
        instance = mutableAttributedString;
    });
    return instance;
}

@end
