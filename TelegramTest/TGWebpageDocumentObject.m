//
//  TGWebpageDocumentObject.m
//  Telegram
//
//  Created by keepcoder on 12/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGWebpageDocumentObject.h"
#import "DownloadDocumentItem.h"
#import "DownloadQueue.h"
#import "NSNumber+NumberFormatter.h"
#import "MessageTableItem.h"
#import "NSStringCategory.h"
@interface TGWebpageDocumentObject ()
@property (nonatomic,strong) TL_localMessage *fakeMessage;
@end

@implementation TGWebpageDocumentObject

@synthesize size = _size;


-(id)initWithWebPage:(TLWebPage *)webpage tableItem:(MessageTableItem *)item {
    if(self = [super initWithWebPage:webpage tableItem:item]) {
        
        
        TL_localMessage *fake = [[TL_localMessage alloc] init];
        
        fake.media = [TL_messageMediaDocument createWithDocument:self.webpage.document caption:webpage.n_description];
        fake.n_id = rand_int();
        _documentItem = [MessageTableItem messageItemFromObject:fake];
        
        _fakeMessage = fake;

        
    }
    
    return self;
}




-(TL_localMessage *)fakeMessage {
    return _fakeMessage;
}




-(Class)webpageContainer {
    return NSClassFromString(@"TGWebpageDocumentContainer");
}

-(void)makeSize:(int)width {
    [super makeSize:width];
    [_documentItem makeSizeByWidth:width];
    _size = NSMakeSize(width , _documentItem.blockSize.height );
        
}

-(int)blockHeight {
    return _documentItem.blockSize.height;
}

@end
