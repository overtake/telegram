//
//  СountriesManager.h
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryItem : NSObject
@property (nonatomic, strong) NSString *shortCountryName;
@property (nonatomic, strong) NSString *fullCountryName;
@property (nonatomic, strong) NSString *smallCountryName;
@property (nonatomic) int countryCode;
@end


@interface PhoneFormatXItem : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *longName;
@property (nonatomic, strong) NSString *format;
@property (nonatomic) int countryCode;
@property (nonatomic) int numSymbols;
@end

@interface _ountriesManager : NSObject

+ (_ountriesManager *)sharedManager;

@property (nonatomic, strong) NSArray *countries;



- (CountryItem *)itemByCodeNumber:(int)codeNumber;
- (CountryItem *)itemBySmallCountryName:(NSString *)countryName;
- (CountryItem *)itemByFullCountryName:(NSString *)countryName;
- (CountryItem *)itemByShortCountryName:(NSString *)countryName;

- (PhoneFormatXItem *)formatByCodeNumber:(int)codeNumber;
- (PhoneFormatXItem *)formatByShortName:(NSString *)countryName;
- (PhoneFormatXItem *)formatByName:(NSString *)countryName;
@end
