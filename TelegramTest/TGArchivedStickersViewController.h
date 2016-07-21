//
//  TGArchivedStickersViewController.h
//  Telegram
//
//  Created by keepcoder on 21/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface TGArchivedStickersViewController : TMViewController
-(SSignal *)loadNext:(long)offsetId;
-(void)addSets:(NSArray *)sets;
@end
