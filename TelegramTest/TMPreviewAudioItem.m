//
//  TMPreviewDocumentItem.m
//  Messenger for Telegram
//
//  Created by keepcoder on 12.03.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMPreviewAudioItem.h"
#import "FileUtils.h"
@implementation TMPreviewAudioItem

@synthesize url = _url;
@synthesize previewObject = _previewObject;

-(id)initWithItem:(PreviewObject *)previewObject {
    if(self = [super init]) {
        _previewObject = previewObject;
        
        _url = [NSURL fileURLWithPath:mediaFilePath(_previewObject.media)];
        
        
        
    }
    return self;
}

-(NSString *)previewItemTitle {
    return @"Voice message";
}


-(BOOL)isEqualToItem:(id<TMPreviewItem>)item {
    return _previewObject.msg_id == item.previewObject.msg_id;
}

-(NSURL *)previewItemURL {
    return _url;
}

- (NSString *)fileName {
    NSString *filename = [self.url lastPathComponent];
    
    if(!filename)
        filename = @"file";
    return filename;
}

@end
