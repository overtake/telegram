//
//  TGSessionRowView.m
//  Telegram
//
//  Created by keepcoder on 26.03.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGSessionRowView.h"

@interface TGSessionRowView ()
@property (nonatomic, strong) TMTextField *textField;
@property (nonatomic, strong) TMTextButton *resetSession;
@end

@implementation TGSessionRowView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.textField = [TMTextField defaultTextField];
        
        [self.textField setFont:[NSFont fontWithName:@"HelveticaNeue" size:13]];
        
        [self addSubview:self.textField];
        
        [self.textField setFrameOrigin:NSMakePoint(100, 0)];
        
        
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
    
    
    [self.resetSession setHidden:item.authorization.n_hash == 0];
    
    NSMutableAttributedString *description = [[NSMutableAttributedString alloc] init];
    
    
    
    NSRange range = [description appendString:[NSString stringWithFormat:@"%@ %@\n",item.authorization.app_name, item.authorization.app_version]];
    
    [description setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:13] forRange:range];
    
    
    range = [description appendString:[NSString stringWithFormat:@"%@, %@ %@\n",item.authorization.device_model,item.authorization.platform,item.authorization.system_version]];
    
    [description setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:range];
    
    range = [description appendString:[NSString stringWithFormat:@"%@ (%@)",item.authorization.country, item.authorization.ip] withColor:NSColorFromRGB(0x999999)];
    
    [description setFont:[NSFont fontWithName:@"HelveticaNeue" size:12] forRange:range];

    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [description addAttribute:NSParagraphStyleAttributeName value:style range:description.range];
    
    [self.textField setAttributedStringValue:description];
    

    [self setNeedsDisplay:YES];
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [self.resetSession setFrameOrigin:NSMakePoint( NSWidth(self.frame) - NSWidth(self.resetSession.frame) - 113, 18)];
    
    [self.textField setFrameSize:NSMakeSize(NSMinX(self.resetSession.frame) - 110, NSHeight(self.frame))];
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    
    [NSColorFromRGB(0xe0e0e0) setFill];
    
    NSRectFill(NSMakeRect(100, 0, NSWidth(self.frame) - 200, 1));
    
}


@end
