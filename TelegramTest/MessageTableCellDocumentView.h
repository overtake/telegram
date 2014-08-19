//
//  MessageTableCellDocumentView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/14/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCellContainerView.h"
#import "MessageTableItemDocument.h"
#import "TGImageView.h"

#import "DownloadQueue.h"

@interface DocumentThumbImageView : TGImageView

@end

@interface MessageTableCellDocumentView : MessageTableCellContainerView<TMHyperlinkTextFieldDelegate>

@property (nonatomic, strong) DocumentThumbImageView *thumbView;

- (void)redrawThumb:(NSImage *)image;

@end
