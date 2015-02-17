//
//  TMSharedMediaButton.m
//  Telegram
//
//  Created by keepcoder on 03.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMSharedMediaButton.h"
#import "TMMediaController.h"
#import "TLChatCategory.h"
#import "TLPeer+Extensions.h"
@interface TMSharedMediaButton ()
@property (nonatomic,strong) TMTextField *field;
@property (nonatomic,assign) int count;
@property (nonatomic,strong) RPCRequest *request;
@property (nonatomic,strong) TMView *container;
@property (nonatomic,strong) NSImageView *imageView;
@end
@implementation TMSharedMediaButton

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

static const NSMutableDictionary *cache;


+(void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
        cache[@"files"] = [[NSMutableDictionary alloc] init];
        cache[@"photo-video"] = [[NSMutableDictionary alloc] init];
        [Notification addObserver: [TMSharedMediaButton reserved] selector:@selector(didReceivedMedia:) name:MEDIA_RECEIVE];
        [Notification addObserver: [TMSharedMediaButton reserved] selector:@selector(didDeletedMessages:) name:MESSAGE_DELETE_EVENT];
    });
}

-(id)initWithFrame:(NSRect)frame withName:(NSString *)name andBlock:(dispatch_block_t)block {
    if(self = [super initWithFrame:frame withName:name andBlock:block]) {
        self.container = [[TMView alloc] initWithFrame:NSZeroRect];
        
        
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image_ArrowGrey().size.width, image_ArrowGrey().size.height)];
        self.imageView .image = image_ArrowGrey();
        [self.container addSubview:self.imageView];
        
        
        self.field = [TMTextField defaultTextField];
        [self.container addSubview:self.field];
        
    }
    
    return self;
}

-(void)didDeletedMessages:(NSNotification *)notification {
    
    NSArray *ids = notification.userInfo[KEY_MESSAGE_ID_LIST];
    
    [ids enumerateObjectsUsingBlock:^(NSNumber *msg_id, NSUInteger idx, BOOL *stop) {
        
        TL_localMessage *msg = [[MessagesManager sharedManager] find:[msg_id intValue]];
        
        if([msg.media isKindOfClass:[TL_messageMediaPhoto class]] && !self.isFiles) {
            
            NSNumber *count = cache[[self primaryKey]][@(msg.peer_id)];
            
            if(count != nil) {
                cache[[self primaryKey]][@(msg.peer_id)] = @([count intValue] - 1);
            }
        }
        
    }];
    
}



-(void)dealloc {
    [Notification removeObserver:self];
}

+(TMSharedMediaButton *)reserved {
    static TMSharedMediaButton *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMSharedMediaButton alloc] init];
    });
    
    return instance;
}


- (void)didReceivedMedia:(NSNotification *)notify {
    PreviewObject *preview = notify.userInfo[KEY_PREVIEW_OBJECT];
    if(cache[[self primaryKey]][@(preview.peerId)] != nil && [[preview.media media] isKindOfClass:[TL_messageMediaPhoto class]] && !self.isFiles) {
        int count = [cache[[self primaryKey]][@(preview.peerId)] intValue];
        count++;
        cache[[self primaryKey]][@(preview.peerId)] = @(count);
        
        if(preview.peerId == self.conversation.peer.peer_id) {
            self.count = count;
        }
    }
}


+ (id) buttonWithText:(NSString *)string tapBlock:(dispatch_block_t)block {
    TMSharedMediaButton *view = [[TMSharedMediaButton alloc] initWithFrame:NSZeroRect withName:string andBlock:block];
    return view;
}

-(void)setConversation:(TL_conversation *)conversation {
    self->_conversation = conversation;
    
    if(cache[[self primaryKey]][@(conversation.peer.peer_id)] == nil) {
        
        [self setLocked:YES];
        [self loadCount:[conversation inputPeer] peer_id:conversation.peer.peer_id];

    } else {
        self.count = [cache[[self primaryKey]][@(conversation.peer.peer_id)] intValue];
    }
    
}

-(void)loadCount:(TLInputPeer *)input peer_id:(int)peer_id {
    
   
    
    //self.count = [[Storage manager] countOfMedia:peer_id];
    
    
    [RPCRequest sendRequest:[TLAPI_messages_search createWithPeer:input q:@"" filter:self.isFiles ? [TL_inputMessagesFilterDocument create] : [TL_inputMessagesFilterPhotoVideo create] min_date:0 max_date:0 offset:0 max_id:0 limit:10000] successHandler:^(RPCRequest *request, TL_messages_messages *response) {
        
        [self setLocked:NO];
        
        self.count = (int) MAX(response.n_count,response.messages.count);
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        
        
    }];
}

-(void)setCount:(int)count {
    self->_count = count;
    cache[[self primaryKey]][@(self.conversation.peer.peer_id)] = @(self.count);
    [self rebuild];
}

-(NSString *)primaryKey {
    return self.isFiles ? @"files" : @"photo-video";
}

-(void)rebuild {
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    NSString *str =  self.count > 0 ? [NSString stringWithFormat:@"%d",self.count] : NSLocalizedString(@"SharedMedia.None", nil);
    
    [string appendString:str withColor:NSColorFromRGB(0xa1a1a1)];
    
    [string setFont:[NSFont fontWithName:@"HelveticaNeue-Light" size:15] forRange:string.range];
    
    
    [self.field setAttributedStringValue:string];
    
    [self.field sizeToFit];
    
    [self.container setFrameSize:NSMakeSize(NSWidth(self.field.frame) + 10 + NSWidth(self.imageView.frame) + 4, NSHeight(self.field.frame))];
    
  
    [self.imageView setFrameOrigin:NSMakePoint(NSWidth(self.field.frame) + 10, 3)];
    
    
    self.rightContainer = self.container;
    
 //   [self.rightContainer setFrameOrigin:NSMakePoint(NSMinX(self.rightContainer.frame), 12)];
    
}

- (void)updateRightControllerFrame {
    [self.rightContainer setFrame:NSMakeRect(roundf(self.frame.size.width - self.container.frame.size.width) + self.rightContainerOffset.x, 12,NSWidth(self.container.frame), NSHeight(self.container.frame))];
}


@end
