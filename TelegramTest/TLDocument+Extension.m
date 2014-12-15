//
//  TLDocument+Extension.m
//  Telegram
//
//  Created by keepcoder on 15.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TLDocument+Extension.h"

@implementation TLDocument (Extensions)

-(NSString *)file_name {
    
    __block NSString *fileName;
    
    [self.attributes enumerateObjectsUsingBlock:^(TLDocumentAttribute *obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[TL_documentAttributeFilename class]]) {
            fileName = obj.file_name;
            *stop = YES;
        }
        
    }];
    
    return fileName;
}

@end
