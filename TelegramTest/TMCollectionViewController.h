//
//  TMCollectionViewController.h
//  Messenger for Telegram
//
//  Created by keepcoder on 08.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CollectionScrollView : TMScrollView {
      BOOL currentScrollIsHorizontal;
}
@end

@interface TMCollectionView : NSCollectionView

@end

@interface TMCollectionViewController : NSViewController<NSCollectionViewDelegate> {
    IBOutlet NSArrayController *arrayController;
}
@property (weak) IBOutlet NSCollectionView *collectionController;

@property (nonatomic,strong) NSMutableArray *data;


-(void)setItems:(NSArray *)items conversation:(TL_conversation *)conversation;

@end
