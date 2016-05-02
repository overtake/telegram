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
    
    __block NSString *fileName = @"Unnamed.file";
    
    [self.attributes enumerateObjectsUsingBlock:^(TLDocumentAttribute *obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[TL_documentAttributeFilename class]]) {
            fileName = [obj.file_name stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
            *stop = YES;
        }
        
    }];
    
    return fileName;
}

-(int)duration  {
    
    TL_documentAttributeAudio *attr = (TL_documentAttributeAudio *) [self attributeWithClass:[TL_documentAttributeAudio class]];
    
    if(attr) {
        return attr.duration;
    }
    
    
    return 0;
}

-(NSString *)path_with_cache {
    TL_localMessage *fake = [[TL_localMessage alloc] init];
    fake.media = [TL_messageMediaDocument createWithDocument:self caption:@""];
    return mediaFilePath(fake);
}

- (BOOL)isset {
    return isPathExists(self.path_with_cache) && [FileUtils checkNormalizedSize:self.path_with_cache checksize:[self size]];
}

-(TLDocumentAttribute *)attributeWithClass:(Class)className {
    
    __block TLDocumentAttribute *attribute;
    
    [self.attributes enumerateObjectsUsingBlock:^(TLDocumentAttribute *obj, NSUInteger idx, BOOL *stop) {
        
        if(obj.class == className) {
            attribute = obj;
            *stop = YES;
        }
        
    }];
    
    return attribute;
    
}

-(NSArray *)serverAttributes {
    
    static NSArray *localAttributes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localAttributes = @[NSStringFromClass([TL_documentAttributeLocalFile class])];
    });
    
    return [self.attributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        
        return [localAttributes indexOfObject:NSStringFromClass([evaluatedObject class])] == NSNotFound;
        
    }]];
}

-(BOOL)isSticker {
    return [self attributeWithClass:[TL_documentAttributeSticker class]] != nil;
}

-(BOOL)isVideo {
    return [self.mime_type hasPrefix:@"video"] && [self attributeWithClass:[TL_documentAttributeVideo class]] != nil && [self attributeWithClass:[TL_documentAttributeAnimated class]] == nil;
}

-(BOOL)isGif {
    return [self.mime_type hasPrefix:@"video/mp4"] && [self attributeWithClass:[TL_documentAttributeVideo class]] != nil && [self attributeWithClass:[TL_documentAttributeAnimated class]] != nil;
}
-(BOOL)isAudio {
    return ([self.mime_type isEqualToString:@"audio/mpeg"] && [self attributeWithClass:[TL_documentAttributeAudio class]] == nil) || ([self attributeWithClass:[TL_documentAttributeAudio class]] != nil && ![self attributeWithClass:[TL_documentAttributeAudio class]].isVoice);
}

-(BOOL)isVoice {
    return ([self.mime_type isEqualToString:@"audio/ogg"] && [self attributeWithClass:[TL_documentAttributeAudio class]] == nil) || ([self attributeWithClass:[TL_documentAttributeAudio class]] != nil && [self attributeWithClass:[TL_documentAttributeAudio class]].isVoice);
}

-(TL_documentAttributeAudio *)audioAttr {
    return (TL_documentAttributeAudio *) [self attributeWithClass:[TL_documentAttributeAudio class]];
}

-(NSSize)imageSize {
    __block NSSize size = NSZeroSize;
    
    [self.attributes enumerateObjectsUsingBlock:^(TLDocumentAttribute *obj, NSUInteger idx, BOOL *stop) {
        
        if([obj isKindOfClass:[TL_documentAttributeImageSize class]]) {
            size = NSMakeSize(obj.w,obj.h);
            *stop = YES;
        }
        
    }];
    
    return size;
}

-(BOOL)isExist {
    return self.n_id != 0 && self.access_hash != 0;
}

@end
