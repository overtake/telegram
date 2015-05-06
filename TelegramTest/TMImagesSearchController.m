//
//  TMImagesSearchController.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/18/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMImagesSearchController.h"
#import <Foundation/Foundation.h>
#import <Availability.h>
#import "AFImageRequestOperation.h"
#import "TMSearchImage.h"

#define NUM_IN_ROW 5

@interface TMImagesSearchController()
@property (nonatomic) BOOL isInitialized;
@property (nonatomic, strong) NSData *authData;
@property (nonatomic, strong) AFHTTPClient *httpClient;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSSearchField *searchTextField;
@property (nonatomic, strong) CNGridView *gridView;

@property (nonatomic, strong) CNGridViewItemLayout *defaultLayout;
@property (nonatomic, strong) CNGridViewItemLayout *hoverLayout;
@property (nonatomic, strong) CNGridViewItemLayout *selectionLayout;

@end

@implementation TMImagesSearchController

+ (TMImagesSearchController *)sharedInstance {
    static TMImagesSearchController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TMImagesSearchController alloc] init];
    });
    return instance;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        NSString *authKey = TGEncodeText(@"rdO,D9[52JGcfJtRtEkr:1sjoJoFLbOKfx,z:DCByeN", -1);
        self.authData = [[[NSString alloc] initWithFormat:@"%@:%@", authKey, authKey] dataUsingEncoding:NSUTF8StringEncoding];
        self.httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"https://api.datamarket.azure.com"]];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    self.searchTextField = [[NSSearchField alloc] init];
    [self.searchTextField sizeToFit];
    self.searchTextField.delegate = self;
    [[self.searchTextField cell] setPlaceholderString:NSLocalizedString(@"Search", nil)];
    [[[self.searchTextField cell] cancelButtonCell] performClick:self];
    [self.searchTextField setFrameSize:NSMakeSize(self.view.bounds.size.width - 20, self.searchTextField.bounds.size.height)];
    [self.searchTextField setFrameOrigin:NSMakePoint(10, self.view.bounds.size.height - self.searchTextField.bounds.size.height - 10)];
    [self.searchTextField setAutoresizingMask:NSViewWidthSizable | NSViewMinYMargin];
    [self.view addSubview:self.searchTextField];
    
    self.gridView = [[CNGridView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width - 20, self.view.bounds.size.height - self.searchTextField.bounds.size.height - 50)];
    [self.gridView setAutoresizingMask:NSViewWidthSizable];
    self.gridView.delegate = self;
    self.gridView.dataSource = self;
    [self.gridView setBackgroundColor:[NSColor redColor]];
    [self.view addSubview:self.gridView];
}

- (BOOL)becomeFirstResponder {
    [self.searchTextField.window makeFirstResponder:self.searchTextField];
    [self.searchTextField setCursorToEnd];
    return [super becomeFirstResponder];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    
    NSString *searchQuery = [textField stringValue];
    [self loadImagesByQuery:searchQuery completeHandler:^(BOOL result, NSArray *results) {
        if(!result || !results) {
            MTLog(@"error loaging");
            return;
        }
        
        if(results.count == 0) {
            MTLog(@"count is 0");
            return;
        }
        
        self.items = [NSMutableArray arrayWithArray:results];
        [self.gridView reloadData];
    }];
}

- (void)loadImagesByQuery:(NSString *)query completeHandler:(void (^)(BOOL result, NSArray *results))completeHandler {
    NSString *path = [NSString stringWithFormat:@"https://api.datamarket.azure.com/Bing/Search/v1/Image?Query='%@'&$skip=%d&$top=%d&$format=json", query, 0, 50];
    
    NSURL *url = [NSURL URLWithString:path];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    NSString *authValue = [[NSString alloc] initWithFormat:@"Basic %@", [self stringByEncodingInBase64:self.authData]];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSMutableArray *resultsObjects = [[NSMutableArray alloc] init];

        
        NSError *e;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&e];
        
        NSDictionary *d = [jsonDictionary objectForKey:@"d"];
        if(d) {
            NSArray *results = [d objectForKey:@"results"];
            if(results) {
                for(NSDictionary *imageDictionary in results) {
                    
                    NSDictionary *thumbImageDictionary = [imageDictionary objectForKey:@"Thumbnail"];
                    if(!thumbImageDictionary)
                        continue;
                    
                    TMSearchImage *imageObject = [[TMSearchImage alloc] init];
                    imageObject.mediaUrl = [imageDictionary objectForKey:@"MediaUrl"];
                    imageObject.displayUrl = [imageDictionary objectForKey:@"DisplayUrl"];
                    imageObject.sourceUrl = [imageDictionary objectForKey:@"SourceUrl"];
                    imageObject.title = [imageDictionary objectForKey:@"Title"];
                    imageObject.n_id = [imageDictionary objectForKey:@"ID"];
                    imageObject.thumbUrl = [thumbImageDictionary objectForKey:@"MediaUrl"];
                    imageObject.size = NSMakeSize([[imageDictionary objectForKey:@"Width"] intValue], [[imageDictionary objectForKey:@"Height"] intValue]);
                    imageObject.fileSize = [[imageDictionary objectForKey:@"FileSize"] integerValue];
                
                    imageObject.thumbSize = NSMakeSize([[thumbImageDictionary objectForKey:@"Width"] intValue], [[thumbImageDictionary objectForKey:@"Height"] intValue]);
                    imageObject.thumbFileSize = [[thumbImageDictionary objectForKey:@"FileSize"] integerValue];
                
                    [resultsObjects addObject:imageObject];
                }
            }
        }
        
        if(completeHandler)
            completeHandler(YES, resultsObjects);
        

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(completeHandler)
            completeHandler(NO, nil);

    }];
    [self.httpClient enqueueHTTPRequestOperation:httpOperation];
}


//Table

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section {
	return self.items.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section {
	static NSString *reuseIdentifier = @"CNGridViewItem";
    
	CNGridViewItem *item = [gridView dequeueReusableItemWithIdentifier:reuseIdentifier];
	if (item == nil) {
		item = [[CNGridViewItem alloc] initWithLayout:self.defaultLayout reuseIdentifier:reuseIdentifier];
	}
	item.hoverLayout = self.hoverLayout;
	item.selectionLayout = self.selectionLayout;
    
    
    MTLog(@"frame %@", NSStringFromRect(item.frame));
//
//	NSDictionary *contentDict = [self.items objectAtIndex:index];
//	item.itemTitle = [contentDict objectForKey:kContentTitleKey]; // [NSString stringWithFormat:@"Item: %lu", index];
//	item.itemImage = [contentDict objectForKey:kContentImageKey];
//
	return item;
}

#pragma mark - NSNotifications

- (void)detectedNotification:(NSNotification *)notif {
    //    CNLog(@"notification: %@", notif);
}

#pragma mark - CNGridView Delegate

- (void)gridView:(CNGridView *)gridView didClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	MTLog(@"didClickItemAtIndex: %li", index);
}

- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	MTLog(@"didDoubleClickItemAtIndex: %li", index);
}

- (void)gridView:(CNGridView *)gridView didActivateContextMenuWithIndexes:(NSIndexSet *)indexSet inSection:(NSUInteger)section {
	MTLog(@"rightMouseButtonClickedOnItemAtIndex: %@", indexSet);
}

- (void)gridView:(CNGridView *)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	MTLog(@"didSelectItemAtIndex: %li", index);
}

- (void)gridView:(CNGridView *)gridView didDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
	MTLog(@"didDeselectItemAtIndex: %li", index);
}


//

- (NSString *)stringByEncodingInBase64:(NSData *)data
{
    NSUInteger length = [data length];
    NSMutableData *mutableData = [[NSMutableData alloc] initWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3)
    {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++)
        {
            value <<= 8;
            if (j < length)
            {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

NSString *TGEncodeText(NSString *string, int key)
{
    NSMutableString *result = [[NSMutableString alloc] init];
    
    for (int i = 0; i < [string length]; i++)
    {
        unichar c = [string characterAtIndex:i];
        c += key;
        [result appendString:[NSString stringWithCharacters:&c length:1]];
    }
    
    return result;
}

@end
