//
//  NSString+Extended.h
//  Telegram
//
//  Created by Dmitry Kondratyev on 11/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extended)
- (NSString *)htmlentities;
- (NSString *)trim;
- (NSString *)singleLine;
- (NSString *)URLDecode;
- (NSSize)sizeForTextFieldForWidth:(int)width;
- (NSArray *)getEmojiFromString:(BOOL)checkColor;
-(NSString *)emojiString;
- (NSString *)replaceSmilesToEmoji;

-(NSString *)fixEmoji;
-(NSString *)realEmoji:(NSString *)raceEmoji;
-(NSString *)emojiModifier:(NSString *)emoji;
-(NSString *)emojiWithModifier:(NSString *)modifier emoji:(NSString *)emoji;


-(BOOL)searchInStringByWordsSeparated:(NSString *)search;
-(NSArray *)partsOfSearchString;

@end
