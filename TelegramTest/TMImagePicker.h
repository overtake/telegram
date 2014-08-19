//
//  TMWebImagesSearchPicker.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/16/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

typedef enum {
    TMImagePickerNoneDefaultSelection, 
    TMImagePickerWebSearchDefaultSelection
} TMImagePickerDefaultSelection;

@interface TMImagePicker : IKPictureTaker<NSTableViewDelegate, NSTextFieldDelegate>

+ (TMImagePicker *)sharedInstance;
@property (nonatomic) TMImagePickerDefaultSelection type;

@end
