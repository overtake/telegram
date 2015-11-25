//
//  TGSProfileMediaRowView.m
//  Telegram
//
//  Created by keepcoder on 03/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGSProfileMediaRowView.h"
#import "TGSProfileMediaRowItem.h"
#import "TGAudioPlayerWindow.h"
@interface TGMediaCounterLoader : NSObject
@property (nonatomic,assign) int photoAndVideoCounter;
@property (nonatomic,assign) int filesCounter;
@property (nonatomic,assign) int audioCounter;
@property (nonatomic,assign) int linksCounter;


@property (nonatomic,copy) dispatch_block_t changeHandler;
@property (nonatomic,strong) NSAttributedString *loaderString;


@property (nonatomic,assign) BOOL isLoaded;


@end


@implementation TGMediaCounterLoader

-(instancetype)init {
    if(self = [super init]) {
        _photoAndVideoCounter = 0;
        _filesCounter = 0;
        _audioCounter = 0;
        _linksCounter = 0;
    }
    
    return self;
}

-(void)loadWithConversation:(TL_conversation *)conversation inputPeer:(TLInputPeer *)inputPeer {
  
    if(conversation.type == DialogTypeSecretChat) {
        _isLoaded = YES;
        
        if( _changeHandler) {
            _changeHandler();
        }
        
        return;
    }
    
    
    NSArray *filters = @[[TL_inputMessagesFilterPhotoVideo create],[TL_inputMessagesFilterDocument create],[TL_inputMessagesFilterAudioDocuments create],[TL_inputMessagesFilterUrl create]];
    
    
    
    NSArray *properties = @[@"photoAndVideoCounter",@"filesCounter",@"audioCounter",@"linksCounter"];
    
    
    NSMutableArray *_inwork = [filters mutableCopy];
    
    [filters enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
      //  dispatch_after_seconds(idx, ^{
            [RPCRequest sendRequest:[TLAPI_messages_search createWithFlags:0 peer:inputPeer q:@"" filter:obj min_date:0 max_date:0 offset:0 max_id:0 limit:0] successHandler:^(RPCRequest *request, TL_messages_messages *response) {
                
                
                NSString *property = properties[idx];
                
                int value = [[self valueForKey:property] intValue];
                
                value += MAX([response n_count],[[response messages] count]);
                
                [self setValue:@(value) forKey:property];
                
                [_inwork removeObject:obj];
                
                [self updateCountersText];
                
                _isLoaded = _inwork.count == 0;
                
                if( _changeHandler) {
                    _changeHandler();
                }
                
                if(_isLoaded && conversation.type == DialogTypeChannel && conversation.chat.chatFull.migrated_from_chat_id != 0)  {
                    _isLoaded = NO;
                    
                    [self loadWithConversation:nil inputPeer:[TL_inputPeerChat createWithChat_id:conversation.chat.chatFull.migrated_from_chat_id]];
                }
                
                
            } errorHandler:^(RPCRequest *request, RpcError *error) {
                
                
            }];
      //  });
        
        
    }];
    
    
    
    
}

-(void)updateCountersText {
   
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    if(_photoAndVideoCounter > 0) {
        
        NSString *key = _photoAndVideoCounter == 1 ? NSLocalizedString(@"Modern.SharedMedia.PhotoOrVideo", nil) : NSLocalizedString(@"Modern.SharedMedia.PhotosAndVideos", nil);
        
        NSRange range = [attr appendString:[NSString stringWithFormat:@"%d",_photoAndVideoCounter] withColor:BLUE_UI_COLOR];
        [attr appendString:@" "];
        NSRange secondRange = [attr appendString:key withColor:GRAY_TEXT_COLOR];
        
        range.length+= (secondRange.location - range.length - range.location) + secondRange.length;
        
        [attr addAttribute:NSLinkAttributeName value:@"photoOrVideo" range:range];
        
    
    }
    
    if(_filesCounter > 0) {
        NSString *key = _filesCounter == 1 ? NSLocalizedString(@"Modern.SharedMedia.File", nil) : NSLocalizedString(@"Modern.SharedMedia.Files", nil);
        
        
        if(attr.string.length > 0) {
            [attr appendString:@"," withColor:GRAY_TEXT_COLOR];
            [attr appendString:@" "];
        }
       
        
        
        NSRange range = [attr appendString:[NSString stringWithFormat:@"%d",_filesCounter] withColor:BLUE_UI_COLOR];
        [attr appendString:@" "];
        NSRange secondRange = [attr appendString:key withColor:GRAY_TEXT_COLOR];
        
        range.length+= (secondRange.location - range.length - range.location) + secondRange.length;
        
        [attr addAttribute:NSLinkAttributeName value:@"files" range:range];
        
    }
    
    if(_audioCounter > 0) {
        
        NSString *key = _audioCounter == 1 ? NSLocalizedString(@"Modern.SharedMedia.Audio", nil) : NSLocalizedString(@"Modern.SharedMedia.Audios", nil);
       
        if(attr.string.length > 0) {
            [attr appendString:@"," withColor:GRAY_TEXT_COLOR];
            [attr appendString:@" "];
        }
        NSRange range = [attr appendString:[NSString stringWithFormat:@"%d",_audioCounter] withColor:BLUE_UI_COLOR];
        [attr appendString:@" "];
        NSRange secondRange = [attr appendString:key withColor:GRAY_TEXT_COLOR];
        
        range.length+= (secondRange.location - range.length - range.location) + secondRange.length;
        
        [attr addAttribute:NSLinkAttributeName value:@"audio" range:range];


    }
    
    if(_linksCounter > 0) {
        
        NSString *key = _linksCounter == 1 ? NSLocalizedString(@"Modern.SharedMedia.Link", nil) : NSLocalizedString(@"Modern.SharedMedia.Links", nil);
        
        if(attr.string.length > 0) {
            [attr appendString:@"," withColor:GRAY_TEXT_COLOR];
            [attr appendString:@" "];
        }
        NSRange range = [attr appendString:[NSString stringWithFormat:@"%d",_linksCounter] withColor:BLUE_UI_COLOR];
        [attr appendString:@" "];
        NSRange secondRange = [attr appendString:key withColor:GRAY_TEXT_COLOR];
        
        range.length+= (secondRange.location - range.length - range.location) + secondRange.length;
        
        [attr addAttribute:NSLinkAttributeName value:@"links" range:range];
        
    }
    
    
    [attr setFont:TGSystemFont(14) forRange:attr.range];
    
    _loaderString = attr;
    
}


@end


@interface TGSProfileMediaRowView () <TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) TMTextField *headerTextField;
@property (nonatomic,strong) TMHyperlinkTextField *countersTextField;

@property (nonatomic,strong) NSProgressIndicator *progressIndicator;

@end

@implementation TGSProfileMediaRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [DIALOG_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(self.item.xOffset, 0, NSWidth(dirtyRect) - self.item.xOffset * 2, DIALOG_BORDER_WIDTH));
}


static NSMutableDictionary *counters;
static NSMutableDictionary *loaders;
+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        counters = [[NSMutableDictionary alloc] init];
        loaders = [[NSMutableDictionary alloc] init];
    });
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _headerTextField = [TMTextField defaultTextField];
        _countersTextField = [TMHyperlinkTextField defaultTextField];
        
        _countersTextField.url_delegate = self;
        
        [_countersTextField setFont:TGSystemFont(13)];
        
        [_headerTextField setStringValue:NSLocalizedString(@"Profile.SharedMedia", nil)];
        [_headerTextField setFont:TGSystemFont(14)];
        [_headerTextField setTextColor:TEXT_COLOR];
        [_headerTextField sizeToFit];
        
        
        [[_headerTextField cell] setTruncatesLastVisibleLine:YES];
        [[_headerTextField cell] setTruncatesLastVisibleLine:YES];
        
        
        [[_countersTextField cell] setTruncatesLastVisibleLine:YES];
        [[_countersTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        _progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 15, 15)];
        [_progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        [self addSubview:_progressIndicator];
        
        [self addSubview:_headerTextField];
        [self addSubview:_countersTextField];
        
    }
    
    return self;
}

-(void)textField:(id)textField handleURLClick:(NSString *)url {
    
    // handle
    if([url isEqualToString:@"audio"]) {
        [TGAudioPlayerWindow show:self.item.conversation playerState:TGAudioPlayerWindowStatePlayList];
        return;
    }
    
    TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:NSZeroRect];
    
    [self.item.controller.navigationViewController pushViewController:viewController animated:YES];
    
    [viewController setConversation:self.item.conversation];
    
    if([url isEqualToString:@"files"]) {
        
        [viewController showFiles];
        
    } else if([url isEqualToString:@"links"]) {
        
        [viewController showSharedLinks];
        
    }
    
    
    
}

-(void)redrawRow {
    [super redrawRow];
    
    [self loadOrConfigure];
    
}

-(TL_conversation *)conversation {
   return [(TGSProfileMediaRowItem *)[self rowItem] conversation];
}



-(void)loadOrConfigure {
   
    TGMediaCounterLoader *loader = loaders[@(self.conversation.peer_id)];
    
    if(!loader) {
        loader = [[TGMediaCounterLoader alloc] init];
        [loader loadWithConversation:self.conversation inputPeer:self.conversation.inputPeer];
        
        loaders[@(self.conversation.peer_id)] = loader;
    }
    
    [loader setChangeHandler:^{
        [self updateText:YES];
    }];
    
    
    [self updateText:NO];
    
}


-(void)updateText:(BOOL)animated {
    TGMediaCounterLoader *loader = loaders[@(self.conversation.peer_id)];
    
    
    [_progressIndicator setHidden:loader.isLoaded];
    
    if(loader.isLoaded)
        [_progressIndicator stopAnimation:self];
    else
        [_progressIndicator startAnimation:self];
    
    [_countersTextField setAttributedStringValue:loader.loaderString];
    
    [_countersTextField sizeToFit];
    
    
    
    if(loader.isLoaded && loader.loaderString.length == 0 && animated) {
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            
            [[_headerTextField animator] setFrameOrigin:NSMakePoint(self.item.xOffset - 2, roundf((NSHeight(self.frame) - NSHeight(_headerTextField.frame)))/2)];
            
        } completionHandler:^{
            [self updateFrames:NO];
        }];
    } else {
        [self updateFrames:animated];
    }
}

-(void)updateFrames:(BOOL)animated {
    [_countersTextField setFrameSize:NSMakeSize(MIN(NSWidth(_countersTextField.frame), NSWidth(self.frame) - 60 - NSWidth(_progressIndicator.frame)) , NSHeight(_countersTextField.frame))];
    
    
    TGMediaCounterLoader *loader = loaders[@(self.conversation.peer_id)];
    
    int totalHeight = NSHeight(_countersTextField.frame) + NSHeight(_headerTextField.frame);
    [_countersTextField setFrameOrigin:NSMakePoint(self.item.xOffset - 2, roundf((NSHeight(self.frame) - totalHeight)/2))];
    [_headerTextField setFrameOrigin:NSMakePoint(self.item.xOffset - 2, roundf((NSHeight(self.frame) - totalHeight)/2) + NSHeight(_countersTextField.frame))];
    
    if(loader.isLoaded && loader.loaderString.length == 0) {
        [_headerTextField setCenteredYByView:self];
    }
    
    id progress = animated ? [_progressIndicator animator] : _progressIndicator;
    
    [progress setFrameOrigin:NSMakePoint(NSMaxX(_countersTextField.frame) + (_countersTextField.attributedStringValue.length == 0 ? 0 : 3), NSMinY(_countersTextField.frame) + 1)];
    
}

-(TGSProfileMediaRowItem *)item {
    return (TGSProfileMediaRowItem *) [self rowItem];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self updateFrames:NO];
    
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    if(self.item.callback)
        self.item.callback(self.item);
}

@end
