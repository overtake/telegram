//
//  CompressedSecretFileSenderItem.m
//  Telegram
//
//  Created by keepcoder on 16/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "CompressedSecretFileSenderItem.h"

@interface CompressedSecretFileSenderItem ()
@property (nonatomic,strong) TGCompressItem *item;
@end

@implementation CompressedSecretFileSenderItem

-(id)initWithItem:(TGCompressItem *)compressItem {
    if(self = [super initWithConversation:compressItem.conversation]) {
        _item = compressItem;
        
//        self.message = [MessageSender createOutMessage:nil media:[TL_messageMediaDocument createWithDocument:compressItem.document] conversation:compressItem.conversation];
//        
//        [self.message save:YES];
//        
//        [[NSFileManager defaultManager] moveItemAtPath:compressItem.outputPath toPath:exportPath(self.message.randomId, extensionForMimetype(compressItem.mime_type)) error:nil];
        
        
    }
    
    return self;
}


@end
