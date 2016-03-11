//
//  TGWebpageDocumentObject.h
//  Telegram
//
//  Created by keepcoder on 12/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGWebpageObject.h"

@interface TGWebpageDocumentObject : TGWebpageObject

-(TL_localMessage *)fakeMessage;
@property (nonatomic,strong,readonly) MessageTableItem *documentItem;

@end
