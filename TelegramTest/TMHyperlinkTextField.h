//
//  TMHyperlinkTextField.h
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/28/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMTextField.h"

@protocol TMHyperlinkTextFieldDelegate <NSObject>

- (void) textField:(id)textField handleURLClick:(NSString *)url;

@end


@interface TMHyperlinkTextField : TMTextField

@property (nonatomic,assign) float hardYOffset; // this is hard fix :D
@property (nonatomic,assign) float hardXOffset; // this is hard fix :D

@property (nonatomic, strong) id<TMHyperlinkTextFieldDelegate> url_delegate;

@end
