//
//  TGModalSetCaptionView.h
//  Telegram
//
//  Created by keepcoder on 23.04.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGAttachObject.h"
@interface TGModalSetCaptionView : TMView

@property (nonatomic,strong) dispatch_block_t onClose;

-(void)prepareWithAttachment:(TGAttachObject *)attachment;
-(void)prepareAttachmentViews:(NSArray *)attachments;
@end
