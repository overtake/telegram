//
//  ContactsViewController.m
//  Telegram
//
//  Created by keepcoder on 26.08.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "ContactsViewController.h"
#import "SearchTableCell.h"
#import "SearchItem.h"
#import "SearchSeparatorItem.h"
#import "DialogTableItemView.h"

#import "SelectUserItem.h"
#import "SelectUserRowView.h"
#import "NewConversationViewController.h"
#import "RBLPopover.h"
#import "AddContactViewController.h"
@interface ContactFirstItem : TMRowItem

@end

@implementation ContactFirstItem


-(NSUInteger)hash {
    return 0;
}

@end

@interface ContactFirstView : TMRowView
@property (nonatomic,strong) TMTextField *field;
@property (nonatomic,strong) NSImageView *imageView;
@end

@implementation ContactFirstView

-(id)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        self.field = [TMTextField defaultTextField];
        
        [self.field setBackgroundColor:[NSColor clearColor]];
        [self.field setFont:[NSFont fontWithName:@"HelveticaNeue-Medium" size:12]];
        [[self.field cell] setLineBreakMode:NSLineBreakByCharWrapping];
        [[self.field cell] setTruncatesLastVisibleLine:YES];
        
        [self.field setStringValue:NSLocalizedString(@"User.AddToContacts", nil)];
        
        [self.field sizeToFit];
        
        [self.field setTextColor:BLUE_UI_COLOR];
        
        [self.field setFrameOrigin:NSMakePoint(55, 13)];
        
        [self addSubview:self.field];
        
        NSImage *image = [NSImage imageNamed:@"ContactsAddContact"];
        
        self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(17, roundf( (40 - image.size.height) / 2), image.size.width, image.size.height)];
        
        
        self.imageView.image = image;
        
        [self addSubview:self.imageView];
    }
    
    return self;
}

-(void)drawRect:(NSRect)dirtyRect {
	
    [LIGHT_GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(55, 0, NSWidth(self.frame) - 55 , 1));
//    
//    [NSColorFromRGB(0xe41f5d) set];
//    NSRectFill(NSMakeRect(0, 1, self.bounds.size.width - DIALOG_BORDER_WIDTH, self.bounds.size.height));

}

@end


@interface ContactUserItem : SelectUserItem


@end


@implementation ContactUserItem


-(id)initWithObject:(id)object {
    if(self = [super initWithObject:object]) {
        
        self.noSelectTitlePoint = NSMakePoint(55, 26);
        self.noSelectLastSeenPoint = NSMakePoint(55, 8);
        self.noSelectAvatarPoint = NSMakePoint(11, roundf( (50 - 36) / 2));
        
        self.rightBorderMargin = 16;
        
    }
    
    return self;
}

@end



@interface ContactUserView : SelectUserRowView

-(ContactUserItem *)rowItem;
@property (nonatomic,strong) NSColor *color;
@end


@implementation ContactUserView



-(BOOL)isEditable {
    return NO;
}

-(BOOL)isSelectable {
    return YES;
}


-(NSColor *)color
{
    return _color != nil ? _color : NSColorFromRGB(0xffffff);
}

-(void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    self.color = NSColorFromRGB(0xfafafa);
    
    [self setNeedsDisplay:YES];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.color = NSColorFromRGB(0xffffff);
        [self setNeedsDisplay:YES];
    });
}

-(ContactUserItem *)rowItem {
    return (ContactUserItem *) [super rowItem];
}

-(void)drawRect:(NSRect)dirtyRect {
    
    NSPoint point = [self rowItem].noSelectTitlePoint;
	
    [LIGHT_GRAY_BORDER_COLOR setFill];
    
    NSRectFill(NSMakeRect(point.x+2, 0, NSWidth(self.frame) - point.x, 1));

    [self.color set];
    NSRectFill(NSMakeRect(0, 1, self.bounds.size.width - DIALOG_BORDER_WIDTH, self.bounds.size.height));
    
}

@end


@interface ContactsViewController ()<TMTableViewDelegate>

@property (nonatomic,strong) TMTableView *tableView;


@property (nonatomic,strong) ContactFirstItem *firstItem;
@property (nonatomic,strong) ContactFirstView *firstView;

@property (nonatomic,strong) AddContactViewController *addContactViewController;

@end

@implementation ContactsViewController


-(void)loadView {
    [super loadView];
    
    int topOffset = 50;
    
    self.searchViewController.type = SearchTypeContacts;
    
    self.addContactViewController = [[AddContactViewController alloc] initWithFrame:NSMakeRect(0, 0, 300, 200)];
    
    self.addContactViewController.rbl = [[RBLPopover alloc] initWithContentViewController:self.addContactViewController];
    self.addContactViewController.rbl.canBecomeKey = YES;
    
    self.tableView = [[DialogTableView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.frame), NSHeight(self.view.frame) - topOffset)];
    self.tableView.tm_delegate = self;
    
    [self.view addSubview:self.tableView.containerView];
    
    self.mainView = self.tableView.containerView;
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectFade;
    
  //  [self.tableView insert:@[self.broadcastItem,self.secretChatItem] startIndex:self.tableView.list.count tableRedraw:YES];
    
    
    
    
    self.firstItem = [[ContactFirstItem alloc] init];
    
    self.firstView = [[ContactFirstView alloc] initWithFrame:NSMakeRect(0, 0, NSWidth(self.view.frame), 40)];
    
    [self.tableView insert:self.firstItem atIndex:0 tableRedraw:YES];
    
    
    [Notification addObserver:self selector:@selector(contactsLoaded:) name:CONTACTS_MODIFIED];

}


-(void)contactsLoaded:(NSNotification *)notify {
    
    
    NSArray *all = [[NewContactsManager sharedManager] all];
    
    all = [all sortedArrayUsingComparator:^NSComparisonResult(TL_contact* obj1, TL_contact* obj2) {
        int first = obj1.user.lastSeenTime;
        int second = obj2.user.lastSeenTime;
        
        if ( first > second ) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if ( first < second ) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedSame;
        }
        
    }];
    

    
    if(all.count > 100) {
        [self insertAll:[all subarrayWithRange:NSMakeRange(0, 20)]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self insertAll:[all subarrayWithRange:NSMakeRange(20, all.count-20)]];
        });
    } else {
        [self insertAll:all];
    }
}

-(void)insertAll:(NSArray *)all {
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for(TL_contact *contact in all) {
        
        ContactUserItem *item = [[ContactUserItem alloc] initWithObject:contact];
        [contacts addObject:item];
    }
    
    NSTableViewAnimationOptions animation = self.tableView.defaultAnimation;
    
    self.tableView.defaultAnimation = NSTableViewAnimationEffectNone;
    
    [self.tableView insert:contacts startIndex:self.tableView.list.count tableRedraw:YES];
    
    self.tableView.defaultAnimation = animation;
}


- (void)dealloc {
    [Notification removeObserver:self];
}

- (void) setHidden:(BOOL)isHidden {
    [super setHidden:isHidden];
    
    if(isHidden) {
        [self.tableView setHidden:YES];
    } else {
        [self.tableView setHidden:NO];
    }
}



- (void)notificationContactsReload:(NSNotification *)notify {
    
    DLog(@"notification reload");
}



- (CGFloat) rowHeight:(NSUInteger)row item:(TMRowItem *)item {
    return [item isKindOfClass:[ContactUserItem class]] ? 50 : 40;
}

- (BOOL) isGroupRow:(NSUInteger)row item:(TMRowItem *) item {
    return NO;
}

- (NSView *)viewForRow:(NSUInteger)row item:(TMRowItem *)item {
    
    if([item isKindOfClass:[ContactUserItem class]]) {
        return [self.tableView cacheViewForClass:[ContactUserView class] identifier:@"contactItem" withSize:NSMakeSize(NSWidth(self.tableView.frame), 50)];
    }else if([item isKindOfClass:[ContactFirstItem class]]) {
        return [self.tableView cacheViewForClass:[ContactFirstView class] identifier:@"firstContactItem"];
    }
    
    return nil;
}


- (BOOL)isSelectable:(NSInteger)row item:(TMRowItem *)item {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [TMTableView setCurrent:self.tableView];
}

- (BOOL) selectionWillChange:(NSInteger)row item:(TMRowItem *) item {
    return YES;
}

- (void) selectionDidChange:(NSInteger)row item:(TMRowItem *) item {
    
    if([item isKindOfClass:[ContactUserItem class]]) {
         ContactUserItem *searchItem = (ContactUserItem *) item;
        [[Telegram sharedInstance] showMessagesWidthUser:searchItem.contact.user sender:self];
    } else if([item isKindOfClass:[ContactFirstItem class]]) {
        
        [self.addContactViewController clear];
        
         NSRect rect = self.tableView.containerView.bounds;
        rect.origin.y -= (NSHeight(self.tableView.containerView.frame) - 40);

        [self.addContactViewController.rbl showRelativeToRect:rect ofView:self.tableView.containerView preferredEdge:CGRectMinYEdge];
    }
   
}


@end
