//
//  TGSessionRowView.m
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSessionRowView.h"

@interface TGSessionRowView ()
@property (nonatomic, strong) TMTextField *deviceName;
@property (nonatomic, strong) TMTextField *appName;
@property (nonatomic, strong) TMTextButton *resetSession;
@end

@implementation TGSessionRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.deviceName = [TMTextField defaultTextField];
        
        [self.deviceName setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        
        [self addSubview:self.deviceName];
        
        [self.deviceName setFrameOrigin:NSMakePoint(100, 27)];
        
        
        self.appName = [TMTextField defaultTextField];
        [self.appName setFont:[NSFont fontWithName:@"HelveticaNeue" size:12]];
        [self.appName setTextColor:NSColorFromRGB(0x999999)];
        [self addSubview:self.appName];
        
        [self.appName setFrameOrigin:NSMakePoint(100, 10)];
        
        
        
        self.resetSession = [TMTextButton standartUserProfileButtonWithTitle:NSLocalizedString(@"Authorization.Reset", nil)];
        
        [self.resetSession setFont:[NSFont fontWithName:@"HelveticaNeue" size:14]];
        [self.resetSession setTextColor:BLUE_UI_COLOR];
        
        [self.resetSession sizeToFit];
        
        weak();
        
        [self.resetSession setTapBlock:^ {
            
            [[Telegram rightViewController].sessionsViewContoller resetAuthorization:[weakSelf rowItem]];
            
        }];
        
        
        [self addSubview:self.resetSession];
        
    }
    return self;
}

- (void) redrawRow {
    
    [super redrawRow];
    
    
    TGSessionRowitem *item = (TGSessionRowitem *) [self rowItem];
    
    [self.deviceName setStringValue:[NSString stringWithFormat:@"%@ %@ %@",item.authorization.app_name,item.authorization.device_model,item.authorization.app_version]];
    
    [self.deviceName sizeToFit];
    
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] init];
    
    [description appendString:(item.authorization.flags & TGSESSIONOFFICIAL) == TGSESSIONOFFICIAL ? NSLocalizedString(@"Authorization.Official", nil) : NSLocalizedString(@"Authorization.Unofficial", nil) withColor:(item.authorization.flags & TGSESSIONOFFICIAL) == TGSESSIONOFFICIAL ? NSColorFromRGB(0x49ae5a) : NSColorFromRGB(0xe76568)];
    
    
    
    if((item.authorization.flags & TGSESSIONCURRENT) == TGSESSIONCURRENT)
    {
        [description appendString:[NSString stringWithFormat:@" (%@)", NSLocalizedString(@"Authorization.Current", nil)] withColor:NSColorFromRGB(0x808080)];
    }
    
    [description setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:description.range];
    
    [self.appName setAttributedStringValue:description];
    
    [self.appName sizeToFit];
    
    [self setNeedsDisplay:YES];
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.resetSession setFrameOrigin:NSMakePoint( NSWidth(self.frame) - NSWidth(self.resetSession.frame) - 113, 18)];
    
    [self.deviceName setFrameSize:NSMakeSize(NSMinX(self.resetSession.frame) - 110, NSHeight(self.deviceName.frame))];
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    
    [NSColorFromRGB(0xe0e0e0) setFill];
    
    NSRectFill(NSMakeRect(100, 0, NSWidth(self.frame) - 200, 1));
    
}


@end
