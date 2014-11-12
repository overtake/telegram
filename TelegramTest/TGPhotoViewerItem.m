//
//  TGPhotoViewerItem.m
//  Telegram
//
//  Created by keepcoder on 10.11.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGPhotoViewerItem.h"
#import "TGDateUtils.h"
@implementation TGPhotoViewerItem

-(id)initWithImageObject:(TGImageObject *)imageObject previewObject:(PreviewObject *)previewObject {
    if(self = [super init]) {
        _imageObject = imageObject;
        _previewObject = previewObject;
        _user = [[UsersManager sharedManager] find:[_previewObject.media from_id]];
        
        [self rebuildDate:[(TL_localMessage *)previewObject.media date]];
    }
    
    return self;
}


-(void)dealloc {
    
}



-(void)rebuildDate:(int)date {
    _date = [NSDate dateWithTimeIntervalSince1970:date];
    
    int time = date;
    time -= [[MTNetwork instance] getTime] - [[NSDate date] timeIntervalSince1970];
    
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    

    _stringDate = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

@end
