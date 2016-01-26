//
//  TMAttributedString.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/2/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMAttributedString.h"
#import <objc/runtime.h>

static void *normalColorsKey;
static void *selectedColorsKey;
static void *isSelectedKey;

@implementation NSMutableAttributedString (TM)

- (BOOL)isSelected {
    NSNumber *isSelectedNumber = objc_getAssociatedObject(self, &isSelectedKey);
    BOOL result = NO;
    if(isSelectedNumber)
        result = [isSelectedNumber boolValue];
    return result;
}

- (void)setSelectionColor:(NSColor *)selectionColor forColor:(NSColor *)color {
    [[self normalColors] setObject:selectionColor forKey:@(color.hash)];
    [[self selectedColors] setObject:color forKey:@(selectionColor.hash)];
}

DYNAMIC_PROPERTY(AttachmentsNormal);
DYNAMIC_PROPERTY(AttachmentsSelected);

- (void)setSelectionAttachment:(NSTextAttachment *)selectionAttachment forAttachment:(NSTextAttachment *)attachment {
    if([self getAttachmentsNormal] == nil)
        [self setAttachmentsNormal:[NSMutableDictionary dictionary]];
    
    if([self getAttachmentsSelected] == nil)
        [self setAttachmentsSelected:[NSMutableDictionary dictionary]];
    
    NSMutableDictionary *normal = [self getAttachmentsNormal];
    [normal setObject:selectionAttachment forKey:@(attachment.hash)];
    
    NSMutableDictionary *selected = [self getAttachmentsSelected];
    [selected setObject:attachment forKey:@(selectionAttachment.hash)];
}

- (NSMutableDictionary *)normalColors {
    NSMutableDictionary *result = objc_getAssociatedObject(self, &normalColorsKey);
    if (result == nil) {
        result = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &normalColorsKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (NSMutableDictionary *)selectedColors {
    NSMutableDictionary *result = objc_getAssociatedObject(self, &selectedColorsKey);
    if (result == nil) {
        result = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, &selectedColorsKey, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (void)setSelected:(BOOL)isSelected {
    if(self.isSelected == isSelected)
        return;
    
    objc_setAssociatedObject(self, &isSelectedKey, [NSNumber numberWithBool:isSelected], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSDictionary *colorSearchDictionary = isSelected ? [self normalColors] : [self selectedColors];
    
    [self beginEditing];
    [self enumerateAttributesInRange:NSMakeRange(0, self.length) options:NSAttributedStringEnumerationReverse usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) {
         
         NSColor *colorNow = [attributes objectForKey:NSForegroundColorAttributeName];
         if(colorNow) {
             
             NSColor *colorNeed = [colorSearchDictionary objectForKey:@(colorNow.hash)];
             if(colorNeed)
                 [self addAttribute:NSForegroundColorAttributeName value:colorNeed range:range];
         }
     }];
    
    
    if([self getAttachmentsNormal]) {
        NSUInteger length = [self length];
        NSRange effectiveRange = NSMakeRange(0, 0);
        NSObject *attachment;
        
        while (NSMaxRange(effectiveRange) < length) {
            attachment = [self attribute:NSAttachmentAttributeName atIndex:NSMaxRange(effectiveRange) effectiveRange:&effectiveRange];
            if (attachment) {
                NSTextAttachment *newAttachment = [(isSelected ? [self getAttachmentsNormal] : [self getAttachmentsSelected]) objectForKey:@(attachment.hash)];
                
                if(newAttachment) {
                    [self removeAttribute:NSAttachmentAttributeName range:effectiveRange];
                    [self addAttribute:NSAttachmentAttributeName value:newAttachment range:effectiveRange];
                }
            }
        }
    }
    
    
    [self endEditing];
}

- (NSRange)appendString:(NSString *)string {
    return [self appendString:string withColor:nil];
}

- (void)clear {
    [[self mutableString] setString:@""];
    [self setSelected:NO];
}

- (NSRange)appendString:(NSString *)string withColor:(NSColor*)color {
    if(string == nil) {
        MTLog(@"string is nil");
        return NSMakeRange(0, 0);
    }
    
    if(color == nil) {
        [self appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
        return NSMakeRange(self.length - string.length, string.length);
    }
    
    [self appendAttributedString:[[NSAttributedString alloc] initWithString:string ? string : @"" attributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName]]];
    return NSMakeRange(self.length - string.length, string.length);
}

- (void)setFont:(NSFont *)font forRange:(NSRange)range {
    [self addAttribute:NSFontAttributeName value:font range:range];
}

- (void)setCTFont:(NSFont *)font forRange:(NSRange)range {
    [self addAttribute:(NSString *)kCTFontAttributeName value:CFBridgingRelease(CTFontCreateWithFontDescriptor((__bridge CTFontDescriptorRef)[font fontDescriptor], 0.0f, NULL)) range:range];
}

- (void)setLink:(NSString *)link forRange:(NSRange)range {
    [self setLink:link withColor:nil forRange:range];
}

+ (NSAttributedString *)attributedStringByImage:(NSImage *)image {
    return [NSAttributedString attributedStringWithAttachment: [self textAttachmentByImage:image]];
}

+ (NSTextAttachment *)textAttachmentByImage:(NSImage *)image {
    NSFileWrapper *fwrap = [[NSFileWrapper alloc] initRegularFileWithContents: [image TIFFRepresentation]];
    NSString *imgName = [image name];
    if(!imgName)
        imgName = @"image";
    imgName = [imgName stringByAppendingPathExtension: @".jpg"];
    [fwrap setFilename:imgName];
    [fwrap setPreferredFilename:imgName];
    
    NSTextAttachmentCell *attachmentCell =[[NSTextAttachmentCell alloc] initImageCell:image];
    NSTextAttachment *attachment =[[NSTextAttachment alloc] init];
    [attachment setAttachmentCell: attachmentCell ];
    return attachment;
    
    return [[NSTextAttachment alloc] initWithFileWrapper: fwrap];
}


+ (NSRange)selectText:(NSString *)text fromAttributedString:(NSMutableAttributedString*)attributed selectionColor:(NSColor *)color {

    
    NSString *stringText = [[attributed string] lowercaseString];
    if(!stringText || !text)
        return NSMakeRange(NSNotFound, 0);
    
    NSRange range = [stringText rangeOfString:[text lowercaseString]];
    if(range.location == NSNotFound) {
        NSMutableString *buffer = [text mutableCopy];
        CFMutableStringRef bufferRef = (__bridge CFMutableStringRef)buffer;
        CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, false);
        
        range = [stringText rangeOfString:[buffer lowercaseString]];
        
        if(range.location == NSNotFound) {
            
            NSMutableString *transformReverse = [text mutableCopy];
            bufferRef = (__bridge CFMutableStringRef)transformReverse;
            CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, true);
            
            range = [stringText rangeOfString:[transformReverse lowercaseString]];
            
            if(range.location == NSNotFound)
                return range;
        }
    }
    
  
    if([attributed isSelected]) {
        NSColor *newColor = [[attributed normalColors] objectForKey:@(color.hash)];
        if(newColor) {
            color = newColor;
        }
    }
    
    [attributed beginEditing];
    [attributed addAttribute:NSForegroundColorAttributeName value:color range:range];
    [attributed endEditing];
    
     return range;
}

- (void)setLink:(NSString *)link withColor:(NSColor *)color forRange:(NSRange)range {
    [self addAttribute:NSLinkAttributeName value:link range:range];
    if(color)
        [self addAttribute:NSForegroundColorAttributeName value:color range:range];
    [self addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:range];
}

@end
