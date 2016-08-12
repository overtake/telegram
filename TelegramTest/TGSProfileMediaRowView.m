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
#import "TGTextLabel.h"
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
    
    
    NSArray *filters = @[[TL_inputMessagesFilterPhotoVideo create],[TL_inputMessagesFilterDocument create],[TL_inputMessagesFilterMusic create],[TL_inputMessagesFilterUrl create]];
    
    
    
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
        [attr setFont:TGSystemMediumFont(14) forRange:range];

        [attr appendString:@" "];
        NSRange secondRange = [attr appendString:key withColor:BLUE_UI_COLOR];
        [attr setFont:TGSystemFont(14) forRange:secondRange];

        range.length+= (secondRange.location - range.length - range.location) + secondRange.length;
        
        [attr addAttribute:NSLinkAttributeName value:@"chat://photoOrVideo" range:range];
        
    
    }
    
    if(_filesCounter > 0) {
        NSString *key = _filesCounter == 1 ? NSLocalizedString(@"Modern.SharedMedia.File", nil) : NSLocalizedString(@"Modern.SharedMedia.Files", nil);
        
        
        if(attr.string.length > 0) {
            [attr appendString:@"   "];
        }
       
        
        
        NSRange range = [attr appendString:[NSString stringWithFormat:@"%d",_filesCounter] withColor:BLUE_UI_COLOR];
        [attr setFont:TGSystemMediumFont(14) forRange:range];

        [attr appendString:@" "];
        NSRange secondRange = [attr appendString:key withColor:BLUE_UI_COLOR];
        [attr setFont:TGSystemFont(14) forRange:secondRange];

        range.length+= (secondRange.location - range.length - range.location) + secondRange.length;
        
        [attr addAttribute:NSLinkAttributeName value:@"chat://files" range:range];
        
    }
    
    if(_audioCounter > 0) {
        
        NSString *key = _audioCounter == 1 ? NSLocalizedString(@"Modern.SharedMedia.Audio", nil) : NSLocalizedString(@"Modern.SharedMedia.Audios", nil);
       
        if(attr.string.length > 0) {
            [attr appendString:@"    "];
        }
        NSRange range = [attr appendString:[NSString stringWithFormat:@"%d",_audioCounter] withColor:BLUE_UI_COLOR];
        [attr setFont:TGSystemMediumFont(14) forRange:range];

        [attr appendString:@" "];
        NSRange secondRange = [attr appendString:key withColor:BLUE_UI_COLOR];
        [attr setFont:TGSystemFont(14) forRange:secondRange];

        range.length+= (secondRange.location - range.length - range.location) + secondRange.length;
        
        [attr addAttribute:NSLinkAttributeName value:@"chat://audio" range:range];


    }
    
    if(_linksCounter > 0) {
        
        NSString *key = _linksCounter == 1 ? NSLocalizedString(@"Modern.SharedMedia.Link", nil) : NSLocalizedString(@"Modern.SharedMedia.Links", nil);
        
        if(attr.string.length > 0) {
            [attr appendString:@"    "];
        }
        NSRange range = [attr appendString:[NSString stringWithFormat:@"%d",_linksCounter] withColor:BLUE_UI_COLOR];
        [attr setFont:TGSystemMediumFont(14) forRange:range];
        [attr appendString:@" "];
        NSRange secondRange = [attr appendString:key withColor:BLUE_UI_COLOR];
        [attr setFont:TGSystemFont(14) forRange:secondRange];

        range.length+= (secondRange.location - range.length - range.location) + secondRange.length;
        
        [attr addAttribute:NSLinkAttributeName value:@"chat://links" range:range];
        
    }
    
    
    
    _loaderString = attr;
    
}


@end


@interface TGSProfileMediaRowView () <TMHyperlinkTextFieldDelegate>
@property (nonatomic,strong) TGTextLabel *headerTextField;
@property (nonatomic,strong) TGTextLabel *countersTextField;

@property (nonatomic,strong) NSProgressIndicator *progressIndicator;

@property (nonatomic,strong) NSMutableAttributedString *headerAttr;

@end

@implementation TGSProfileMediaRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
   // [DIALOG_BORDER_COLOR setFill];
    
   // NSRectFill(NSMakeRect(self.item.xOffset, 0, NSWidth(dirtyRect) - self.item.xOffset * 2, DIALOG_BORDER_WIDTH));
}


static NSMutableDictionary *counters;
static NSMutableDictionary *loaders;
+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        counters = [[NSMutableDictionary alloc] init];
        loaders = [[NSMutableDictionary alloc] init];
        
        [Notification addObserver:self selector:@selector(didReceiveMessage:) name:MESSAGE_RECEIVE_EVENT];
        [Notification addObserver:self selector:@selector(didReceiveMessageList:) name:MESSAGE_RECEIVE_EVENT];
    });
}


-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _headerTextField = [[TGTextLabel alloc] init];
        
        _countersTextField = [[TGTextLabel alloc] init];
        
        weak();
        
        [_countersTextField setLinkCallback:^(NSString *url) {
            
            if([url isEqualToString:@"chat://audio"]) {
                [TGAudioPlayerWindow show:weakSelf.item.conversation playerState:TGAudioPlayerGlobalStyleList  navigation:self.item.controller.navigationViewController];
                return;
            }
            
            TMCollectionPageController *viewController = [[TMCollectionPageController alloc] initWithFrame:NSZeroRect];
            
            [weakSelf.item.controller.navigationViewController pushViewController:viewController animated:YES];
            
            [viewController setConversation:weakSelf.item.conversation];
            
            if([url isEqualToString:@"chat://files"]) {
                
                [viewController showFiles];
                
            } else if([url isEqualToString:@"chat://links"]) {
                
                [viewController showSharedLinks];
                
            }
            
        }];
        _headerAttr = [[NSMutableAttributedString alloc] init];
        
        [_headerAttr appendString:NSLocalizedString(@"Profile.SharedMedia", nil) withColor:TEXT_COLOR];
        [_headerAttr setFont:TGSystemFont(14) forRange:_headerAttr.range];
        
        [_headerTextField setText:_headerAttr maxWidth:INT32_MAX];
        
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
    
    [_countersTextField setText:loader.loaderString maxWidth:NSWidth(self.frame) - self.item.xOffset*2];
   
    if(loader.isLoaded && loader.loaderString.length == 0 && animated) {
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            
            [[_headerTextField animator] setFrameOrigin:NSMakePoint(self.item.xOffset, roundf((NSHeight(self.frame) - NSHeight(_headerTextField.frame)))/2)];
            
        } completionHandler:^{
            [self updateFrames:NO];
        }];
    } else {
        [self updateFrames:animated];
    }
}

-(void)updateFrames:(BOOL)animated {
    
    TGMediaCounterLoader *loader = loaders[@(self.conversation.peer_id)];
    
    [_countersTextField setText:loader.loaderString maxWidth:NSWidth(self.frame) - self.item.xOffset*2];
    
    [_headerTextField setText:_headerAttr maxWidth:NSWidth(self.frame) - self.item.xOffset*2];
    
    int totalHeight = NSHeight(_countersTextField.frame) + NSHeight(_headerTextField.frame);
    [_countersTextField setFrameOrigin:NSMakePoint(self.item.xOffset, roundf((NSHeight(self.frame) - totalHeight)/2) - 8)];
    [_headerTextField setFrameOrigin:NSMakePoint(self.item.xOffset , roundf((NSHeight(self.frame) - totalHeight)/2) + NSHeight(_countersTextField.frame))];
    
    if(loader.isLoaded && loader.loaderString.length == 0) {
        [_headerTextField setCenteredYByView:self];
    }
    
    id progress = animated ? [_progressIndicator animator] : _progressIndicator;
    
    [progress setFrameOrigin:NSMakePoint(NSMaxX(_countersTextField.frame) + (loader.loaderString.length == 0 ? 0 : 3), 3)];
    
}

-(TGSProfileMediaRowItem *)item {
    return (TGSProfileMediaRowItem *) [self rowItem];
}

-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self updateFrames:NO];
    
}


-(void)mouseUp:(NSEvent *)theEvent {
    if(self.item.callback)
        self.item.callback(self.item);
}

-(void)mouseDown:(NSEvent *)theEvent {
   // [super mouseDown:theEvent];
    
    
}


+(void)didReceiveMessage:(NSNotification *)notification {
    
    [ASQueue dispatchOnMainQueue:^{
        
        TL_localMessage *message = notification.userInfo[KEY_MESSAGE];
        
        TGMediaCounterLoader *loader = loaders[@(message.peer_id)];
        
        [self incrementCountersWithMessage:message toLoader:loader];

    }];
    
}

+(void)incrementCountersWithMessage:(TL_localMessage*)message toLoader:(TGMediaCounterLoader *)loader {
    if(loader) {
        
        NSArray *entities = [message.entities filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.class = %@",[TL_messageEntityUrl class]]];
        
        if((message.media || entities.count > 0)) {
            
            if([message.media isKindOfClass:[TL_messageMediaDocument class]] || [message.media isKindOfClass:[TL_messageMediaDocument_old44 class]]) {
                
                TL_documentAttributeAudio *attr =  (TL_documentAttributeAudio *)[message.media.document attributeWithClass:[TL_documentAttributeAudio class]];
                
                if(attr)
                    loader.audioCounter++;
                else
                    loader.filesCounter++;
                
            } else if([message.media isKindOfClass:[TL_messageMediaPhoto class]] || [message.media isKindOfClass:[TL_messageMediaVideo class]]) {
                
                loader.photoAndVideoCounter++;
                
            } else if([message.media isKindOfClass:[TL_messageMediaWebPage class]] || entities.count > 0) {
                
                loader.linksCounter++;
                
            }
            
            if(loader.changeHandler) {
                [loader updateCountersText];
                loader.changeHandler();
            }
            
            
        }
        
    }
}

+(void)didReceiveMessageList:(NSNotification *)notification {
    [ASQueue dispatchOnMainQueue:^{
        
        NSArray *messages = notification.object;
        
        [messages enumerateObjectsUsingBlock:^(TL_localMessage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            TGMediaCounterLoader *loader = loaders[@(obj.peer_id)];
            if(loader) {
                 [self incrementCountersWithMessage:obj toLoader:loader];
            }
        }];
        
        
        
    }];
}

-(void)viewDidMoveToWindow {
    if(!self.window) {
        TGMediaCounterLoader *loader = loaders[@(self.conversation.peer_id)];
        [loader setChangeHandler:nil];
    }
}

@end
