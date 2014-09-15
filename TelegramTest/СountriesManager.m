//
//  СountriesManager.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "СountriesManager.h"

@implementation CountryItem
@end

@implementation PhoneFormatXItem
@end

@interface _ountriesManager()
@property (nonatomic, strong) NSArray *formats;
@end

@implementation _ountriesManager

+ (_ountriesManager *)sharedManager {
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if(self) {
        [self parseCountries];
    }
    return self;
}

- (CountryItem *)itemByCodeNumber:(int)codeNumber {
    if(codeNumber == 7)
        return [self itemBySmallCountryName:@"ru"];
    if(codeNumber == 1)
        return [self itemBySmallCountryName:@"us"];
    
    for(CountryItem *item in self.countries) {
        if(item.countryCode == codeNumber)
            return item;
    }
    return nil;
}





- (CountryItem *)itemBySmallCountryName:(NSString *)countryName {
    countryName = [countryName lowercaseString];
    for(CountryItem *item in self.countries) {
        if([item.smallCountryName isEqualToString:countryName])
            return item;
    }
    return nil;
}

- (CountryItem *)itemByFullCountryName:(NSString *)countryName {
    for(CountryItem *item in self.countries) {
        if([item.fullCountryName isEqualToString:countryName])
            return item;
    }
    return nil;
}

- (CountryItem *)itemByShortCountryName:(NSString *)countryName {
    for(CountryItem *item in self.countries) {
        if([item.shortCountryName isEqualToString:countryName])
            return item;
    }
    return nil;
}



- (PhoneFormatXItem *)formatByCodeNumber:(int)codeNumber {
    for(PhoneFormatXItem *item in self.formats) {
        if(item.countryCode == codeNumber)
            return item;
    }
    return nil;
}





- (PhoneFormatXItem *)formatByShortName:(NSString *)countryName {
    countryName = [countryName lowercaseString];
    for(PhoneFormatXItem *item in self.formats) {
        if([item.name isEqualToString:countryName])
            return item;
    }
    return nil;
}

- (PhoneFormatXItem *)formatByName:(NSString *)countryName {
    for(PhoneFormatXItem *item in self.formats) {
        if([item.longName isEqualToString:countryName])
            return item;
    }
    return nil;
}



- (void)parseCountries {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"PhoneCountries.txt"]];
    NSString *fileContent = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *allLines = [fileContent componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    

    NSMutableArray *countries = [[NSMutableArray alloc] init];
    for(NSString *line in allLines) {
        NSArray *lineArray = [line componentsSeparatedByString:@";"];
        
        if(lineArray.count == 3) {
            CountryItem *item = [[CountryItem alloc] init];
            item.countryCode = [[lineArray objectAtIndex:0] intValue];
            item.smallCountryName = [[lineArray objectAtIndex:1] lowercaseString];
            item.shortCountryName = [lineArray objectAtIndex:2];
            item.fullCountryName = [NSString stringWithFormat:@"%@ +%d", item.shortCountryName, item.countryCode];
            
            [countries addObject:item];
        }
    }
    
    if(isTestServer()) {
        CountryItem *item = [[CountryItem alloc] init];
        item.countryCode = 9996;
        item.smallCountryName = @"ts";
        item.shortCountryName = @"Test Country";
        item.fullCountryName = @"TestCountry +9996";
        [countries addObject:item];
    }
    
    self.countries = [countries sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(CountryItem *obj1, CountryItem *obj2) {
        return [obj1.fullCountryName compare:obj2.fullCountryName];
    }];
    
    
    
    NSString *phoneFormat = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"phone-x-format.txt"]];
    NSArray *phoneFormatLines = [[[NSString alloc] initWithContentsOfFile:phoneFormat encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    
    NSMutableArray *formats = [[NSMutableArray alloc] init];
    
    [phoneFormatLines enumerateObjectsUsingBlock:^(NSString *line, NSUInteger idx, BOOL *stop) {
         NSArray *lineArray = [line componentsSeparatedByString:@";"];
        if(lineArray.count >= 5) {
            PhoneFormatXItem *item = [[PhoneFormatXItem alloc] init];
            item.countryCode = [[lineArray objectAtIndex:0] intValue];
            item.longName = [lineArray objectAtIndex:2];
            item.name = [lineArray objectAtIndex:1];
            item.format = [[lineArray objectAtIndex:3] lowercaseString];
            item.numSymbols = [[lineArray objectAtIndex:4] intValue];
            
            item.format = [item.format substringFromIndex:[item.format rangeOfString:@" "].location+1];
            
            item.longName = [NSString stringWithFormat:@"%@ +%d", item.longName, item.countryCode];
            [formats addObject:item];
        }
    }];
    
    self.formats = formats;
    
    
}

@end
