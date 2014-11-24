//
//  TMPreviewDocumentItem.h
//  Messenger for Telegram
//
//  Created by keepcoder on 12.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMPreviewPhotoItem.h"

@interface TMPreviewDocumentItem : NSObject<TMPreviewItem>
- (TLDocument *)document;
@end
