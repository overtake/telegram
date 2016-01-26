//
//  LoginCountrySelectorView.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LoginCountrySelectorView.h"
#import "СountriesManager.h"
#import "NS(Attributed)String+Geometrics.h"
#import "RMPhoneFormat.h"
#import "NSString+Extended.h"
#import "NewLoginViewController.h"

@interface LoginCountrySelectorView()

@property (nonatomic, strong) TMTextField *countryCodeTextField;
@property (nonatomic, strong) TMTextField *numberTextField;
@property (nonatomic, strong) TMTextField *countryNameTextField;
@property (nonatomic, strong) TMTextButton *editTextButton;
@property (nonatomic, strong) NSPopUpButton *popupButton;
@property (nonatomic, strong) CountryItem *selectedCountry;

@end

@implementation LoginCountrySelectorView

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [_ountriesManager sharedManager];
        
        self.countryCodeTextField = [[TMTextField alloc] initWithFrame:NSMakeRect(100, 14, self.bounds.size.width, 20)];
        self.countryCodeTextField.drawsBackground = NO;
        self.countryCodeTextField.delegate = self;
        
        NSAttributedString *placeHolder = [[NSAttributedString alloc] initWithString:@"+" attributes:@{NSFontAttributeName: TGSystemLightFont(15), NSForegroundColorAttributeName: NSColorFromRGB(0xaeaeae)}];
        [self.countryCodeTextField.cell setPlaceholderAttributedString:placeHolder];
      //  [self.countryCodeTextField setPlaceholderAttributedString:placeHolder];
        [self.countryCodeTextField setPlaceholderPoint:NSMakePoint(2, 0)];
        
        self.countryCodeTextField.font = TGSystemLightFont(15);
        self.countryCodeTextField.focusRingType = NSFocusRingTypeNone;
        [self.countryCodeTextField setBordered:NO];
        
       // [self.countryCodeTextField setDrawsBackground:YES];
       // [self.countryCodeTextField setBackgroundColor:[NSColor redColor]];
        
        [self addSubview:self.countryCodeTextField];
        
        self.numberTextField = [[TMTextField alloc] init];
        self.numberTextField.drawsBackground = NO;
        self.numberTextField.delegate = self;
        
        placeHolder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login.phoneNumber", nil) attributes:@{NSFontAttributeName: TGSystemLightFont(15), NSForegroundColorAttributeName: NSColorFromRGB(0xaeaeae)}];
        [self.numberTextField.cell setPlaceholderAttributedString:placeHolder];
        //        [self.numberTextField setPlaceholderAttributedString:placeHolder];
        [self.numberTextField.cell setUsesSingleLineMode:YES];
        //        [self.numberTextField setPlaceholderPoint:NSMakePoint(2, 1)];
        
        [self.numberTextField setFont:TGSystemLightFont(15)];
        self.numberTextField.focusRingType = NSFocusRingTypeNone;
        [self.numberTextField setBordered:NO];
        [self.numberTextField setTarget:self];
        [self.numberTextField setAction:@selector(numberTextFieldAction)];
        
        [self addSubview:self.numberTextField];
        
        
        [self controlTextDidChange:[NSNotification notificationWithName:@"no" object:self.countryCodeTextField]];
        self.countryCodeTextField.nextKeyView = self.numberTextField;
        self.numberTextField.nextKeyView = self.countryCodeTextField;
        
        
        
        weakify();
        self.editTextButton = [[TMTextButton alloc] init];
        //        [self.editTextButton setDisable:YES];
        self.editTextButton.stringValue = NSLocalizedString(@"Profile.edit", nil);
        [self.editTextButton setFont:TGSystemFont(14)];
        [self.editTextButton setWantsLayer:IS_RETINA];
        [self.editTextButton setTextColor:BLUE_UI_COLOR];
        [self.editTextButton sizeToFit];
        [self.editTextButton setFrameOrigin:NSMakePoint(self.bounds.size.width - self.editTextButton.bounds.size.width - 10, 16)];
        [self.editTextButton setHidden:YES];
        [self.editTextButton setTapBlock:^{
            if(strongSelf.backCallback) strongSelf.backCallback();
           // [strongSelf.loginController performBackEditAnimation:0.08];
        }];
        [self addSubview:self.editTextButton];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.countryCodeTextField.textView.insertionPointColor = self.numberTextField.textView.insertionPointColor =  NSColorFromRGB(0x60b8ea);
        });
        
        
        self.popupButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(110, 60, 320, 26)];
        [self.popupButton setBordered:NO];
        [self.popupButton setAlphaValue:0];
        [self.popupButton setAction:@selector(changeCountry:)];
        
        for(CountryItem *item in [[_ountriesManager sharedManager] countries]) {
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:item.fullCountryName action:NULL keyEquivalent:@""];
            menuItem.tag = [item.fullCountryName hash];
            [[self.popupButton menu] addItem:menuItem];
        }
        [self addSubview:self.popupButton];
        
        //        self.countryNameTextField = [CountrySelectTextField defaultTextField];
        //        [self.countryCodeTextField setEditable:NO];
        //        self.countryCodeTextField.frame = NSMakeRect(110, 60, 360, 16);
        //        self.countryCodeTextField.font = TGSystemLightFont(15);
        //        self.countryCodeTextField.stringValue = NSLocalizedString(@"Choose coutry", nil);
        //        [self addSubview:self.countryCodeTextField];
        
        
        NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
        if(countryCode) {
            CountryItem *item = [[_ountriesManager sharedManager] itemBySmallCountryName:countryCode];
            if(item) {
                [self changeCountry:[[NSMenuItem alloc] initWithTitle:item.fullCountryName action:NULL keyEquivalent:@""]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.numberTextField.window makeFirstResponder:self.numberTextField];
            // [self.numberTextField setCursorToEnd];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.numberTextField.window makeFirstResponder:self.numberTextField];
                [self controlTextDidChange:[NSNotification notificationWithName:@"change" object:self.numberTextField]];
                // [self.numberTextField setCursorToEnd];
            });
        });
    }
    return self;
}

- (void)changeCountry:(NSMenuItem *)item {
    CountryItem *countryItem = [[_ountriesManager sharedManager] itemByFullCountryName:item.title];
    
    self.selectedCountry = countryItem;
    if(countryItem) {
        [self.countryCodeTextField setStringValue:[NSString stringWithFormat:@"+%d", countryItem.countryCode]];
        [self controlTextDidChange:[NSNotification notificationWithName:@"didChangeCountryCode" object:self.countryCodeTextField]];
        [self.numberTextField.window makeFirstResponder:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.numberTextField.window makeFirstResponder:self.numberTextField];
            [self.numberTextField setCursorToEnd];
        });
    }
    
    [self setNeedsDisplay:YES];
}

- (BOOL)becomeFirstResponder {
    [self.numberTextField.window makeFirstResponder:self.numberTextField];
    return YES;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    if(control == self.numberTextField) {
        if(commandSelector == @selector(insertNewline:)) {
            if(_nextCallback)_nextCallback();
            return YES;
        }
        
        if(commandSelector == @selector(moveLeft:)) {
            if(textView.selectedRange.location == 0 && textView.selectedRange.length == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.countryCodeTextField.window makeFirstResponder:self.countryCodeTextField];
                    [self.countryCodeTextField setCursorToEnd];
                });
            }
        }
        
        if(commandSelector == @selector(deleteBackward:)) {
            if(textView.selectedRange.location == 0 && textView.selectedRange.length == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.countryCodeTextField.window makeFirstResponder:self.countryCodeTextField];
                    [self.countryCodeTextField setCursorToEnd];
                });
            }
        }
    }
    
    if(control == self.countryCodeTextField) {
        if(commandSelector == @selector(moveRight:)) {
            if(textView.selectedRange.location == textView.string.length && textView.selectedRange.length == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.numberTextField.window makeFirstResponder:self.numberTextField];
                    [self.numberTextField setCursorToStart];
                });
            }
        }
        
        if(commandSelector == @selector(insertNewline:)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.numberTextField.window makeFirstResponder:self.numberTextField];
                [self.numberTextField setCursorToEnd];
            });
            return YES;
        }
    }
    
    return NO;
}

- (void)controlTextDidChange:(NSNotification *)notification {
    id object = notification.object;
    
    if(object == self.countryCodeTextField) {
        NSString *str = [[self.countryCodeTextField.stringValue componentsSeparatedByCharactersInSet:
                          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                         componentsJoinedByString:@""];
        
        str = [NSString stringWithFormat:@"+%@", str];
        
        CountryItem *item = nil;
        
        if(str.length > 1) {
            if(str.length > 5) {
                
                int i = 0;
                for(i = 0; i < 4; i++) {
                    NSString *testNumber = [str substringToIndex:i + 1];
                    item = [[_ountriesManager sharedManager] itemByCodeNumber:[testNumber intValue]];
                    if(item)
                        break;
                }
                i++;
                
                if(item) {
                    
                   [self.numberTextField setStringValue:[str substringFromIndex:i]];
                    
                    str = [str substringToIndex:i];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.numberTextField.window makeFirstResponder:self.numberTextField];
                        [self controlTextDidChange:[NSNotification notificationWithName:@"change" object:self.numberTextField]];
                        
                    });
                    
                } else {
                    str = [str substringToIndex:5];
                }
                
            } else {
                item = [[_ountriesManager sharedManager] itemByCodeNumber:[[str substringFromIndex:1] intValue]];
            }
        }
        
        if(self.selectedCountry.countryCode == item.countryCode) {
            item = self.selectedCountry;
        } else {
            self.selectedCountry = item;
        }
        
        if(item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.numberTextField.window makeFirstResponder:self.numberTextField];
                [self controlTextDidChange:[NSNotification notificationWithName:@"change" object:self.numberTextField]];
                
                //[self.numberTextField setCursorToEnd];
            });
        }
        
        
        
        if(item) {
            NSUInteger pos = [[self.popupButton menu] indexOfItemWithTag:[item.fullCountryName hash]];
            [self.popupButton selectItemAtIndex:pos];
        }
        
        
        if(str.length == 1) {
            [self.countryCodeTextField setStringValue:@"+"];
            [self.countryCodeTextField sizeToFit];
            [self.countryCodeTextField setStringValue:@""];
        } else {
            [self.countryCodeTextField setStringValue:str];
            [self.countryCodeTextField sizeToFit];
        }
        
        
        [self.countryCodeTextField setFrameOrigin:NSMakePoint(114, 16)];
        
        
        [self.countryCodeTextField setCursorToEnd];
        
        [self.numberTextField setFrameSize:NSMakeSize(200, self.countryCodeTextField.bounds.size.height)];
        [self.numberTextField setFrameOrigin:NSMakePoint(114 + self.countryCodeTextField.bounds.size.width + 16, 15)];
        
        
        
        
        [self setNeedsDisplay:YES];
        
        
        
        
        return;
    }
    
    if(object == self.numberTextField) {
        
        if([self.numberTextField.stringValue hasPrefix:@"+"] && [[RMPhoneFormat instance] isPhoneNumberValid:self.numberTextField.stringValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.countryCodeTextField.stringValue = self.numberTextField.stringValue;
                [self controlTextDidChange:[NSNotification notificationWithName:@"change" object:self.countryCodeTextField]];
            });
            return;
        }
        
        NSString *inputed = self.numberTextField.stringValue;
        
        if([inputed rangeOfString:@"("].location != NSNotFound && [inputed rangeOfString:@")"].location == NSNotFound) {
            
            
            int i = 1;
            while([inputed characterAtIndex:inputed.length-i] == ' ')
                i++;
            inputed = [inputed substringToIndex:inputed.length-i];
            
            
            
        }
        
        NSString *str = [[inputed componentsSeparatedByCharactersInSet:
                          [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                         componentsJoinedByString:@""];
        
        
        
        
        if(str.length > 15)
            str = [str substringToIndex:15];
        
        
        PhoneFormatXItem *formatItem = [[_ountriesManager sharedManager] formatByCodeNumber:self.selectedCountry.countryCode];
        
        
        formatItem = nil; // off new formatter
        
        NSString *xFormat = formatItem != nil ? formatItem.format : @"";
        
        
        NSString *country = self.countryCodeTextField.stringValue;
        
        if([country isEqualToString:@"+1876"]) {
            country = @"";
        }
        
        
        NSString *format = [RMPhoneFormat formatPhoneNumber:[NSString stringWithFormat:@"%@%@", country, str]];
        
        
        
        format = [[[format stringByReplacingOccurrencesOfString:self.countryCodeTextField.stringValue withString:@""] stringByReplacingOccurrencesOfString:@"+" withString:@""] trim];
        
        
        
        
        NSString *f = @"";
        int xpos = -1;
        
        if(formatItem) {
            
            xFormat = [xFormat uppercaseString];
            
            NSString *fc  = @"";
            for (int i = 0; i < format.length; i++) {
                unichar c = [format characterAtIndex:i];
                
                if(c != '-' && c != '(' && c != ')' && c != ' ') {
                    fc = [fc stringByAppendingString:[NSString stringWithFormat:@"%C",c]];
                }
            }
            
            
            
            NSString *fcopy = fc;
            
            MTLog(@"format: %@, f:%@",xFormat,fcopy);
            
            for (int i = 0; i < xFormat.length; i++) {
                unichar xc = [xFormat characterAtIndex:i];
                if(fcopy.length > 0) {
                    if(xc == 'X') {
                        f = [f stringByAppendingFormat:@"%C",[fcopy characterAtIndex:0]];
                        fcopy = [fcopy substringFromIndex:1];
                    } else if(xc == ' ') {
                        f = [f stringByAppendingString:@" "];
                    }
                } else {
                    f = [f stringByAppendingFormat:@"%C",xc];
                    
                    if(xpos == -1) {
                        xpos = i;
                        if(i < xFormat.length) {
                            //  if([xFormat characterAtIndex:i] == ' ')
                            //      ++xpos;
                        }
                    }
                    
                }
                
            }
            
            if(fc.length == 0) {
                f = @"";
            }
            
            
        } else {
            xpos = 0;
            f = format;
        }
        
        if(xpos == -1)
            xpos = (int) f.length;
        
        
        format = f;
        
        
        
        
        
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        
        [attr appendString:format withColor:NSColorFromRGB(0x000000)];
        [attr setFont:TGSystemLightFont(15) forRange:NSMakeRange(0, format.length)];
        
        [attr addAttribute:NSForegroundColorAttributeName value:NSColorFromRGB(0xaeaeae) range:NSMakeRange(xpos, format.length-xpos)];
        
        // [attr addAttribute:NSParagraphStyleAttributeName value:p range:NSMakeRange(0, format.length)];
        
        
        
        
        
        if(formatItem) {
            NSMutableAttributedString *xCheck = [[NSMutableAttributedString alloc] init];
            
            [xCheck appendString:xFormat];
            [xCheck setFont:TGSystemLightFont(15) forRange:NSMakeRange(0, format.length)];
            [xCheck addAttribute:(NSString *) kCTKernAttributeName value:@(0) range:NSMakeRange(0, xFormat.length)];
            
            
            NSSize xsize = [xCheck sizeForWidth:self.numberTextField.frame.size.width height:FLT_MAX];
            
            NSSize fsize = [attr sizeForWidth:self.numberTextField.frame.size.width height:FLT_MAX];
            
            
            
            NSNumber *kern = @((xsize.width-fsize.width)/xFormat.length);
            
            MTLog(@"%@",kern);
            
            [attr addAttribute:kCTKernAttributeName value:kern range:NSMakeRange(0, format.length)];
            
            [[self.numberTextField.textView textStorage] setAttributedString:attr];
            
            
            [self.numberTextField.textView setSelectedRange:NSMakeRange(xpos, 0)];
        } else {
            [self.numberTextField setStringValue:format];
            [self.numberTextField setCursorToEnd];
        }
        
        
        
        
        
        // [self.numberTextField.cell setAttributedStringValue:attr];
        //
        //  [self.numberTextField setEditable:NO];
        
        
        
    }
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
    
    //    float rightOffset = self.bounds.size.width - 336;
    
    //    NSAttributedString *countryAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"country", nil) attributes:defaultLeftStringsAttributes()];
    //
    //    NSSize size = [countryAttributedString size];
    //    [countryAttributedString drawAtPoint:NSMakePoint(rightOffset - size.width, 66)];
    //
    //    NSAttributedString *yourNumberAttributedString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"your number", nil) attributes:defaultLeftStringsAttributes()];
    //    size = [yourNumberAttributedString size];
    //    [yourNumberAttributedString drawAtPoint:NSMakePoint(rightOffset - size.width, 17)];
    
    
    NSAttributedString *youCountryAttributedString;
    if(self.selectedCountry) {
        youCountryAttributedString = [[NSAttributedString alloc] initWithString:self.selectedCountry.shortCountryName attributes:@{NSFontAttributeName: TGSystemLightFont(15), NSForegroundColorAttributeName: self.countryCodeTextField.isEnabled ? NSColorFromRGB(0x000000) : NSColorFromRGB(0xc3c3c3)}];
    } else {
        youCountryAttributedString = [[NSAttributedString alloc] initWithString:self.countryCodeTextField.stringValue.length ?   NSLocalizedString(@"Login.InvalidCountry", nil) : NSLocalizedString(@"Registration.ChooseCountry", nil) attributes:@{NSFontAttributeName: TGSystemLightFont(15), NSForegroundColorAttributeName: NSColorFromRGB(0xaeaeae)}];
    }
    
    //    NSSize size = [youCountryAttributedString size];
    [youCountryAttributedString drawAtPoint:NSMakePoint(120, 66)];
    
    
	[NSColorFromRGB(0xe6e6e6) set];
    NSRectFill(NSMakeRect(self.bounds.size.width - 322, 0, 322, 1));
    NSRectFill(NSMakeRect(self.bounds.size.width - 322, 50, 322, 1));
    NSRectFill(NSMakeRect(self.bounds.size.width - 322 + self.countryCodeTextField.frame.size.width + 12, 0, 1, 50));
    
    [image_select() drawAtPoint:NSMakePoint(self.bounds.size.width - 24, 70) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void)performShake {
    float a = 3;
    float duration = 0.04;
    
    NSBeep();
    
    [self.countryCodeTextField prepareForAnimation];
    [self.numberTextField prepareForAnimation];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.countryCodeTextField setWantsLayer:NO];
        [self.numberTextField setWantsLayer:NO];
        
        if(self.selectedCountry)
            [self.numberTextField.window makeFirstResponder:self.numberTextField];
        else
            [self.countryCodeTextField.window makeFirstResponder:self.countryCodeTextField];
    }];
    
    [self.countryCodeTextField setAnimation:[TMAnimations shakeWithDuration:duration fromValue:CGPointMake(-a + self.countryCodeTextField.layer.position.x, self.countryCodeTextField.layer.position.y) toValue:CGPointMake(a + self.countryCodeTextField.layer.position.x, self.countryCodeTextField.layer.position.y)] forKey:@"position"];
    
    [self.numberTextField  setAnimation:[TMAnimations shakeWithDuration:duration fromValue:CGPointMake(-a + self.numberTextField.layer.position.x, self.numberTextField.layer.position.y) toValue:CGPointMake(a + self.numberTextField.layer.position.x, self.numberTextField.layer.position.y)] forKey:@"position"];
    
    [CATransaction commit];
}

- (void)performBlocking:(BOOL)isBlocking {
    BOOL isEnabled = !isBlocking;
    NSColor *textColor = isEnabled ? NSColorFromRGB(0x000000) : NSColorFromRGB(0x888888);
    
    [self.countryCodeTextField setEnabled:isEnabled];
    [self.countryNameTextField setEnabled:isEnabled];
    [self.numberTextField setEnabled:isEnabled];
    [self.popupButton setEnabled:isEnabled];
    
    [self.numberTextField setTextColor:textColor];
    [self.countryCodeTextField setTextColor:textColor];
    [self.countryNameTextField setTextColor:textColor];
    
    if(!isBlocking) {
        [self.numberTextField.window makeFirstResponder:self.numberTextField];
        [self.numberTextField setCursorToEnd];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.numberTextField.window makeFirstResponder:self.numberTextField];
            [self.numberTextField setCursorToEnd];
        });
    }
    
    [self setNeedsDisplay:YES];
}

- (void)showEditButton:(BOOL)isShow {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [self.editTextButton setHidden:self.editTextButton.layer.opacity == 0];
        if(!IS_RETINA) {
            [self.editTextButton setWantsLayer:NO];
        }
    }];
    
    [self.editTextButton prepareForAnimation];
    [self.editTextButton.layer setOpacity:self.editTextButton.isHidden ? 0 : 1];
    [self.editTextButton setHidden:NO];
    
    float duration = 0.2;
    if(isShow) {
        //        [self.editTextButton setDisable:NO];
        if(!self.editTextButton.layer.opacity)
            [self.editTextButton setAnimation:[TMAnimations fadeWithDuration:duration fromValue:0 toValue:1] forKey:@"opacity"];
    } else {
        //        [self.editTextButton setDisable:YES];
        if(self.editTextButton.layer.opacity)
            [self.editTextButton setAnimation:[TMAnimations fadeWithDuration:duration fromValue:1 toValue:0] forKey:@"opacity"];
    }
    [CATransaction commit];
}


- (BOOL)isValidPhoneNumber {
    return (self.selectedCountry && self.numberTextField.stringValue.length) || [self.phoneNumber isEqualTo:@"+42"];
}

- (NSString *)phoneNumber {
    return [NSString stringWithFormat:@"%@%@", self.countryCodeTextField.stringValue, self.numberTextField.stringValue];
}

static NSDictionary *defaultLeftStringsAttributes() {
    static NSDictionary *dictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionary = @{NSFontAttributeName: TGSystemFont(13), NSForegroundColorAttributeName: NSColorFromRGB(0xc8c8c8)};
    });
    return dictionary;
}

-(void)clear {
    [self.numberTextField setStringValue:@""];
    
    NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    if(countryCode) {
        CountryItem *item = [[_ountriesManager sharedManager] itemBySmallCountryName:countryCode];
        if(item) {
            [self changeCountry:[[NSMenuItem alloc] initWithTitle:item.fullCountryName action:NULL keyEquivalent:@""]];
        }
    }
    
}

@end