//
//  AddContactViewController.m
//  Telegram
//
//  Created by keepcoder on 05.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "AddContactViewController.h"
#import "AddContactView.h"
@interface AddContactViewController ()
@property (nonatomic,strong) AddContactView *addContactView;
@end

@implementation AddContactViewController

-(void)loadView {
    [super loadView];
    
    self.addContactView = [[AddContactView alloc] initWithFrame:self.view.bounds];
    self.addContactView.controller = self;
    [self.view addSubview:self.addContactView];
    
}

-(void)close {
    [self.rbl close];
}

-(void)clear {
    [self.addContactView clear];
}

@end
