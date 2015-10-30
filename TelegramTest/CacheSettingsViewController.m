//
//  CacheSettingsViewController.m
//  Telegram
//
//  Created by keepcoder on 28.07.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "CacheSettingsViewController.h"
#import "GeneralSettingsBlockHeaderView.h"
#import "GeneralSettingsDescriptionRowView.h"
#import "GeneralSettingsRowView.h"
#import "NSStringCategory.h"
@interface CacheSettingsViewController ()<TMTableViewDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) NSProgressIndicator *progress;
@end

@implementation CacheSettingsViewController


-(void)loadView {
    [super loadView];
    
    _tableView = [[TMTableView alloc] initWithFrame:self.view.bounds];
    
    _tableView.tm_delegate = self;
    
    _progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
    
    [_progress setStyle:NSProgressIndicatorSpinningStyle];
    
    [self.view addSubview:_progress];
  
    [self setCenterBarViewText:NSLocalizedString(@"Settings.Cache", nil)];
    
    
    [self.view addSubview:_tableView.containerView];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self proccess];
}


-(void)proccess {
    
    [_progress setHidden:NO];
    [_progress startAnimation:self];
    
    [_progress setCenterByView:self.view];
    
    [_tableView.containerView setHidden:YES];
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path() error:nil];
        
        NSArray *photos = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.jpg'"]];
        
        NSArray *videos = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mp4'"]];
        
        
        __block NSUInteger photoSize = 0;
        __block NSUInteger videoSize = 0;
        
        [photos enumerateObjectsUsingBlock:^(NSString*obj, NSUInteger idx, BOOL *stop) {
            
            photoSize+=fileSize([NSString stringWithFormat:@"%@/%@",path(),obj]);
            
        }];
        
        [videos enumerateObjectsUsingBlock:^(NSString*obj, NSUInteger idx, BOOL *stop) {
            
            videoSize+=fileSize([NSString stringWithFormat:@"%@/%@",path(),obj]);
            
        }];
        
        
        [ASQueue dispatchOnMainQueue:^{
            
            [_progress setHidden:YES];
            [_progress stopAnimation:self];
            [_tableView.containerView setHidden:NO];
            
            [self configureWithPhotoSize:photoSize videoSize:videoSize fullSize:photoSize+videoSize];
            
        }];
        
        
    }];
    
}

-(void)configureWithPhotoSize:(NSUInteger)photoSize videoSize:(NSUInteger)videoSize fullSize:(NSUInteger)fullSize {
    
    [self.tableView removeAllItems:YES];
    
    GeneralSettingsRowItem *photos = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        
        confirm(appName(), NSLocalizedString(@"Cache.ClearPhotoCache", nil), ^{
            
            [self clearWithType:@"jpg"];
            
        }, nil);
        
    } description:NSLocalizedString(@"Cache.Photos", nil) subdesc:[NSString sizeToTransformedValue:photoSize] height:82 stateback:^id(TGGeneralRowItem *item) {
        return @"";
    } ];
    
    GeneralSettingsRowItem *videos = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        confirm(appName(), NSLocalizedString(@"Cache.ClearVideoCache", nil), ^{
            
            [self clearWithType:@"mp4"];
            
        }, nil);
        
    } description:NSLocalizedString(@"Cache.Videos", nil) subdesc:[NSString sizeToTransformedValue:videoSize] height:42 stateback:^id(TGGeneralRowItem *item) {
        return @"";
    }];
    
    
    GeneralSettingsRowItem *allCache = [[GeneralSettingsRowItem alloc] initWithType:SettingsRowItemTypeNext callback:^(TGGeneralRowItem *item) {
        
        confirm(appName(), NSLocalizedString(@"Cache.ClearAllCache", nil), ^{
            
            [self clearWithType:nil];
            
        }, nil);
        
    } description:NSLocalizedString(@"Cache.AllCache", nil) subdesc:[NSString sizeToTransformedValue:fullSize] height:42 stateback:^id(TGGeneralRowItem *item) {
        
        return @"";
    }];
    
    
   [self.tableView addItem:photos tableRedraw:NO];
    
    if(videoSize > 0) {
        [self.tableView addItem:videos tableRedraw:NO];
        
        [self.tableView addItem:allCache tableRedraw:NO];
    }
    
    
    GeneralSettingsBlockHeaderItem *description = [[GeneralSettingsBlockHeaderItem alloc] initWithString:NSLocalizedString(@"Cache.Description", nil) height:100 flipped:YES];
    
    
    [self.tableView insert:description atIndex:self.tableView.count tableRedraw:NO];
    
    [self.tableView reloadData];
}


-(void)clearWithType:(NSString *)type {
    
    [self showModalProgress];
    
    [ASQueue dispatchOnStageQueue:^{
        
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path() error:nil];
        
        
        
        NSArray *toCleanFiles = files;
        
        if(type != nil)
        {
            toCleanFiles = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH %@",type]];
        }
        
        
        if(files.count != toCleanFiles.count)
        {
            [toCleanFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                
                [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path(),obj] error:nil];
                
            }];
        } else {
            [[NSFileManager defaultManager] removeItemAtPath:path() error:nil];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:path()
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        
        
        [ASQueue dispatchOnMainQueue:^{
            [self hideModalProgress];
            [self proccess];
        }];

        
    }];
    
}

- (CGFloat)rowHeight:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return  item.height;
}

- (BOOL)isGroupRow:(NSUInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (TMRowView *)viewForRow:(NSUInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[GeneralSettingsBlockHeaderItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsBlockHeaderView class] identifier:@"GeneralSettingsBlockHeaderView"];
    }
    
    if([item isKindOfClass:[GeneralSettingsRowItem class]]) {
        return [self.tableView cacheViewForClass:[GeneralSettingsRowView class] identifier:@"GeneralSettingsRowViewClass"];
    }
    
    return nil;
    
}

- (void)selectionDidChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    
}

- (BOOL)selectionWillChange:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}

- (BOOL)isSelectable:(NSInteger)row item:(GeneralSettingsRowItem *) item {
    return NO;
}


@end
