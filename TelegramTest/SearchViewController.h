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

- (void) searchByString:(NSString*)searchString;

@end
