//
//  StandartViewController.h
//  Telegram
//
//  Created by keepcoder on 27.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMViewController.h"
#import "SearchViewController.h"
@interface StandartViewController : TMViewController
@property (nonatomic, strong, readonly) SearchViewController *searchViewController;

@property (nonatomic,strong) NSView *searchView;
@property (nonatomic,strong) NSView *mainView;

-(BOOL)isSearchActive;
+(NSMenu *)attachMenu;
-(void)hideSearchViewControllerWithConversationUsed:(TL_conversation*)conversation;
-(void)searchByString:(NSString *)searchString;
@end
