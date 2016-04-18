//
//  TGUserPopup.m
//  Telegram
//
//  Created by keepcoder on 15/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGUserPopup.h"

@interface TGUserPopup ()
@property (nonatomic,strong) TMAvatarImageView *photoView;
@property (nonatomic,strong) TMNameTextField *nameView;
@property (nonatomic,strong) TMStatusTextField *statusView;
@end

@implementation TGUserPopup


-(void)loadView {
    [super loadView];
    
    _photoView = [TMAvatarImageView standartTableAvatar];
    _nameView = [[TMNameTextField alloc] initWithFrame:NSMakeRect(60, 30, 200, 20)];
    _statusView = [[TMStatusTextField alloc] initWithFrame:NSMakeRect(60, 10, 200, 20)];
    [[_statusView cell] setTruncatesLastVisibleLine:YES];
    [[_statusView cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [[_nameView cell] setTruncatesLastVisibleLine:YES];
    [[_nameView cell] setLineBreakMode:NSLineBreakByTruncatingTail];
    [_statusView setSelector:@selector(statusForMessagesHeaderView)];
    
   
    
    
    [self.view addSubview:_photoView];
    [self.view addSubview:_nameView];
    [self.view addSubview:_statusView];
    
    
    [_photoView setFrameOrigin:NSMakePoint(5, 5)];
    
}

-(void)setObject:(id)object {
    [self loadViewIfNeeded];
    
    _object = object;
    
    if([_object isKindOfClass:[TLUser class]]) {
        [_photoView setUser:object];
        [_nameView setUser:object];
        [_statusView setUser:object];
    } else {
        [_photoView setChat:object];
        [_nameView setChat:object];
        [_statusView setChat:object];
    }
  
    
    [_nameView sizeToFit];
    [_statusView sizeToFit];
    
    [self updateSizes];
}

-(void)updateSizes {
    [_nameView setFrameSize:NSMakeSize(MIN(NSWidth(_nameView.frame), NSWidth(self.view.frame) - NSMaxX(_photoView.frame) - 10), NSHeight(_nameView.frame))];
    [_statusView setFrameSize:NSMakeSize(MIN(NSWidth(_statusView.frame), NSWidth(self.view.frame) - NSMaxX(_photoView.frame) - 10), NSHeight(_statusView.frame))];
}


@end
