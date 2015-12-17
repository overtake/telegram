//
//  CompressedDocumentSenderItem.m
//  Telegram
//
//  Created by keepcoder on 16/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "CompressedDocumentSenderItem.h"

@interface DocumentSenderItem ()
-(void)performRequest;
@end

@interface CompressedDocumentSenderItem ()<TGCompressDelegate>
@property (nonatomic,strong) TGCompressItem *item;
@end

@implementation CompressedDocumentSenderItem

-(id)initWithItem:(TGCompressItem *)compressItem {
    if(self = [super initWithConversation:compressItem.conversation]) {
        self.item = compressItem;
        
        long randomId = rand_long();
        
        TL_compressDocument *document = [TL_compressDocument createWithN_id:randomId access_hash:0 date:[[MTNetwork instance] getTime] mime_type:compressItem.mime_type size:0 thumb:[TL_photoSizeEmpty createWithType:@"x"] dc_id:0 attributes:[compressItem.attributes mutableCopy] compressor:[NSKeyedArchiver archivedDataWithRootObject:_item]];
        
       
        self.message = [MessageSender createOutMessage:nil media:[TL_messageMediaDocument createWithDocument:document] conversation:compressItem.conversation];
        self.message.randomId = document.n_id;
        [self.message save:YES];
        

    }
    
    return self;
}

-(void)didStartCompressing:(id)item {
    
}

-(void)performRequest {
    [self.item readyAndStart];
}


-(void)didEndCompressing:(TGCompressItem *)item success:(BOOL)success {
    if(item == _item) {
        [ASQueue dispatchOnStageQueue:^{
            
            if(success) {
                [[NSFileManager defaultManager] moveItemAtPath:item.outputPath toPath:exportPath(self.message.randomId, extensionForMimetype(item.mime_type)) error:nil];
                
                [super performRequest];
            } else {
                self.state = MessageSendingStateError;
            }
            
        }];
       
        
        
    }
}
-(void)didProgressUpdate:(id)item progress:(int)progress {
    
}
-(void)didCancelCompressing:(id)item {
    
}

-(void)setItem:(TGCompressItem *)item {
    _item = item;
    _item.delegate = self;
}

-(void)setMessage:(TL_localMessage *)message {
    [super setMessage:message];
    
    self.item = [NSKeyedUnarchiver unarchiveObjectWithData:message.media.document.compressor];
}

@end
