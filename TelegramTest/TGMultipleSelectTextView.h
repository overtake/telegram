//
//  TGMultipleSelectTextView.h
//  Telegram
//
//  Created by keepcoder on 03.10.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TGCTextView.h"

@interface TGMultipleSelectTextView : TGCTextView


-(void)_parentMouseDragged:(NSEvent *)theEvent;
-(void)_parentMouseDown:(NSEvent *)theEvent;

@end
