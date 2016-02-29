//
//  MessageTableCellDocumentView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGModernMessageCellContainerView.h"
#import "MessageTableItemDocument.h"
#import "TGImageView.h"

#import "DownloadQueue.h"

@interface DocumentThumbImageView : TGImageView

@end

@interface MessageTableCellDocumentView : TGModernMessageCellContainerView

@property (nonatomic, strong) DocumentThumbImageView *thumbView;


@end
