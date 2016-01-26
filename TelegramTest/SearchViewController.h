//
//  SearchViewController.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 12/28/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMElements.h"
#import "SearchLoaderItem.h"
#import "SearchLoaderCell.h"

@interface SearchViewController : TMViewController<TMTableViewDelegate>


typedef enum {
    SearchTypeContacts = 1 << 1,
    SearchTypeDialogs = 1 << 3,
    SearchTypeMessages = 1 << 4,
    SearchTypeGlobalUsers = 1 << 5
    
} SearchType;

@property (nonatomic,assign) int type;


- (void) searchByString:(NSString*)searchString;

-(int)selectedPeerId;

-(void)dontLoadHashTagsForOneRequest;

@end
