//
//  MessageTableCellPhotoView.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 2/12/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "MessageTableCell.h"
#import "TGModernMessageCellContainerView.h"
#import "MessageTableItemPhoto.h"
#import "BluredPhotoImageView.h"
@interface MessageTableCellPhotoView : TGModernMessageCellContainerView
@property (nonatomic, strong) TGImageView *imageView;
@end
