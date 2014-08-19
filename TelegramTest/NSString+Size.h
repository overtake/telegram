//
//  NSString+ContainerSize.h
//
//  Created by Michael Robinson on 6/03/12.
//  License: http://pagesofinterest.net/license/
//
//  Based on the Stack Overflow answer: http://stackoverflow.com/a/1993376/187954
//

#import <Foundation/Foundation.h>

@interface NSString (Size)

- (NSSize) sizeWithWidth:(float)width andFont:(NSFont *)font;

@end