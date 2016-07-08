//
//  TGModernSearchvViewController.h
//  Telegram
//
//  Created by keepcoder on 06/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMViewController.h"

@interface TGModernSearchvViewController : TMViewController

typedef enum {
    TGModernSearchTypeDialogs = 1 << 1,
    TGModernSearchTypeHashtags = 1 << 3,
    TGModernSearchTypeMessages = 1 << 4,
    TGModernSearchTypeGlobalUsers = 1 << 5
    
} TGModernSearchType;

@property (nonatomic,assign) TGModernSearchType type;

-(void)search:(NSString *)search;

-(int)selectedPeerId;
- (void)selectFirst;
-(void)dontLoadHashTagsForOneRequest;

@end
