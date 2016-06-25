//
//  TGStickerPackRowView.h
//  Telegram
//
//  Created by keepcoder on 24/06/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMRowView.h"
#import "TGImageView.h"
@interface TGStickerPackRowView : TMRowView
@property (nonatomic,strong) TMTextField *titleField;
@property (nonatomic,strong) TGImageView *imageView;
@property (nonatomic,strong) TMView *imageContainerView;

@property (nonatomic,strong) BTRButton *deletePack;
@property (nonatomic,strong) NSImageView *reorderPack;
@property (nonatomic,strong) BTRButton *disablePack;


@property (nonatomic,strong) TMView *separator;

-(void)setEditable:(BOOL)editable animated:(BOOL)animated;

@property (nonatomic,weak) TGStickersSettingsViewController *controller;
@end
