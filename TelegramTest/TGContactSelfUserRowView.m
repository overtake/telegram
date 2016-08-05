//
//  TGContactSelfUserRowView.m
//  Telegram
//
//  Created by keepcoder on 05/08/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGContactSelfUserRowView.h"

@interface TGContactSelfUserRowView ()
@property (nonatomic,strong) TMAvatarImageView *photoView;
@property (nonatomic,strong) TMNameTextField *nameView;
@property (nonatomic,strong) TMTextField *phoneView;
@property (nonatomic,strong) NSMutableAttributedString *phoneNumber;
@end

@implementation TGContactSelfUserRowView

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _photoView = [TMAvatarImageView standartTableAvatar];
        _nameView = [[TMNameTextField alloc] initWithFrame:NSMakeRect(NSMaxX(_photoView.frame) + 10, 8, NSWidth(frameRect) - NSMaxX(_photoView.frame) - 10, 20)];
        [_nameView setSelector:@selector(dialogTitle)];
        self.isFlipped = YES;
        
        
        [_photoView setCenteredYByView:self];
        
        _phoneView = [TMTextField defaultTextField];
        [_phoneView setFont:TGSystemFont(13)];
        [_phoneView setTextColor:GRAY_TEXT_COLOR];
        [_phoneView setFrame:NSMakeRect(NSMaxX(_photoView.frame) + 10, NSMaxY(_nameView.frame) + 5, NSWidth(frameRect) - NSMaxX(_photoView.frame) - 10, 20)];

        [self addSubview:_photoView];
        [self addSubview:_nameView];
        [self addSubview:_phoneView];
        
    }
    
    return self;
}

-(void)checkSelected:(BOOL)isSelected
{
    [_nameView setSelected:isSelected];
    [_phoneNumber setSelected:isSelected];
    
    [_phoneView setAttributedString:_phoneNumber];

}


-(void)drawRect:(NSRect)dirtyRect {
    
    if(self.isSelected) {
        [BLUE_COLOR_SELECT setFill];
        NSRectFill(NSMakeRect(0, 0, self.bounds.size.width, self.bounds.size.height));
    } else {
        [super drawRect:dirtyRect];
    }
    
}


-(void)redrawRow {
    [super redrawRow];
    
    [_photoView setUser:[UsersManager currentUser]];
    [_nameView setUser:[UsersManager currentUser]];
    
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    [attr appendString:[UsersManager currentUser].phoneWithFormat withColor:GRAY_TEXT_COLOR];
    [attr setFont:TGSystemFont(13) forRange:attr.range];
    [attr setSelectionColor:[NSColor whiteColor] forColor:GRAY_TEXT_COLOR];
    
    [attr setSelected:self.isSelected];
    
    _phoneNumber = attr;
    
    [_phoneView setAttributedString:attr];
    
}

@end
