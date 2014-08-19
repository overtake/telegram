//
//  LoginWindow.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/11/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LoginWindow.h"
#import "NewLoginViewController.h"


@implementation LoginWindow


- (id)init {
    self = [super init];
    if(self) {
        
        
        self.autoSaver = [TGWindowArchiver find:NSStringFromClass([MainWindow class])];
        
        
        
        [super initialize:self.autoSaver];
        
        
        if(!self.autoSaver) {
            self.autoSaver = [[TGWindowArchiver alloc] initWithName:NSStringFromClass([MainWindow class])];
            self.autoSaver.origin = self.frame.origin;
            self.autoSaver.size = self.frame.size;
        }

        
        TMNavigationController *navigationController = [[TMNavigationController alloc] initWithFrame:((NSView *)self.contentView).bounds];
        
        NewLoginViewController *loginViewController = [[NewLoginViewController alloc] initWithFrame:((NSView *)self.contentView).bounds];
        [navigationController pushViewController:loginViewController animated:NO];
        self.rootViewController = navigationController;
    }
    return self;
}





@end
