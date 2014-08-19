//
//  TMCollectionPageController.m
//  Messenger for Telegram
//
//  Created by keepcoder on 13.05.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMCollectionPageController.h"
#import "TMCollectionViewController.h"
#import "TMMediaController.h"
@interface TMCollectionPageController ()
@property (nonatomic,strong) TMCollectionViewController *mediaCollection;

@end

@implementation TMCollectionPageController

-(id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
        TMBackButton *backButton = [[TMBackButton alloc] initWithFrame:NSZeroRect string:NSLocalizedString(@"BackToProfile", nil)];
        self.leftNavigationBarView = [[TMView alloc] initWithFrame:backButton.bounds];
        [self.leftNavigationBarView addSubview:backButton];
        
        
        TMTextField *nameTextField = [TMTextField defaultTextField];
        [nameTextField setAlignment:NSCenterTextAlignment];
        [nameTextField setAutoresizingMask:NSViewWidthSizable];
        [nameTextField setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        [nameTextField setTextColor:NSColorFromRGB(0x222222)];
        [[nameTextField cell] setTruncatesLastVisibleLine:YES];
        [[nameTextField cell] setLineBreakMode:NSLineBreakByTruncatingTail];
        [nameTextField setDrawsBackground:NO];
        
        [nameTextField setFrameOrigin:NSMakePoint(nameTextField.frame.origin.x, -15)];
        
        [nameTextField setStringValue:NSLocalizedString(@"Profile.SharedMedia", nil)];


        self.centerNavigationBarView = nameTextField;

        

    }
    
    return self;
}

-(void)loadView {
    [super loadView];
    
    _mediaCollection = [[TMCollectionViewController alloc] initWithNibName:@"TMCollectionViewController" bundle:nil];
    
     [_mediaCollection.view setFrame:self.view.bounds];
    
    [_mediaCollection.view setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:_mediaCollection.view];

}

-(void)setConversation:(TL_conversation *)conversation {
    self->_conversation = conversation;
    
    [[TMMediaController controller] prepare:conversation completionHandler:^{
        [_mediaCollection setItems:[TMMediaController controller]->items conversation:conversation];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    
}

@end
