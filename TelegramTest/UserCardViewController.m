//
//  UserCardViewController.m
//  Telegram
//
//  Created by keepcoder on 16.09.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "UserCardViewController.h"
#import "RBLPopover.h"
#import "TMBlueInputTextField.h"
@interface UserCardViewController ()
@property (nonatomic,strong) RBLPopover *popover;


@property (nonatomic,strong) TMView *exportView;
@property (nonatomic,strong) TMView *importView;

@property (nonatomic,strong) TMBlueInputTextField *inputField;
@property (nonatomic,assign) UserCardViewType type;


@property (nonatomic,strong) TMTextField *textField;
@property (nonatomic,strong) TMTextField *descTextField;
@property (nonatomic,strong) TMButton *button;
@property (nonatomic,strong) NSProgressIndicator *progress;


@property (nonatomic,strong) RPCRequest *request;
@property (nonatomic,strong) NSString *exportCard;

@end

@implementation UserCardViewController


-(id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.popover = [[RBLPopover alloc] initWithContentViewController:self];
        self.popover.canBecomeKey = YES;
    }
    
    return self;
}

-(void)loadView {
    [super loadView];
    
    
    
    self.progress = [[TGProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 20, 20)];
    
    
    [self.progress setStyle:NSProgressIndicatorSpinningStyle];
    
    self.importView = [[TMView alloc] initWithFrame:self.view.bounds];
    
    
    
    self.inputField = [[TMBlueInputTextField alloc] initWithFrame:NSMakeRect(18, 80, self.importView.frame.size.width-40, 35)];
    

    self.inputField.font = self.inputField.placeholderFont = TGSystemFont(13);
    self.inputField.placeholderTitle = NSLocalizedString(@"UserCard.exportPlaceholder", nil);
    self.inputField.placeholderTextColor = NSColorFromRGB(0xc8c8c8);
    [self.inputField setPlaceholderAligment:NSCenterTextAlignment];
    [self.inputField setDrawsFocusRing:NO];
    
    [self.inputField setAlignment:NSCenterTextAlignment];
    

    [self.importView addSubview:self.inputField];

    [self.inputField setActiveFieldColor:BLUE_UI_COLOR];
    [self.inputField setInactiveFieldColor:NSColorFromRGB(0xdedede)];
    
    
    
    
    self.exportView = [[TMView alloc] initWithFrame:self.view.bounds];
    
    
    self.button = [[TMButton alloc] initWithFrame:NSMakeRect(0, 0, self.exportView.frame.size.width, 47)];
    [self.button setAutoresizesSubviews:YES];
    [self.button setAutoresizingMask:NSViewMinXMargin];
    [self.button setTarget:self selector:@selector(actionExportCard)];
    [self.button setText:NSLocalizedString(@"UserCard.Export", nil)];
    [self.button setTextFont:TGSystemFont(12)];
    
    [self.button setBackgroundColor:NSColorFromRGB(0xfdfdfd)];
    
    [self.button setTextOffset:NSMakeSize(0, 0)];
    
   // [self.button setDrawBlock:separatorDraw];
    
    [self.button setTextColor:BLUE_UI_COLOR forState:TMButtonNormalState];
    [self.button setTextColor:NSColorFromRGB(0x467fb0) forState:TMButtonNormalHoverState];
    [self.button setTextColor:NSColorFromRGB(0x2e618c) forState:TMButtonPressedState];
    [self.button setTextColor:DARK_GRAY forState:TMButtonDisabledState];
    
    [self.exportView addSubview:self.button];
    
    
    self.textField = [TMTextField defaultTextField];
    [self.textField setFont:TGSystemFont(13)];
    
 //   [self.textField setSelectable:YES];
    
    [self.textField setDrawsBackground:YES];
  //  [self.textField setBackgroundColor:[NSColor redColor]];
    
    [self.exportView addSubview:self.textField];
    
    
    self.descTextField = [TMTextField defaultTextField];
    
    [self.descTextField setStringValue:NSLocalizedString(@"UserCard.ExportDesc", nil)];
    
    [self.descTextField setFrame:NSMakeRect(10, 55, NSWidth(self.exportView.frame) - 20, 65)];
    [self.descTextField setAlignment:NSCenterTextAlignment];
    [self.descTextField setTextColor:DARK_GRAY];
    
    [self.descTextField setDrawsBackground:YES];
   // [desc setBackgroundColor:[NSColor blueColor]];

    
    [self.exportView addSubview:self.descTextField];
    
    
    
    [self.exportView addSubview:self.progress];
    
    [self.progress setCenterByView:self.exportView];
    
    [self.progress setFrameOrigin:NSMakePoint(NSMinX(self.progress.frame), NSHeight(self.view.frame) - NSHeight(self.progress.frame) - 8)];
    
    [self.view addSubview:self.exportView];
    
   // [self setExportCard:@"6af3e:e93b01e9:7941c2ba:37bb2198:ed6f7dc4"];
    
}


-(void)setExportCard:(NSString *)card {
    self->_exportCard = card;
    [self.textField setStringValue:card];
    
    [self.textField sizeToFit];
    
    [self.textField setCenterByView:self.exportView];
    
    [self.textField setFrameOrigin:NSMakePoint(NSMinX(self.textField.frame), NSMinY(self.textField.frame) + 57)];
    
    
    [self.progress setHidden:YES];
    
    [self.textField setHidden:NO];
    [self.button setDisabled:NO];
}

-(void)actionExportCard {
    
    NSString *card = [TGImportCardPrefix stringByAppendingString:self.textField.stringValue];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString: card forType:NSStringPboardType];
    
    [self.popover close];
    
}




-(void)showWithType:(UserCardViewType)type relativeRect:(NSRect)rect ofView:(NSView *)view preferredEdge:(CGRectEdge)edge {
    self.type = type;
    
    if(!self.exportCard && !self.request){
        
        self.request = [RPCRequest sendRequest:[TLAPI_contacts_exportCard create] successHandler:^(RPCRequest *request, id response) {
            self.exportCard = decodeCard(response);
            self.request = nil;;
           
        } errorHandler:^(RPCRequest *request, RpcError *error) {
            
        }];
    }
    
    
    
    [self.popover showRelativeToRect:rect ofView:view preferredEdge:edge];
    
    if(self.request) {
        [self.button setDisabled:YES];
        [self.progress setHidden:NO];
        [self.progress startAnimation:self];
    }
}

@end
