//
//  TMCheckBox.h
//  Telegram P-Edition
//
//  Created by keepcoder on 20.02.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TMCheckBox : TMView
-(void)setChecked:(BOOL)checked;
-(BOOL)isChecked;


-(void)setSelected:(BOOL)selected;
-(BOOL)isSelected;
@end
