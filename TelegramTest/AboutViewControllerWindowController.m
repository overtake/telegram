//
//  AboutViewControllerWindowController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 03.04.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "AboutViewControllerWindowController.h"

@interface AboutViewControllerWindowController ()
@property (weak) IBOutlet NSTextField *version;

@end

@implementation AboutViewControllerWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.version setStringValue:[NSString stringWithFormat:@"Version %@",API_VERSION]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)keyDown:(NSEvent *)theEvent {
    
}

@end
