//
//  AccountSettingsViewController.m
//  Telegram
//
//  Created by keepcoder on 26.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "ChatAvatarImageView.h"
#import "TMPreviewUserPicture.h"
#import "TMMediaUserPictureController.h"
#import "UserInfoShortButtonView.h"


@interface ExView : TMView

@end

@implementation ExView

-(void)drawRect:(NSRect)dirtyRect {
    [NSColorFromRGB(0xffffff) set];
    
    NSRectFill(NSMakeRect(0, 0, NSWidth(self.bounds) - DIALOG_BORDER_WIDTH, NSHeight(self.bounds)));
}

@end


@interface AccountSettingsViewController ()
@property (nonatomic,strong) ChatAvatarImageView *avatarImageView;
@property (nonatomic,strong) TMNameTextField *nameTextField;
@property (nonatomic,strong) TMTextField *numberTextField;

@property (nonatomic,strong) UserInfoShortButtonView *updateProfileButton;
@end

@implementation AccountSettingsViewController

-(void)loadView {
    
    self.view = [[ExView alloc] initWithFrame:self.frameInit];
    
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.avatarImageView = [ChatAvatarImageView standartUserInfoAvatar];
    [self.avatarImageView setCenterByView:self.view];
    
    int currentY = 300;
    
    [self.avatarImageView setFrameOrigin:NSMakePoint(NSMinX(self.avatarImageView.frame), currentY)];
    [self.view addSubview:self.avatarImageView];
    
    currentY-=50;
    
    self.nameTextField = [[TMNameTextField alloc] initWithFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - DIALOG_BORDER_WIDTH, 40)];
    
    [self.nameTextField setSelector:@selector(titleForMessage)];
    
    [self.nameTextField setUser:[UsersManager currentUser]];
    
    [self.view addSubview:self.nameTextField];
    
    
    
    self.numberTextField = [TMTextField defaultTextField];
    
    currentY-=30;
    
    [self.numberTextField setFrame:NSMakeRect(0, currentY, NSWidth(self.view.frame) - DIALOG_BORDER_WIDTH, 40)];
    
    
    NSMutableAttributedString *number = [[NSMutableAttributedString alloc] init];
    
    [number appendString:[UsersManager currentUser].phoneWithFormat withColor:DARK_GRAY];
    
    [number setAlignment:NSCenterTextAlignment range:number.range];
    
    [number setFont:[NSFont fontWithName:@"HelveticaNeue" size:14] forRange:number.range];
    
    [self.numberTextField setAttributedStringValue:number];
    
    [self.view addSubview:self.numberTextField];
    
    
    self.updateProfileButton = [UserInfoShortButtonView buttonWithText:@"Update Profile Photo" tapBlock:^{
        [self.avatarImageView showUpdateChatPhotoBox];
    }];
    
    currentY-=40;
    
    [self.updateProfileButton setFrame:NSMakeRect(10, currentY, NSWidth(self.view.frame) - 20, 60)];
    
    [self.updateProfileButton.textButton setAlignment:NSCenterTextAlignment];
    [self.updateProfileButton.textButton setFrameSize:NSMakeSize(NSWidth(self.updateProfileButton.frame), NSHeight(self.updateProfileButton.textButton.frame))];
    [self.updateProfileButton.textButton setFrameOrigin:NSMakePoint(0, NSMinY(self.updateProfileButton.textButton.frame))];
    
    
    [self.view addSubview:self.updateProfileButton];
    
    self.updateProfileButton.autoresizingMask = self.updateProfileButton.textButton.autoresizingMask = self.numberTextField.autoresizingMask = self.nameTextField.autoresizingMask = NSViewWidthSizable;
    
    self.avatarImageView.autoresizingMask = NSViewMinXMargin | NSViewMaxXMargin;
    
    
    weakify();
    [_avatarImageView setTapBlock:^{
        PreviewObject *previewObject = [[PreviewObject alloc] initWithMsdId:0 media:[UsersManager currentUser].photo.photo_big peer_id:[UsersManager currentUserId]];
        
        previewObject.reservedObject = strongSelf.avatarImageView;
        
        TMPreviewUserPicture *picture = [[TMPreviewUserPicture alloc] initWithItem:previewObject];
        if(picture)
            [[TMMediaUserPictureController controller] show:picture];
    }];
    
    [_avatarImageView setSourceType:ChatAvatarSourceUser];
    
    [self.avatarImageView setUser:[UsersManager currentUser]];
    
}

@end
