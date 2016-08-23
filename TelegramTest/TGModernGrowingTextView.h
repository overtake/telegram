//
//  TGModernGrowingTextView.h
//  Telegram
//
//  Created by keepcoder on 12/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TGInputTextTag.h"
#import "SpacemanBlocks.h"


@protocol TGModernGrowingDelegate <NSObject>

-(void) textViewHeightChanged:(id)textView height:(int)height animated:(BOOL)animated;
-(BOOL) textViewEnterPressed:(id)textView;
-(void) textViewTextDidChange:(id)textView;
-(MessagesViewController *)messagesController;
-(NSSize)textViewSize;
-(BOOL)textViewIsTypingEnabled;

@optional
- (void) textViewNeedClose:(id)textView;

@end


@interface TGGrowingTextView : NSTextView {
    SMDelayedBlockHandle _handle;
}
@property (nonatomic,weak) id <TGModernGrowingDelegate> weakd;
@end

@interface TGModernGrowingTextView : TMView

@property (nonatomic,assign) BOOL animates;

@property (nonatomic,assign) int min_height;
@property (nonatomic,assign) int max_height;



@property (nonatomic,strong) NSAttributedString *placeholderAttributedString;

-(void)setPlaceholderAttributedString:(NSAttributedString *)placeholderAttributedString update:(BOOL)update;

@property (nonatomic,weak) id <TGModernGrowingDelegate> delegate;

-(int)height;


-(void)update:(BOOL)notify;

-(NSAttributedString *)attributedString;
-(void)setAttributedString:(NSAttributedString *)attributedString;
-(NSString *)string;
-(void)setString:(NSString *)string;
-(NSRange)selectedRange;
-(void)insertText:(id)aString replacementRange:(NSRange)replacementRange;
-(void)addInputTextTag:(TGInputTextTag *)tag range:(NSRange)range;

-(void)replaceMention:(NSString *)mention username:(bool)username userId:(int32_t)userId;

-(void)paste:(id)sender;

-(void)setSelectedRange:(NSRange)range;

-(NSFont *)font;

-(Class)_textViewClass;
-(int)_startXPlaceholder;
-(BOOL)_needShowPlaceholder;

@end
