//
//  TGModernGrowingTextView.h
//  Telegram
//
//  Created by keepcoder on 12/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TGInputTextTag.h"
@protocol TGModernGrowingDelegate <NSObject>

-(void) textViewHeightChanged:(id)textView height:(int)height animated:(BOOL)animated;
-(BOOL) textViewEnterPressed:(id)textView;
-(void) textViewTextDidChange:(id)textView;
-(NSSize)textViewSize;

@optional
- (void) textViewNeedClose:(id)textView;

@end

@interface TGModernGrowingTextView : TMView

@property (nonatomic,assign) BOOL animates;

@property (nonatomic,assign) int min_height;
@property (nonatomic,assign) int max_height;

@property (nonatomic,strong) NSAttributedString *placeholderAttributedString;

@property (nonatomic,weak) id <TGModernGrowingDelegate> delegate;

-(int)height;


-(void)update;

-(NSString *)string;
-(void)setString:(NSString *)string;
-(NSRange)selectedRange;
-(void)insertText:(id)aString replacementRange:(NSRange)replacementRange;
-(void)addInputTextTag:(TGInputTextTag *)tag range:(NSRange)range;

-(void)replaceMention:(NSString *)mention username:(bool)username userId:(int32_t)userId;


@end
