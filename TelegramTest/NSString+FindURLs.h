//
//  NSString+FindURLs.h
//  timezone
//
//  Created by Randall Brown on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_FindURLs)


- (NSArray *) arrayOfLinks:(NSArray *)results;
- (NSArray *) locationsOfLinks;

@end
