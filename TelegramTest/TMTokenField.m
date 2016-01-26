//
//  TMTextField.m
//  Telegram
//
//  Created by keepcoder on 8/29/24.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "TMTokenField.h"
#import "TMTokenCell.h"
#import "NS(Attributed)String+Geometrics.h"
#import "AppDelegate.h"

@interface TMTokenField()
@property (weak) NSScrollView *scrollView;
@property (weak) NSClipView *contentView;

@end

@implementation TMTokenField

- (id)initWithFrame:(NSRect)frameRect {
   
    if(self = [super initWithFrame:frameRect]) {
        self.elements = [[NSMutableArray alloc] init];
        self.delegate = self;
        
        self.scrollView = (NSScrollView*)self.superview.superview;
        self.contentView = self.scrollView.contentView;
    }
    
    return self;
    
}

- (NSPoint) getContentOffset {
    return NSMakePoint(0, self.contentView.bounds.origin.y);
}

- (NSSize) getContentSize {
    return self.contentView.documentRect.size;
}

- (void)scrollToEndOfDocument:(id)sender {
    //СУКАПЗДЦ))0
    [self scrollPoint:NSMakePoint(0, [self getContentSize].height)];
}

- (void)removeToken:(TokenItem *)token {
    NSUInteger pos = [self.elements indexOfObject:token];
    if(pos != NSNotFound) {
        [self removeObject:pos];
    }
}

- (void)removeAllTokens {
    [self setString:@""];
    
    [self.elements removeAllObjects];
}

- (void)addToken:(TokenItem *)token {
    
     if([self.elements indexOfObject:token] != NSNotFound)
         return;
    
    NSString *name = token.title;
    
    TMTokenCell *tokenCell = [[TMTokenCell alloc] initTextCell:name];
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setAttachmentCell:tokenCell];
    
    
    if(self.textStorage.length > self.elements.count) {
        [self.textStorage replaceCharactersInRange:NSMakeRange(self.elements.count, self.textStorage.length-self.elements.count) withString:@""];
    }

    [self.textStorage appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];

    [self _add:token];
    
    [self textDidChange:nil];
    
    AppDelegate *delegate = (AppDelegate*)[NSApplication sharedApplication].delegate;
    [delegate.window makeFirstResponder:self];
    [self setSelectedRange:NSMakeRange(self.textStorage.length, 0)];
}

- (void)_add:(TokenItem*)token {
    if([self.elements indexOfObject:token] == NSNotFound) {
        [self.elements addObject:token];
        [self.tokenDelegate textView:self changeElementCount:(int)[self.elements count]];
    }
}


- (void)textDidChange:(NSNotification *)notification {
//    NSMutableAttributedString *attributesString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedString];
    
    [[self textStorage] addAttribute:NSFontAttributeName value:TGSystemLightFont(13) range:NSMakeRange(0, self.attributedString.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:4];
    [[self textStorage] addAttribute:NSParagraphStyleAttributeName
                      value:style
                      range:NSMakeRange(0, self.attributedString.length)];
    
    [self scrollToEndOfDocument:nil];
    
    NSString *str = [self string];
    if(self.elements.count) {
        if(str.length >= self.elements.count)
            str = [str substringFromIndex:self.elements.count];
        else
            str = @"";
    }
    
    [self.tokenDelegate textStringDidChange:str];
}

- (void)removeObject:(NSUInteger)pos {
    [self.textStorage replaceCharactersInRange:NSMakeRange(pos, 1) withString:@""];
    
    TokenItem *token = self.elements[pos];
    
    [self.elements removeObjectAtIndex:pos];
    [self.tokenDelegate textView:self removeElements:@[token]];
    [self.tokenDelegate textView:self changeElementCount:(int)[self.elements count]];
}

-(BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    
    if(affectedCharRange.location < [self.elements count] && affectedCharRange.length) {
        if(replacementString.length == 0) {
            NSRange range = NSMakeRange(affectedCharRange.location, MIN(affectedCharRange.length, [self.elements count]-affectedCharRange.location));
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
            
            NSArray *tokens = [self.elements objectsAtIndexes:set];
            
            [self.elements removeObjectsInArray:tokens];
            [self.tokenDelegate textView:self removeElements:tokens];
            [self.tokenDelegate textView:self changeElementCount:(int)[self.elements count]];
            return YES;
        } else
            return NO;
    } else {
        if(affectedCharRange.location >= [self.elements count]) {
            return YES;
        }
    }
    return NO;
}


- (TokenItem *)token:(NSUInteger)identifier object:(id)object title:(NSString *)title {
    __block TokenItem *item;
    
    [self.elements enumerateObjectsUsingBlock:^(TokenItem  *obj, NSUInteger idx, BOOL *stop) {
        if(obj.identifier == identifier) {
            item = obj;
            
            *stop = YES;
        }
    }];
    
    if(!item) {
        item = [[TokenItem alloc] initWithIdentified:identifier object:object title:title];
    }
    
    return item;
}

@end
