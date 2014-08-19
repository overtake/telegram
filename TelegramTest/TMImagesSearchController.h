//
//  TMImagesSearchController.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/18/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CNGridView.h"

@interface TMImagesSearchController : TMViewController<NSTextFieldDelegate, CNGridViewDelegate, CNGridViewDataSource>

+ (TMImagesSearchController *)sharedInstance;
- (void)loadImagesByQuery:(NSString *)query completeHandler:(void (^)(BOOL result, NSArray *results))completeHandler;

@end
