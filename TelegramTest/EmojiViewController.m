//
//  EmojiViewController.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 6/10/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "EmojiViewController.h"
#import "TGAllStickersTableView.h"
#define EMOJI_IMAGE(img) image_test#img
#define EMOJI_COUNT_PER_ROW 8

@interface EmojiButton : BTRButton
@property (nonatomic, strong) NSString *smile;
@end

@implementation EmojiButton

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        
        
        [self setBackgroundImage:hoverImage() forControlState:BTRControlStateHover];
        [self setBackgroundImage:higlightedImage() forControlState:BTRControlStateHighlighted];

    }
    return self;
}

- (CGRect)labelFrame {
    return CGRectMake(0, 0, 34, 34);
}

static NSImage *hoverImage() {
    static NSImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[NSImage alloc] initWithSize:NSMakeSize(34, 34)];
        [image lockFocus];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, 34, 34) xRadius:6 yRadius:6];
        [NSColorFromRGB(0xf4f4f4) set];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

static NSImage *higlightedImage() {
    static NSImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [[NSImage alloc] initWithSize:NSMakeSize(34, 34)];
        [image lockFocus];
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, 34, 34) xRadius:6 yRadius:6];
        [NSColorFromRGB(0xdedede) set];
        [path fill];
        [image unlockFocus];
    });
    return image;
}

@end


@interface EmojiBottomButton : BTRButton
@property (nonatomic) int index;
@end

@implementation EmojiBottomButton

- (void)handleStateChange {
    [super handleStateChange];
    
    if(self.state & BTRControlStateHover || self.state & BTRControlStateSelected || self.state & BTRControlStateHighlighted) {
        [self.backgroundImageView setAlphaValue:1];
    } else {
        [self.backgroundImageView setAlphaValue:0.7];
    }
    
}

@end

@interface EmojiCellView : TMView
@property (nonatomic, strong) EmojiViewController *controller;
@end

@implementation EmojiCellView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if(self) {
        
        [self setWantsLayer:YES];
        
        for(int i = 0; i < EMOJI_COUNT_PER_ROW; i++) {
            EmojiButton *button = [[EmojiButton alloc] initWithFrame:NSMakeRect(34 * i, 0, 34, 34)];
            [button setTitleFont:[NSFont fontWithName:@"Helvetica" size:17] forControlState:BTRControlStateNormal];
            [button addTarget:self action:@selector(emojiClick:) forControlEvents:BTRControlEventLeftClick];
            [self addSubview:button];
        }
    }
    return self;
}

- (void)emojiClick:(BTRButton *)button {
    [self.controller insertEmoji:button.titleLabel.stringValue];
}

- (void)setEmoji:(NSString *)string atIndex:(int)index {
    EmojiButton *button = [self.subviews objectAtIndex:index];
    if(string) {
        [button setHidden:NO];
        [button setTitle:string forControlState:BTRControlStateNormal];
    } else {
        [button setHidden:YES];
    }
    
 
    [button setHighlighted:NO];
    [button setHovered:NO];
    [button setSelected:NO];
}


@end

@interface EmojiViewController ()

@property (nonatomic, strong) TMTextField *noRecentsTextField;

@property (nonatomic, strong) EmojiBottomButton *currentButton;
@property (nonatomic, strong) TMTableView *tableView;
@property (nonatomic, strong) TMView *bottomView;
@property (nonatomic, strong) NSArray *segments;
@property (nonatomic, strong) NSMutableArray *userEmoji;
@property (nonatomic, strong) TGAllStickersTableView *stickersTableView;

@end

@implementation EmojiViewController

- (void)saveEmoji:(NSArray *)array {
    
    for(NSString *emoji in array) {
        [self.userEmoji removeObject:emoji];
        [self.userEmoji insertObject:emoji atIndex:0];
    }
    
    [[Storage manager] saveEmoji:self.userEmoji];
    
    if(self.currentButton.index == 1) {
        [self bottomButtonClick:self.currentButton];
    }
}

+ (EmojiViewController *)instance {
    static EmojiViewController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[EmojiViewController alloc] initWithFrame:NSMakeRect(0, 0, 280, 240)];
    });
    return controller;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        
        
        self.userEmoji = [[Storage manager] emoji];
        
        NSMutableArray *popular = [[@"😂 😘 ❤️ 😍 😊 😁 👍 ☺️ 😔 😄 😭 💋 😒 😳 😜 🙈 😉 😃 😢 😝 😱 😡 😏 😞 😅 😚 🙊 😌 😀 😋 😆 👌 😐 😕" componentsSeparatedByString:@" "] mutableCopy];
        
        
        [self.userEmoji enumerateObjectsUsingBlock:^(NSString *emoji, NSUInteger idx, BOOL *stop) {
            [popular removeObject:emoji];
        }];
                
        [self.userEmoji addObjectsFromArray:popular];
        
        
        NSString *emoji2 = @"😄 😃 😀 😊 ☺️ 😉 😍 😘 😚 😗 😙 😜 😝 😛 😳 😁 😔 😌 😒 😞 😣 😢 😂 😭 😪 😥 😰 😅 😓 😩 😫 😨 😱 😠 😡 😤 😖 😆 😋 😷 😎 😴 😵 😲 😟 😦 😧 😈 👿 😮 😬 😐 😕 😯 😶 😇 😏 😑 👲 👳 👮 👷 💂 👶 👦 👧 👨 👩 👴 👵 👱 👼 👸 😺 😸 😻 😽 😼 🙀 😿 😹 😾 👹 👺 🙈 🙉 🙊 💀 👽 💩 🔥 ✨ 🌟 💫 💥 💢 💦 💧 💤 💨 👂 👀 👃 👅 👄 👍 👎 👌 👊 ✊ ✌️ 👋 ✋ 👐 👆 👇 👉 👈 🙌 🙏 ☝️ 👏 💪 🚶 🏃 💃 👫 👪 👬 👭 💏 💑 👯 🙆 🙅 💁 🙋 💆 💇 💅 👰 🙎 🙍 🙇 🎩 👑 👒 👟 👞 👡 👠 👢 👕 👔 👚 👗 🎽 👖 👘 👙 💼 👜 👝 👛 👓 🎀 🌂 💄 💛 💙 💜 💚 ❤️ 💔 💗 💓 💕 💖 💞 💘 💌 💋 💍 💎 👤 👥 💬 👣 💭";
        
        NSString *emoji3 = @"🐶 🐺 🐱 🐭 🐹 🐰 🐸 🐯 🐨 🐻 🐷 🐽 🐮 🐗 🐵 🐒 🐴 🐑 🐘 🐼 🐧 🐦 🐤 🐥 🐣 🐔 🐍 🐢 🐛 🐝 🐜 🐞 🐌 🐙 🐚 🐠 🐟 🐬 🐳 🐋 🐄 🐏 🐀 🐃 🐅 🐇 🐉 🐎 🐐 🐓 🐕 🐖 🐁 🐂 🐲 🐡 🐊 🐫 🐪 🐆 🐈 🐩 🐾 💐 🌸 🌷 🍀 🌹 🌻 🌺 🍁 🍃 🍂 🌿 🌾 🍄 🌵 🌴 🌲 🌳 🌰 🌱 🌼 🌐 🌞 🌝 🌚 🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘 🌜🌛 🌙 🌍 🌎 🌏 🌋 🌌 🌠 ⭐️ ☀️ ⛅️ ☁️ ⚡️ ☔️ ❄️ ⛄️ 🌀 🌁 🌈 🌊";
        
        NSString *emoji4 = @"🎍 💝 🎎 🎒 🎓 🎏 🎆 🎇 🎐 🎑 🎃 👻 🎅 🎄 🎁 🎋 🎉 🎊 🎈 🎌 🔮 🎥 📷 📹 📼 💿 📀 💽 💾 💻 📱 ☎️ 📞 📟 📠 📡 📺 📻 🔊 🔉 🔈 🔇 🔔 🔕 📢 📣 ⏳ ⌛️ ⏰ ⌚️ 🔓 🔒 🔏 🔐 🔑 🔎 💡 🔦 🔆 🔅 🔌 🔋 🔍 🛁 🛀 🚿 🚽 🔧 🔩 🔨 🚪 🚬 💣 🔫 🔪 💊 💉 💰 💴 💵 💷 💶 💳 💸 📲 📧 📥 📤 ✉️ 📩 📨 📯 📫 📪 📬 📭 📮 📦 📝 📄 📃 📑 📊 📈 📉 📜 📋 📅 📆 📇 📁 📂 ✂️ 📌 📎 ✒️ ✏️ 📏 📐 📕 📗 📘 📙 📓 📔 📒 📚 📖 🔖 📛 🔬 🔭 📰 🎨 🎬 🎤 🎧 🎼 🎵 🎶 🎹 🎻 🎺 🎷 🎸 👾 🎮 🃏 🎴 🀄️ 🎲 🎯 🏈 🏀 ⚽️ ⚾️ 🎾 🎱 🏉 🎳 ⛳️ 🚵 🚴 🏁 🏇 🏆 🎿 🏂 🏊 🏄 🎣 ☕️ 🍵 🍶 🍼 🍺 🍻 🍸 🍹 🍷 🍴 🍕 🍔 🍟 🍗 🍖 🍝 🍛 🍤 🍱 🍣 🍥 🍙 🍘 🍚 🍜 🍲 🍢 🍡 🍳 🍞 🍩 🍮 🍦 🍨 🍧 🎂 🍰 🍪 🍫 🍬 🍭 🍯 🍎 🍏 🍊 🍋 🍒 🍇 🍉 🍓 🍑 🍈 🍌 🍐 🍍 🍠 🍆 🍅 🌽";
        
        NSString *emoji5 = @"🏠 🏡 🏫 🏢 🏣 🏥 🏦 🏪 🏩 🏨 💒 ⛪️ 🏬 🏤 🌇 🌆 🏯 🏰 ⛺️ 🏭 🗼 🗾 🗻 🌄 🌅 🌃 🗽 🌉 🎠 🎡 ⛲️ 🎢 🚢 ⛵️ 🚤 🚣 ⚓️ 🚀 ✈️ 💺 🚁 🚂 🚊 🚉 🚞 🚆 🚄 🚅 🚈 🚇 🚝 🚋 🚃 🚎 🚌 🚍 🚙 🚘 🚗 🚕 🚖 🚛 🚚 🚨 🚓 🚔 🚒 🚑 🚐 🚲 🚡 🚟 🚠 🚜 💈 🚏 🎫 🚦 🚥 ⚠️ 🚧 🔰 ⛽️ 🏮 🎰 ♨️ 🗿 🎪 🎭 📍 🚩 🇯🇵 🇰🇷 🇩🇪 🇨🇳 🇺🇸 🇫🇷 🇪🇸 🇮🇹 🇷🇺 🇬🇧";
        
        NSString *emoji6 = @"1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣ 8️⃣ 9️⃣ 0️⃣ 🔟 🔢 #️⃣ 🔣 ⬆️ ⬇️ ⬅️ ➡️ 🔠 🔡 🔤 ↗️ ↖️ ↘️ ↙️ ↔️ ↕️ 🔄 ◀️ ▶️ 🔼 🔽 ↩️ ↪️ ℹ️ ⏪ ⏩ ⏫ ⏬ ⤵️ ⤴️ 🆗 🔀 🔁 🔂 🆕 🆙 🆒 🆓 🆖 📶 🎦 🈁 🈯️ 🈳 🈵 🈴 🈲 🉐 🈹 🈺 🈶 🈚️ 🚻 🚹 🚺 🚼 🚾 🚰 🚮 🅿️ ♿️ 🚭 🈷 🈸 🈂 Ⓜ️ 🛂 🛄 🛅 🛃 🉑 ㊙️ ㊗️ 🆑 🆘 🆔 🚫 🔞 📵 🚯 🚱 🚳 🚷 🚸 ⛔️ ✳️ ❇️ ❎ ✅ ✴️ 💟 🆚 📳 📴 🅰 🅱 🆎 🅾 💠 ➿ ♻️ ♈️ ♉️ ♊️ ♋️ ♌️ ♍️ ♎️ ♏️ ♐️ ♑️ ♒️ ♓️ ⛎ 🔯 🏧 💹 💲 💱 © ® ™ ❌ ‼️ ⁉️ ❗️ ❓ ❕ ❔ ⭕️ 🔝 🔚 🔙 🔛 🔜 🔃 🕛 🕧 🕐 🕜 🕑 🕝 🕒 🕞 🕓 🕟 🕔 🕠 🕕 🕖 🕗 🕘 🕙 🕚 🕡 🕢 🕣 🕤 🕥 🕦 ✖️ ➕ ➖ ➗ ♠️ ♥️ ♣️ ♦️ 💮 💯 ✔️ ☑️ 🔘 🔗 ➰ 〰 〽️ 🔱 ◼️ ◻️ ◾️ ◽️ ▪️ ▫️ 🔺 🔲 🔳 ⚫️ ⚪️ 🔴 🔵 🔻 ⬜️ ⬛️ 🔶 🔷 🔸 🔹";
        
        self.segments = @[self.userEmoji, [emoji2 componentsSeparatedByString:@" "], [emoji3 componentsSeparatedByString:@" "], [emoji4 componentsSeparatedByString:@" "], [emoji5 componentsSeparatedByString:@" "], [emoji6 componentsSeparatedByString:@" "]];
    }
    return self;
}

+(void)reloadStickers {
    [[self instance].stickersTableView load:YES];
}

- (void)loadView {
    [super loadView];
    
   
    

    self.bottomView = [[TMView alloc] initWithFrame:NSMakeRect(0, 0, self.view.bounds.size.width, 42)];
    for(int i = 1; i <= 7; i++) {
        BTRButton *button = [self createButtonForIndex:i];
        [button setFrameOrigin:NSMakePoint(i * 18 + 20 * (i - 1), 12)];
        [self.bottomView addSubview:button];
    }
    
    self.currentButton = [self.bottomView.subviews objectAtIndex:self.userEmoji.count ? 0 : 1];
    [self.currentButton setSelected:YES];
    [self.view addSubview:self.bottomView];
    
    
    self.stickersTableView = [[TGAllStickersTableView alloc] initWithFrame:NSMakeRect(6, self.bottomView.bounds.size.height, self.view.bounds.size.width - 12, self.view.bounds.size.height - self.bottomView.bounds.size.height - 4)];
    
    [self.stickersTableView load:NO];
    
    [self.view addSubview:self.stickersTableView.containerView];
    
    [self.stickersTableView.containerView setHidden:YES];

    
    self.tableView = [[TMTableView alloc] initWithFrame:NSMakeRect(6, self.bottomView.bounds.size.height, self.view.bounds.size.width - 12, self.view.bounds.size.height - self.bottomView.bounds.size.height - 4)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView.scrollView setHasVerticalScroller:YES];
    [self.tableView.containerView setWantsLayer:YES];
    [self.tableView.scrollView setScrollerKnobStyle:NSScrollerKnobStyleLight];
    [self.tableView.scrollView setIsHideVerticalScroller:YES];
    [self.view addSubview:self.tableView.containerView];
    
    self.noRecentsTextField = [[TMTextField alloc] initWithFrame:NSZeroRect];
    [self.noRecentsTextField setStringValue:NSLocalizedString(@"Emoji.NoRecents", nil)];
    [self.noRecentsTextField setFont:[NSFont fontWithName:@"Helvetica-Light" size:12]];
    [self.noRecentsTextField setTextColor:NSColorFromRGB(0xaeaeae)];
    [self.noRecentsTextField sizeToFit];
    [self.noRecentsTextField setDrawsBackground:NO];
    [self.noRecentsTextField setEditable:NO];
    [self.noRecentsTextField setSelectable:NO];
    [self.noRecentsTextField setBordered:NO];
    [self.noRecentsTextField setHidden:YES];
    [self.noRecentsTextField setAutoresizingMask:NSViewMaxXMargin | NSViewMinXMargin | NSViewMinYMargin | NSViewMaxYMargin];
    [self.view addSubview:self.noRecentsTextField];
}

- (EmojiBottomButton *)createButtonForIndex:(int)index {
    
    NSImage *image;
    NSImage *imageSelected;
    
    switch (index) {
        case 1:
            image = image_emojiContainer1();
            imageSelected = image_emojiContainer1Highlighted();
            break;
            
        case 2:
            image = image_emojiContainer2();
            imageSelected = image_emojiContainer2Highlighted();
            break;
            
        case 3:
            image = image_emojiContainer3();
            imageSelected = image_emojiContainer3Highlighted();
            break;
            
        case 4:
            image = image_emojiContainer4();
            imageSelected = image_emojiContainer4Highlighted();
            break;
            
        case 5:
            image = image_emojiContainer5();
            imageSelected = image_emojiContainer5Highlighted();
            break;
            
        case 6:
            image = image_emojiContainer6();
            imageSelected = image_emojiContainer6Highlighted();
            break;
            
        case 7:
            image = image_emojiContainer7();
            imageSelected = image_emojiContainer7Highlighted();
            break;
            
        default:
            break;
    }
    
    EmojiBottomButton *button = [[EmojiBottomButton alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
    [button setBackgroundImage:image forControlState:BTRControlStateNormal];
    [button setBackgroundImage:image forControlState:BTRControlStateHover];
    [button setBackgroundImage:imageSelected forControlState:BTRControlStateHover | BTRControlStateSelected];
    [button setBackgroundImage:imageSelected forControlState:BTRControlStateHighlighted];
    [button setBackgroundImage:imageSelected forControlState:BTRControlStateSelected];
    [button setIndex:index];
    [button addTarget:self action:@selector(bottomButtonClick:) forControlEvents:BTRControlEventLeftClick];
    return button;
}

- (void)showPopovers {
    [self bottomButtonClick:[self.bottomView.subviews objectAtIndex:self.userEmoji.count ? 0 : 1]];
}

- (void)bottomButtonClick:(EmojiBottomButton *)button {
    
    for(EmojiBottomButton *btn in self.bottomView.subviews) {
        [btn setSelected:btn == button];
    }
    
    self.currentButton = button;
    
    [self.tableView.containerView setHidden:NO];
    [self.noRecentsTextField setHidden:YES];
    
    if(self.currentButton.index == 1) {
        if([self numberOfRowsInTableView:self.tableView] == 0) {
            [self.noRecentsTextField setHidden:NO];
            [self.noRecentsTextField setCenterByView:self.view];
            [self.noRecentsTextField setFrameOrigin:NSMakePoint(self.noRecentsTextField.frame.origin.x, self.noRecentsTextField.frame.origin.y + 2)];
            [self.tableView.containerView setHidden:YES];
        }
    }
    
    [self.tableView reloadData];
    [self.tableView scrollToBeginningOfDocument:nil];
    
    if(self.currentButton.index == 7) {
        [self.stickersTableView load:NO];
    }
    
    
    [self.tableView.containerView setHidden:self.currentButton.index == 7];
    [self.stickersTableView.containerView setHidden:self.currentButton.index != 7];
    
    
}

- (void)insertEmoji:(NSString *)emoji {
    if(self.insertEmoji)
        self.insertEmoji(emoji);
}

//Table

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return ceilf(((NSArray *)self.segments[MIN(self.currentButton.index - 1, 5)]).count / 1.f / EMOJI_COUNT_PER_ROW);
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if(row < EMOJI_COUNT_PER_ROW) {
        return 36;
    }
    return 34;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    static NSString* const kRowIdentifier = @"smile";
    EmojiCellView *cell = [self.tableView makeViewWithIdentifier:kRowIdentifier owner:self];
    if(!cell) {
        cell = [[EmojiCellView alloc] initWithFrame:self.view.bounds];
        cell.identifier = kRowIdentifier;
        cell.controller = self;
    }
    
    
    NSArray *currentArray = self.segments[MIN(self.currentButton.index - 1, 5)];
    long startPos = row * EMOJI_COUNT_PER_ROW;
    for(long i = 0; i < EMOJI_COUNT_PER_ROW; i++) {
        NSString *emoji;
        if(startPos + i < currentArray.count) {
            emoji = currentArray[startPos + i];
        }
        
        [cell setEmoji:emoji atIndex:(int)i];
    }
    
    return cell;
}

@end