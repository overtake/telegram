//
//  TGAttachImageElement.m
//  Telegram
//
//  Created by keepcoder on 18.02.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TGAttachImageElement.h"
#import "UIImageView+AFNetworking.h"

@interface TGAttachImageElement ()
@property (nonatomic,strong) NSString *link;
@property (nonatomic,strong) NSProgressIndicator *progress;
@property (nonatomic,strong) NSImageView *deleteImageView;
@property (nonatomic,strong) NSImageView *containerImageView;
@end

@implementation TGAttachImageElement

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _progress = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        
        [_progress setStyle:NSProgressIndicatorSpinningStyle];
        
        [_progress setCenterByView:self];
        
        [self addSubview:_progress];
        

        
        _deleteImageView = imageViewWithImage(image_RemoveSticker());
        
        
        self.containerImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(5, 5, NSWidth(self.frame) - 10, NSHeight(self.frame) - 10)];
        
        [self addSubview:self.containerImageView];
        
        _containerImageView.wantsLayer = YES;
        
        _containerImageView.layer.backgroundColor = GRAY_BORDER_COLOR.CGColor;
        
        _containerImageView.layer.cornerRadius = 3;
        
        
        [_deleteImageView setFrameOrigin:NSMakePoint(NSWidth(self.frame) - NSWidth(_deleteImageView.frame) , NSHeight(self.frame) - NSHeight(_deleteImageView.frame))];
        [self addSubview:_deleteImageView];
        
        
    }
    
    return self;
}

-(void)mouseDown:(NSEvent *)theEvent {
    BOOL inMouse = [self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:_deleteImageView.frame];
    
    if(inMouse && _deleteCallback) {
        _deleteCallback();
    }
}

-(NSImage *)image {
    return _containerImageView.image;
}

-(void)setLink:(NSString *)link range:(NSRange)range {
    _link = link;
    _range = range;
    
    [_progress setHidden:NO];
    [_progress startAnimation:self];
    [_containerImageView setHidden:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:link]];
    [request setHTTPShouldHandleCookies:NO];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    weakify();
    
    [_containerImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSImage *image) {
        
        [strongSelf.progress setHidden:YES];
        [strongSelf.progress stopAnimation:strongSelf];
        [strongSelf.containerImageView setHidden:NO];
        
        strongSelf.containerImageView.image = image;
        
        strongSelf = nil;
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
        if(strongSelf.deleteCallback)
            strongSelf.deleteCallback();
        
        strongSelf = nil;
        
    }];
}

@end
