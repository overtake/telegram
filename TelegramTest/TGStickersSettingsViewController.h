//
//  TGStickersSettingsViewController.h
//  Telegram
//
//  Created by keepcoder on 11.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "ComposeViewController.h"
#import "TGStickerPackRowItem.h"
@interface TGStickersSettingsViewController : ComposeViewController
-(void)removeStickerPack:(TGStickerPackRowItem *)item;
@end
