//
//  MessageTableCellPhotoView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCell.h"
#import "MessageTableCellContainerView.h"
#import "MessageTableItemPhoto.h"
#import "BluredPhotoImageView.h"
@interface MessageTableCellPhotoView : MessageTableCellContainerView
@property (nonatomic, strong) BluredPhotoImageView *imageView;
@end
