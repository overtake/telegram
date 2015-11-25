//
//  TLDocument+Extension.h
//  Telegram
//
//  Created by keepcoder on 15.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLDocument (Extension)

-(int)duration;
-(NSString *)file_name;
-(NSString *)path_with_cache;
-(BOOL)isSticker;
-(TLDocumentAttribute *)attributeWithClass:(Class)className;
-(NSSize)imageSize;
-(BOOL)isExist;

@end
