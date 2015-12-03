//
//  TGModalGifSearch.m
//  Telegram
//
//  Created by keepcoder on 03/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGModalGifSearch.h"

#import "TMTableView.h"
#import "TMSearchTextField.h"
@interface TGModalGifSearch () <TMSearchTextFieldDelegate>
@property (nonatomic,strong) TMTableView *tableView;
@property (nonatomic,strong) TMSearchTextField *searchField;

@end

@implementation TGModalGifSearch

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        [self setContainerFrameSize:NSMakeSize(300, 300)];
        
        [self initialize];
    }
    
    return self;
}


-(void)initialize {
    _tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(0, 0, self.containerSize.width, self.containerSize.height-50)];
    [self addSubview:_tableView.containerView];
    
    
    _searchField = [[TMSearchTextField alloc] initWithFrame:NSMakeRect(10, self.containerSize.height - 40, self.containerSize.width - 20, 30)];
    _searchField.delegate = self;
    [self addSubview:_searchField];
}


-(void)searchFieldTextChange:(NSString *)searchString {
    
}

@end
