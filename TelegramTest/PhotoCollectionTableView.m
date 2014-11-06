//
//  PhotoCollectionTableView.m
//  Telegram
//
//  Created by keepcoder on 04.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "PhotoCollectionTableView.h"

#import "TMPreviewPhotoItem.h"
@interface PhotoCollectionTableView ()
@property (nonatomic,strong) TL_conversation *conversation;
@end

@implementation PhotoCollectionTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

//-(BOOL)isFlipped {
//    return NO;
//}


@end
