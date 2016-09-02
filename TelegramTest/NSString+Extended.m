//
//  NSString+Extended.m
//  Telegram
//
//  Created by Dmitry Kondratyev on 11/18/13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "NSString+Extended.h"

#import "NSString+FindURLs.h"

@implementation NSString (Extended)

- (NSString *) singleLine {
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (NSString *)URLDecode {
    return [[self
             stringByReplacingOccurrencesOfString:@"+" withString:@" "]
            stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *) trim {
    
    NSString *string = self;
    
    while ([string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]].location == 0 || [string rangeOfString:@"\n"].location == 0) {
        string = [string substringFromIndex:1];
    }
    

    while (string.length > 0 && ([string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:0 range:NSMakeRange(string.length - 1, 1)].location == string.length-1 || [string rangeOfString:@"\n" options:0 range:NSMakeRange(string.length - 1, 1)].location == string.length-1)) {
        string = [string substringToIndex:string.length - 1];
    }


    NSMutableString *replaceSlowCoreTextCharacters = [[NSMutableString alloc] init];
    
//    [string enumerateSubstringsInRange: NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
//     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
//         
//        
//         if(substring.length == 2) {
//             NSString *special = [substring substringFromIndex:1];
//             
//             if([special isEqualToString:@"\u0335"] || [special isEqualToString:@"\u0336"] || [special isEqualToString:@"\u0337"] || [special isEqualToString:@"\u0338"]) {
//                 [replaceSlowCoreTextCharacters appendString:[NSString stringWithFormat:@"-%@",[substring substringToIndex:1]]];
//                 return;
//             }
//         }
//         
//         [replaceSlowCoreTextCharacters appendString:substring];
//         
//     }];

    
    return string;
}

-(NSString *)fixEmoji {
    NSString *selfString = self;
    
    selfString = [selfString stringByReplacingOccurrencesOfString:@"✌" withString:@"✌️"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"☺" withString:@"☺️"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"☝" withString:@"☝️"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"1⃣" withString:@"1️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"2⃣" withString:@"2️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"3⃣" withString:@"3️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"4⃣" withString:@"4️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"5⃣" withString:@"5️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"6⃣" withString:@"6️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"7⃣" withString:@"7️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"8⃣" withString:@"8️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"9⃣" withString:@"9️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"0⃣" withString:@"0️⃣"];
    selfString = [selfString stringByReplacingOccurrencesOfString:@"❤" withString:@"❤️"];
    
    
    return selfString;
}


static NSDictionary *replaces;

+(NSDictionary *)emojiReplaceDictionary {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        replaces = [[NSMutableDictionary alloc] init];
        
        replaces = @{
                     @":smile:": @"😄",
                     @":hm:": @"🤔",
                     @":laughing:": @"😆",
                     @":blush:": @"😊",
                     @":smiley:": @"😃",
                     @":relaxed:": @"😊",
                     @":smirk:": @"😏",
                     @":heart_eyes:": @"😍",
                     @":kissing_heart:": @"😘",
                     @":kissing_closed_eyes:": @"😚",
                     @":flushed:": @"😳",
                     @":relieved:": @"😥",
                     @":satisfied:": @"😌",
                     @":grin:": @"😁",
                     @":wink:": @"😉",
                     @":wink2:": @"😜",
                     @":stuck_out_tongue_winking_eye:": @"😜",
                     @":stuck_out_tongue_closed_eyes:": @"😝",
                     @":grinning:": @"😀",
                     @":kissing:": @"😗",
                     @":kissing_smiling_eyes:": @"😙",
                     @":stuck_out_tongue:": @"😛",
                     @":sleeping:": @"😴",
                     @":worried:": @"😟",
                     @":frowning:": @"😦",
                     @":anguished:": @"😧",
                     @":open_mouth:": @"😮",
                     @":grimacing:": @"😬",
                     @":confused:": @"😕",
                     @":hushed:": @"😯",
                     @":expressionless:": @"😑",
                     @":unamused:": @"😒",
                     @":sweat_smile:": @"😅",
                     @":sweat:": @"😓",
                     @":weary:": @"😩",
                     @":pensive:": @"😔",
                     @":dissapointed:": @"😞",
                     @":confounded:": @"😖",
                     @":fearful:": @"😨",
                     @":cold_sweat:": @"😰",
                     @":persevere:": @"😣",
                     @":cry:": @"😢",
                     @":sob:": @"😭",
                     @":joy:": @"😂",
                     @":astonished:": @"😲",
                     @":scream:": @"😱",
                     @":tired_face:": @"😫",
                     @":angry:": @"😠",
                     @":rage:": @"😡",
                     @":triumph:": @"😤",
                     @":sleepy:": @"😪",
                     @":yum:": @"😋",
                     @":mask:": @"😷",
                     @":sunglasses:": @"😎",
                     @":dizzy_face:": @"😵",
                     @":imp:": @"👿",
                     @":smiling_imp:": @"😈",
                     @":neutral_face:": @"😐",
                     @":no_mouth:": @"😶",
                     @":innocent:": @"😇",
                     @":alien:": @"👽",
                     @":yellow_heart:": @"💛",
                     @":blue_heart:": @"💙",
                     @":purple_heart:": @"💜",
                     @":heart:": @"♥️",
                     @":green_heart:": @"💚",
                     @":broken_heart:": @"💔",
                     @":heartbeat:": @"💓",
                     @":heartpulse:": @"💗",
                     @":two_hearts:": @"💕",
                     @":revolving_hearts:": @"💞",
                     @":cupid:": @"💘",
                     @":sparkling_heart:": @"💖",
                     @":sparkles:": @"✨",
                     @":star:": @"⭐",
                     @":star2:": @"🌟",
                     @":dizzy:": @"💫",
                     @":boom:": @"💥",
                     @":collision:": @"💥",
                     @":anger:": @"💢",
                     @":exclamation:": @"❗",
                     @":question:": @"❓",
                     @":grey_exclamation:": @"❕",
                     @":grey_question:": @"❔",
                     @":zzz:": @"💤",
                     @":dash:": @"💨",
                     @":sweat_drops:": @"💦",
                     @":notes:": @"🎶",
                     @":musical_note:": @"🎵",
                     @":fire:": @"🔥",
                     @":hankey:": @"💩",
                     @":poop:": @"💩",
                     @":shit:": @"💩",
                     @":thumbsup:": @"👍",
                     @":+1:": @"👍",
                     @":thumbsdown:": @"👎",
                     @":-1:": @"👎",
                     @":ok_hand:": @"👌",
                     @":punch:": @"👊",
                     @":facepunch:": @"👊",
                     @":fist:": @"✊",
                     @":v:": @"✌",
                     @":wave:": @"👋",
                     @":hand:": @"✋",
                     @":open_hands:": @"👐",
                     @":point_up:": @"☝",
                     @":point_down:": @"👇",
                     @":point_left:": @"👈",
                     @":point_right:": @"👉",
                     @":raised_hands:": @"🙌",
                     @":pray:": @"🙏",
                     @":point_up_2:": @"👆",
                     @":clap:": @"👏",
                     @":muscle:": @"💪",
                     @":walking:": @"🚶",
                     @":runner:": @"🏃",
                     @":running:": @"🏃",
                     @":couple:": @"👫",
                     @":family:": @"👪",
                     @":two_men_holding_hands:": @"👬",
                     @":two_women_holding_hands:": @"👭",
                     @":dancer:": @"💃",
                     @":dancers:": @"👯",
                     @":ok_woman:": @"🙆",
                     @":no_good:": @"🙅",
                     @":information_desk_person:": @"💁",
                     @":raised_hand:": @"🙋",
                     @":bride_with_veil:": @"👰",
                     @":person_with_pouting_face:": @"🙎",
                     @":person_frowning:": @"🙍",
                     @":bow:": @"🙇",
                     @":couplekiss:": @"💏",
                     @":couple_with_heart:": @"💑",
                     @":massage:": @"💆",
                     @":haircut:": @"💇",
                     @":nail_care:": @"💅",
                     @":boy:": @"👦",
                     @":girl:": @"👧",
                     @":woman:": @"👩",
                     @":man:": @"👨",
                     @":baby:": @"👶",
                     @":older_woman:": @"👵",
                     @":older_man:": @"👴",
                     @":person_with_blond_hair:": @"👱",
                     @":man_with_gua_pi_mao:": @"👲",
                     @":man_with_turban:": @"👳",
                     @":construction_worker:": @"👷",
                     @":cop:": @"👮",
                     @":angel:": @"👼",
                     @":princess:": @"👸",
                     @":smiley_cat:": @"😺",
                     @":smile_cat:": @"😸",
                     @":heart_eyes_cat:": @"😻",
                     @":kissing_cat:": @"😽",
                     @":smirk_cat:": @"😼",
                     @":scream_cat:": @"🙀",
                     @":crying_cat_face:": @"😿",
                     @":joy_cat:": @"😹",
                     @":pouting_cat:": @"😾",
                     @":japanese_ogre:": @"👹",
                     @":japanese_goblin:": @"👺",
                     @":see_no_evil:": @"🙈",
                     @":hear_no_evil:": @"🙉",
                     @":speak_no_evil:": @"🙊",
                     @":guardsman:": @"💂",
                     @":skull:": @"💀",
                     @":feet:": @"👣",
                     @":lips:": @"👄",
                     @":kiss:": @"💋",
                     @":droplet:": @"💧",
                     @":ear:": @"👂",
                     @":eyes:": @"👀",
                     @":nose:": @"👃",
                     @":tongue:": @"👅",
                     @":love_letter:": @"💌",
                     @":bust_in_silhouette:": @"👤",
                     @":busts_in_silhouette:": @"👥",
                     @":speech_balloon:": @"💬",
                     @":thought_balloon:": @"💭",
                     @":sunny:": @"☀",
                     @":umbrella:": @"☔",
                     @":cloud:": @"☁",
                     @":snowflake:": @"❄",
                     @":snowman:": @"⛄",
                     @":zap:": @"⚡",
                     @":cyclone:": @"🌀",
                     @":foggy:": @"🌁",
                     @":ocean:": @"🌊",
                     @":cat:": @"🐱",
                     @":dog:": @"🐶",
                     @":mouse:": @"🐭",
                     @":hamster:": @"🐹",
                     @":rabbit:": @"🐰",
                     @":wolf:": @"🐺",
                     @":frog:": @"🐸",
                     @":tiger:": @"🐯",
                     @":koala:": @"🐨",
                     @":bear:": @"🐻",
                     @":pig:": @"🐷",
                     @":pig_nose:": @"🐽",
                     @":cow:": @"🐮",
                     @":boar:": @"🐗",
                     @":monkey_face:": @"🐵",
                     @":monkey:": @"🐒",
                     @":horse:": @"🐴",
                     @":racehorse:": @"🐎",
                     @":camel:": @"🐫",
                     @":sheep:": @"🐑",
                     @":elephant:": @"🐘",
                     @":panda_face:": @"🐼",
                     @":snake:": @"🐍",
                     @":bird:": @"🐦",
                     @":baby_chick:": @"🐤",
                     @":hatched_chick:": @"🐥",
                     @":hatching_chick:": @"🐣",
                     @":chicken:": @"🐔",
                     @":penguin:": @"🐧",
                     @":turtle:": @"🐢",
                     @":bug:": @"🐛",
                     @":honeybee:": @"🐝",
                     @":ant:": @"🐜",
                     @":beetle:": @"🐞",
                     @":snail:": @"🐌",
                     @":octopus:": @"🐙",
                     @":tropical_fish:": @"🐠",
                     @":fish:": @"🐟",
                     @":whale:": @"🐳",
                     @":whale2:": @"🐋",
                     @":dolphin:": @"🐬",
                     @":cow2:": @"🐄",
                     @":ram:": @"🐏",
                     @":rat:": @"🐀",
                     @":water_buffalo:": @"🐃",
                     @":tiger2:": @"🐅",
                     @":rabbit2:": @"🐇",
                     @":dragon:": @"🐉",
                     @":goat:": @"🐐",
                     @":rooster:": @"🐓",
                     @":dog2:": @"🐕",
                     @":pig2:": @"🐖",
                     @":mouse2:": @"🐁",
                     @":ox:": @"🐂",
                     @":dragon_face:": @"🐲",
                     @":blowfish:": @"🐡",
                     @":crocodile:": @"🐊",
                     @":dromedary_camel:": @"🐪",
                     @":leopard:": @"🐆",
                     @":cat2:": @"🐈",
                     @":poodle:": @"🐩",
                     @":paw_prints:": @"🐾",
                     @":bouquet:": @"💐",
                     @":cherry_blossom:": @"🌸",
                     @":tulip:": @"🌷",
                     @":four_leaf_clover:": @"🍀",
                     @":rose:": @"🌹",
                     @":sunflower:": @"🌻",
                     @":hibiscus:": @"🌺",
                     @":maple_leaf:": @"🍁",
                     @":leaves:": @"🍃",
                     @":fallen_leaf:": @"🍂",
                     @":herb:": @"🌿",
                     @":mushroom:": @"🍄",
                     @":cactus:": @"🌵",
                     @":palm_tree:": @"🌴",
                     @":evergreen_tree:": @"🌲",
                     @":deciduous_tree:": @"🌳",
                     @":chestnut:": @"🌰",
                     @":seedling:": @"🌱",
                     @":blossum:": @"🌼",
                     @":ear_of_rice:": @"🌾",
                     @":shell:": @"🐚",
                     @":globe_with_meridians:": @"🌐",
                     @":sun_with_face:": @"🌞",
                     @":full_moon_with_face:": @"🌝",
                     @":new_moon_with_face:": @"🌚",
                     @":new_moon:": @"🌑",
                     @":waxing_crescent_moon:": @"🌒",
                     @":first_quarter_moon:": @"🌓",
                     @":waxing_gibbous_moon:": @"🌔",
                     @":full_moon:": @"🌕",
                     @":waning_gibbous_moon:": @"🌖",
                     @":last_quarter_moon:": @"🌗",
                     @":waning_crescent_moon:": @"🌘",
                     @":last_quarter_moon_with_face:": @"🌜",
                     @":first_quarter_moon_with_face:": @"🌛",
                     @":moon:": @"🌙",
                     @":earth_africa:": @"🌍",
                     @":earth_americas:": @"🌎",
                     @":earth_asia:": @"🌏",
                     @":volcano:": @"🌋",
                     @":milky_way:": @"🌌",
                     @":partly_sunny:": @"⛅",
                     @":bamboo:": @"🎍",
                     @":gift_heart:": @"💝",
                     @":dolls:": @"🎎",
                     @":school_satchel:": @"🎒",
                     @":mortar_board:": @"🎓",
                     @":flags:": @"🎏",
                     @":fireworks:": @"🎆",
                     @":sparkler:": @"🎇",
                     @":wind_chime:": @"🎐",
                     @":rice_scene:": @"🎑",
                     @":jack_o_lantern:": @"🎃",
                     @":ghost:": @"👻",
                     @":santa:": @"🎅",
                     @":8ball:": @"🎱",
                     @":alarm_clock:": @"⏰",
                     @":apple:": @"🍎",
                     @":art:": @"🎨",
                     @":baby_bottle:": @"🍼",
                     @":balloon:": @"🎈",
                     @":banana:": @"🍌",
                     @":bar_chart:": @"📊",
                     @":baseball:": @"⚾",
                     @":basketball:": @"🏀",
                     @":bath:": @"🛀",
                     @":bathtub:": @"🛁",
                     @":battery:": @"🔋",
                     @":beer:": @"🍺",
                     @":beers:": @"🍻",
                     @":bell:": @"🔔",
                     @":bento:": @"🍱",
                     @":bicyclist:": @"🚴",
                     @":bikini:": @"👙",
                     @":birthday:": @"🎂",
                     @":black_joker:": @"🃏",
                     @":black_nib:": @"✒",
                     @":blue_book:": @"📘",
                     @":bomb:": @"💣",
                     @":bookmark:": @"🔖",
                     @":bookmark_tabs:": @"📑",
                     @":books:": @"📚",
                     @":boot:": @"👢",
                     @":bowling:": @"🎳",
                     @":bread:": @"🍞",
                     @":briefcase:": @"💼",
                     @":bulb:": @"💡",
                     @":cake:": @"🍰",
                     @":calendar:": @"📆",
                     @":calling:": @"📲",
                     @":camera:": @"📷",
                     @":candy:": @"🍬",
                     @":card_index:": @"📇",
                     @":cd:": @"💿",
                     @":chart_with_downwards_trend:": @"📉",
                     @":chart_with_upwards_trend:": @"📈",
                     @":cherries:": @"🍒",
                     @":chocolate_bar:": @"🍫",
                     @":christmas_tree:": @"🎄",
                     @":clapper:": @"🎬",
                     @":clipboard:": @"📋",
                     @":closed_book:": @"📕",
                     @":closed_lock_with_key:": @"🔐",
                     @":closed_umbrella:": @"🌂",
                     @":clubs:": @"♣",
                     @":cocktail:": @"🍸",
                     @":coffee:": @"☕",
                     @":computer:": @"💻",
                     @":confetti_ball:": @"🎊",
                     @":cookie:": @"🍪",
                     @":corn:": @"🌽",
                     @":credit_card:": @"💳",
                     @":crown:": @"👑",
                     @":crystal_ball:": @"🔮",
                     @":curry:": @"🍛",
                     @":custard:": @"🍮",
                     @":dango:": @"🍡",
                     @":dart:": @"🎯",
                     @":date:": @"📅",
                     @":diamonds:": @"♦",
                     @":dollar:": @"💵",
                     @":door:": @"🚪",
                     @":doughnut:": @"🍩",
                     @":dress:": @"👗",
                     @":dvd:": @"📀",
                     @":e-mail:": @"📧",
                     @":egg:": @"🍳",
                     @":eggplant:": @"🍆",
                     @":electric_plug:": @"🔌",
                     @":email:": @"✉",
                     @":envelope:": @"✉",
                     @":euro:": @"💶",
                     @":eyeglasses:": @"👓",
                     @":fax:": @"📠",
                     @":file_folder:": @"📁",
                     @":fish_cake:": @"🍥",
                     @":fishing_pole_and_fish:": @"🎣",
                     @":flashlight:": @"🔦",
                     @":floppy_disk:": @"💾",
                     @":flower_playing_cards:": @"🎴",
                     @":football:": @"🏈",
                     @":fork_and_knife:": @"🍴",
                     @":fried_shrimp:": @"🍤",
                     @":fries:": @"🍟",
                     @":game_die:": @"🎲",
                     @":gem:": @"💎",
                     @":gift:": @"🎁",
                     @":golf:": @"⛳",
                     @":grapes:": @"🍇",
                     @":green_apple:": @"🍏",
                     @":green_book:": @"📗",
                     @":guitar:": @"🎸",
                     @":gun:": @"🔫",
                     @":hamburger:": @"🍔",
                     @":hammer:": @"🔨",
                     @":handbag:": @"👜",
                     @":headphones:": @"🎧",
                     @":hearts:": @"♥️",
                     @":high_brightness:": @"🔆",
                     @":high_heel:": @"👠",
                     @":hocho:": @"🔪",
                     @":honey_pot:": @"🍯",
                     @":horse_racing:": @"🏇",
                     @":hourglass:": @"⌛",
                     @":hourglass_flowing_sand:": @"⏳",
                     @":ice_cream:": @"🍨",
                     @":icecream:": @"🍦",
                     @":inbox_tray:": @"📥",
                     @":incoming_envelope:": @"📨",
                     @":iphone:": @"📱",
                     @":jeans:": @"👖",
                     @":key:": @"🔑",
                     @":kimono:": @"👘",
                     @":ledger:": @"📒",
                     @":lemon:": @"🍋",
                     @":lipstick:": @"💄",
                     @":lock:": @"🔒",
                     @":lock_with_ink_pen:": @"🔏",
                     @":lollipop:": @"🍭",
                     @":loop:": @"➿",
                     @":loudspeaker:": @"📢",
                     @":low_brightness:": @"🔅",
                     @":mag:": @"🔍",
                     @":mag_right:": @"🔎",
                     @":mahjong:": @"🀄",
                     @":mailbox:": @"📫",
                     @":mailbox_closed:": @"📪",
                     @":mailbox_with_mail:": @"📬",
                     @":mailbox_with_no_mail:": @"📭",
                     @":mans_shoe:": @"👞",
                     @":shoe:": @"👞",
                     @":meat_on_bone:": @"🍖",
                     @":mega:": @"📣",
                     @":melon:": @"🍈",
                     @":memo:": @"📝",
                     @":pencil:": @"📝",
                     @":microphone:": @"🎤",
                     @":microscope:": @"🔬",
                     @":minidisc:": @"💽",
                     @":money_with_wings:": @"💸",
                     @":moneybag:": @"💰",
                     @":mountain_bicyclist:": @"🚵",
                     @":movie_camera:": @"🎥",
                     @":musical_keyboard:": @"🎹",
                     @":musical_score:": @"🎼",
                     @":mute:": @"🔇",
                     @":name_badge:": @"📛",
                     @":necktie:": @"👔",
                     @":newspaper:": @"📰",
                     @":no_bell:": @"🔕",
                     @":notebook:": @"📓",
                     @":notebook_with_decorative_cover:": @"📔",
                     @":nut_and_bolt:": @"🔩",
                     @":oden:": @"🍢",
                     @":open_file_folder:": @"📂",
                     @":orange_book:": @"📙",
                     @":outbox_tray:": @"📤",
                     @":page_facing_up:": @"📄",
                     @":page_with_curl:": @"📃",
                     @":pager:": @"📟",
                     @":paperclip:": @"📎",
                     @":peach:": @"🍑",
                     @":pear:": @"🍐",
                     @":pencil2:": @"✏",
                     @":phone:": @"☎",
                     @":telephone:": @"☎",
                     @":pill:": @"💊",
                     @":pineapple:": @"🍍",
                     @":pizza:": @"🍕",
                     @":postal_horn:": @"📯",
                     @":postbox:": @"📮",
                     @":pouch:": @"👝",
                     @":poultry_leg:": @"🍗",
                     @":pound:": @"💷",
                     @":purse:": @"👛",
                     @":pushpin:": @"📌",
                     @":radio:": @"📻",
                     @":ramen:": @"🍜",
                     @":ribbon:": @"🎀",
                     @":rice:": @"🍚",
                     @":rice_ball:": @"🍙",
                     @":rice_cracker:": @"🍘",
                     @":ring:": @"💍",
                     @":rugby_football:": @"🏉",
                     @":running_shirt_with_sash:": @"🎽",
                     @":sake:": @"🍶",
                     @":sandal:": @"👡",
                     @":satellite:": @"📡",
                     @":saxophone:": @"🎷",
                     @":scissors:": @"✂",
                     @":scroll:": @"📜",
                     @":seat:": @"💺",
                     @":shaved_ice:": @"🍧",
                     @":shirt:": @"👕",
                     @":tshirt:": @"👕",
                     @":shower:": @"🚿",
                     @":ski:": @"🎿",
                     @":smoking:": @"🚬",
                     @":snowboarder:": @"🏂",
                     @":soccer:": @"⚽",
                     @":sound:": @"🔉",
                     @":space_invader:": @"👾",
                     @":spades:": @"♠",
                     @":spaghetti:": @"🍝",
                     @":speaker:": @"🔊",
                     @":stew:": @"🍲",
                     @":straight_ruler:": @"📏",
                     @":strawberry:": @"🍓",
                     @":surfer:": @"🏄",
                     @":sushi:": @"🍣",
                     @":sweet_potato:": @"🍠",
                     @":swimmer:": @"🏊",
                     @":syringe:": @"💉",
                     @":tada:": @"🎉",
                     @":tanabata_tree:": @"🎋",
                     @":tangerine:": @"🍊",
                     @":tea:": @"🍵",
                     @":telephone_receiver:": @"📞",
                     @":telescope:": @"🔭",
                     @":tennis:": @"🎾",
                     @":toilet:": @"🚽",
                     @":tomato:": @"🍅",
                     @":tophat:": @"🎩",
                     @":triangular_ruler:": @"📐",
                     @":trophy:": @"🏆",
                     @":tropical_drink:": @"🍹",
                     @":trumpet:": @"🎺",
                     @":tv:": @"📺",
                     @":unlock:": @"🔓",
                     @":vhs:": @"📼",
                     @":video_camera:": @"📹",
                     @":video_game:": @"🎮",
                     @":violin:": @"🎻",
                     @":watch:": @"⌚",
                     @":watermelon:": @"🍉",
                     @":wine_glass:": @"🍷",
                     @":womans_clothes:": @"👚",
                     @":womans_hat:": @"👒",
                     @":wrench:": @"🔧",
                     @":yen:": @"💴",
                     @":aerial_tramway:": @"🚡",
                     @":airplane:": @"✈",
                     @":ambulance:": @"🚑",
                     @":anchor:": @"⚓",
                     @":articulated_lorry:": @"🚛",
                     @":atm:": @"🏧",
                     @":bank:": @"🏦",
                     @":barber:": @"💈",
                     @":beginner:": @"🔰",
                     @":bike:": @"🚲",
                     @":blue_car:": @"🚙",
                     @":boat:": @"⛵",
                     @":sailboat:": @"⛵",
                     @":bridge_at_night:": @"🌉",
                     @":bullettrain_front:": @"🚅",
                     @":bullettrain_side:": @"🚄",
                     @":bus:": @"🚌",
                     @":busstop:": @"🚏",
                     @":car:": @"🚗",
                     @":red_car:": @"🚗",
                     @":carousel_horse:": @"🎠",
                     @":checkered_flag:": @"🏁",
                     @":church:": @"⛪",
                     @":circus_tent:": @"🎪",
                     @":city_sunrise:": @"🌇",
                     @":city_sunset:": @"🌆",
                     @":construction:": @"🚧",
                     @":convenience_store:": @"🏪",
                     @":crossed_flags:": @"🎌",
                     @":department_store:": @"🏬",
                     @":european_castle:": @"🏰",
                     @":european_post_office:": @"🏤",
                     @":factory:": @"🏭",
                     @":ferris_wheel:": @"🎡",
                     @":fire_engine:": @"🚒",
                     @":fountain:": @"⛲",
                     @":fuelpump:": @"⛽",
                     @":helicopter:": @"🚁",
                     @":hospital:": @"🏥",
                     @":hotel:": @"🏨",
                     @":hotsprings:": @"♨",
                     @":house:": @"🏠",
                     @":house_with_garden:": @"🏡",
                     @":japan:": @"🗾",
                     @":japanese_castle:": @"🏯",
                     @":light_rail:": @"🚈",
                     @":love_hotel:": @"🏩",
                     @":minibus:": @"🚐",
                     @":monorail:": @"🚝",
                     @":mount_fuji:": @"🗻",
                     @":mountain_cableway:": @"🚠",
                     @":mountain_railway:": @"🚞",
                     @":moyai:": @"🗿",
                     @":office:": @"🏢",
                     @":oncoming_automobile:": @"🚘",
                     @":oncoming_bus:": @"🚍",
                     @":oncoming_police_car:": @"🚔",
                     @":oncoming_taxi:": @"🚖",
                     @":performing_arts:": @"🎭",
                     @":police_car:": @"🚓",
                     @":post_office:": @"🏣",
                     @":railway_car:": @"🚃",
                     @":train:": @"🚃",
                     @":rainbow:": @"🌈",
                     @":rocket:": @"🚀",
                     @":roller_coaster:": @"🎢",
                     @":rotating_light:": @"🚨",
                     @":round_pushpin:": @"📍",
                     @":rowboat:": @"🚣",
                     @":school:": @"🏫",
                     @":ship:": @"🚢",
                     @":slot_machine:": @"🎰",
                     @":speedboat:": @"🚤",
                     @":stars:": @"🌃",
                     @":station:": @"🚉",
                     @":statue_of_liberty:": @"🗽",
                     @":steam_locomotive:": @"🚂",
                     @":sunrise:": @"🌅",
                     @":sunrise_over_mountains:": @"🌄",
                     @":suspension_railway:": @"🚟",
                     @":taxi:": @"🚕",
                     @":tent:": @"⛺",
                     @":ticket:": @"🎫",
                     @":tokyo_tower:": @"🗼",
                     @":tractor:": @"🚜",
                     @":traffic_light:": @"🚥",
                     @":train2:": @"🚆",
                     @":tram:": @"🚊",
                     @":triangular_flag_on_post:": @"🚩",
                     @":trolleybus:": @"🚎",
                     @":truck:": @"🚚",
                     @":vertical_traffic_light:": @"🚦",
                     @":warning:": @"⚠",
                     @":wedding:": @"💒",
                     @":jp:": @"🇯🇵",
                     @":kr:": @"🇰🇷",
                     @":cn:": @"🇨🇳",
                     @":us:": @"🇺🇸",
                     @":fr:": @"🇫🇷",
                     @":es:": @"🇪🇸",
                     @":it:": @"🇮🇹",
                     @":ru:": @"🇷🇺",
                     @":gb:": @"🇬🇧",
                     @":uk:": @"🇬🇧",
                     @":de:": @"🇩🇪",
                     @":100:": @"💯",
                     @":1234:": @"🔢",
                     @":a:": @"🅰",
                     @":ab:": @"🆎",
                     @":abc:": @"🔤",
                     @":abcd:": @"🔡",
                     @":accept:": @"🉑",
                     @":aquarius:": @"♒",
                     @":aries:": @"♈",
                     @":arrow_backward:": @"◀",
                     @":arrow_double_down:": @"⏬",
                     @":arrow_double_up:": @"⏫",
                     @":arrow_down:": @"⬇",
                     @":arrow_down_small:": @"🔽",
                     @":arrow_forward:": @"▶",
                     @":arrow_heading_down:": @"⤵",
                     @":arrow_heading_up:": @"⤴",
                     @":arrow_left:": @"⬅",
                     @":arrow_lower_left:": @"↙",
                     @":arrow_lower_right:": @"↘",
                     @":arrow_right:": @"➡",
                     @":arrow_right_hook:": @"↪",
                     @":arrow_up:": @"⬆",
                     @":arrow_up_down:": @"↕",
                     @":arrow_up_small:": @"🔼",
                     @":arrow_upper_left:": @"↖",
                     @":arrow_upper_right:": @"↗",
                     @":arrows_clockwise:": @"🔃",
                     @":arrows_counterclockwise:": @"🔄",
                     @":b:": @"🅱",
                     @":baby_symbol:": @"🚼",
                     @":baggage_claim:": @"🛄",
                     @":ballot_box_with_check:": @"☑",
                     @":bangbang:": @"‼",
                     @":black_circle:": @"⚫",
                     @":black_square_button:": @"🔲",
                     @":cancer:": @"♋",
                     @":capital_abcd:": @"🔠",
                     @":capricorn:": @"♑",
                     @":chart:": @"💹",
                     @":children_crossing:": @"🚸",
                     @":cinema:": @"🎦",
                     @":cl:": @"🆑",
                     @":clock1:": @"🕐",
                     @":clock10:": @"🕙",
                     @":clock1030:": @"🕥",
                     @":clock11:": @"🕚",
                     @":clock1130:": @"🕦",
                     @":clock12:": @"🕛",
                     @":clock1230:": @"🕧",
                     @":clock130:": @"🕜",
                     @":clock2:": @"🕑",
                     @":clock230:": @"🕝",
                     @":clock3:": @"🕒",
                     @":clock330:": @"🕞",
                     @":clock4:": @"🕓",
                     @":clock430:": @"🕟",
                     @":clock5:": @"🕔",
                     @":clock530:": @"🕠",
                     @":clock6:": @"🕕",
                     @":clock630:": @"🕡",
                     @":clock7:": @"🕖",
                     @":clock730:": @"🕢",
                     @":clock8:": @"🕗",
                     @":clock830:": @"🕣",
                     @":clock9:": @"🕘",
                     @":clock930:": @"🕤",
                     @":congratulations:": @"㊗",
                     @":cool:": @"🆒",
                     @":copyright:": @"©",
                     @":curly_loop:": @"➰",
                     @":currency_exchange:": @"💱",
                     @":customs:": @"🛃",
                     @":diamond_shape_with_a_dot_inside:": @"💠",
                     @":do_not_litter:": @"🚯",
                     @":eight:": @"8⃣",
                     @":eight_pointed_black_star:": @"✴",
                     @":eight_spoked_asterisk:": @"✳",
                     @":end:": @"🔚",
                     @":fast_forward:": @"⏩",
                     @":five:": @"5⃣",
                     @":four:": @"4⃣",
                     @":free:": @"🆓",
                     @":gemini:": @"♊",
                     @":hash:": @"#⃣",
                     @":heart_decoration:": @"💟",
                     @":heavy_check_mark:": @"✔",
                     @":heavy_division_sign:": @"➗",
                     @":heavy_dollar_sign:": @"💲",
                     @":heavy_minus_sign:": @"➖",
                     @":heavy_multiplication_x:": @"✖",
                     @":heavy_plus_sign:": @"➕",
                     @":id:": @"🆔",
                     @":ideograph_advantage:": @"🉐",
                     @":information_source:": @"ℹ",
                     @":interrobang:": @"⁉",
                     @":keycap_ten:": @"🔟",
                     @":koko:": @"🈁",
                     @":large_blue_circle:": @"🔵",
                     @":large_blue_diamond:": @"🔷",
                     @":large_orange_diamond:": @"🔶",
                     @":left_luggage:": @"🛅",
                     @":left_right_arrow:": @"↔",
                     @":leftwards_arrow_with_hook:": @"↩",
                     @":leo:": @"♌",
                     @":libra:": @"♎",
                     @":link:": @"🔗",
                     @":m:": @"Ⓜ",
                     @":mens:": @"🚹",
                     @":metro:": @"🚇",
                     @":mobile_phone_off:": @"📴",
                     @":negative_squared_cross_mark:": @"❎",
                     @":new:": @"🆕",
                     @":ng:": @"🆖",
                     @":nine:": @"9⃣",
                     @":no_bicycles:": @"🚳",
                     @":no_entry:": @"⛔",
                     @":no_entry_sign:": @"🚫",
                     @":no_mobile_phones:": @"📵",
                     @":no_pedestrians:": @"🚷",
                     @":no_smoking:": @"🚭",
                     @":non-potable_water:": @"🚱",
                     @":o:": @"⭕",
                     @":o2:": @"🅾",
                     @":ok:": @"👌",
                     @":on:": @"🔛",
                     @":one:": @"1⃣",
                     @":ophiuchus:": @"⛎",
                     @":parking:": @"🅿",
                     @":part_alternation_mark:": @"〽",
                     @":passport_control:": @"🛂",
                     @":pisces:": @"♓",
                     @":potable_water:": @"🚰",
                     @":put_litter_in_its_place:": @"🚮",
                     @":radio_button:": @"🔘",
                     @":recycle:": @"♻",
                     @":red_circle:": @"🔴",
                     @":registered:": @"®",
                     @":repeat:": @"🔁",
                     @":repeat_one:": @"🔂",
                     @":restroom:": @"🚻",
                     @":rewind:": @"⏪",
                     @":sa:": @"🈂",
                     @":sagittarius:": @"♐",
                     @":scorpius:": @"♏",
                     @":secret:": @"㊙",
                     @":seven:": @"7⃣",
                     @":signal_strength:": @"📶",
                     @":six:": @"6⃣",
                     @":six_pointed_star:": @"🔯",
                     @":small_blue_diamond:": @"🔹",
                     @":small_orange_diamond:": @"🔸",
                     @":small_red_triangle:": @"🔺",
                     @":small_red_triangle_down:": @"🔻",
                     @":soon:": @"🔜",
                     @":sos:": @"🆘",
                     @":symbols:": @"🔣",
                     @":taurus:": @"♉",
                     @":three:": @"3⃣",
                     @":tm:": @"™",
                     @":top:": @"🔝",
                     @":trident:": @"🔱",
                     @":twisted_rightwards_arrows:": @"🔀",
                     @":two:": @"2⃣",
                     @":u5272:": @"🈹",
                     @":u5408:": @"🈴",
                     @":u55b6:": @"🈺",
                     @":u6307:": @"🈯",
                     @":u6708:": @"🈷",
                     @":u6709:": @"🈶",
                     @":u6e80:": @"🈵",
                     @":u7121:": @"🈚",
                     @":u7533:": @"🈸",
                     @":u7981:": @"🈲",
                     @":u7a7a:": @"🈳",
                     @":underage:": @"🔞",
                     @":up:": @"🆙",
                     @":vibration_mode:": @"📳",
                     @":virgo:": @"♍",
                     @":vs:": @"🆚",
                     @":wavy_dash:": @"〰",
                     @":wc:": @"🚾",
                     @":wheelchair:": @"♿",
                     @":white_check_mark:": @"✅",
                     @":white_circle:": @"⚪",
                     @":white_flower:": @"💮",
                     @":white_square_button:": @"🔳",
                     @":womens:": @"🚺",
                     @":x:": @"❌",
                     @":zero:": @"0⃣",
                     @":-)":@"😊",
                     @":-D":@"😃",
                     @";-)":@"😉",
                     @"XD":@"😆",
                     @";-P":@"😜",
                     @":-p":@"😛",
                     @"8-)":@"😍",
                     @"B-)":@"😎",
                     @"3(":@"😔",
                     @":|":@"😐",
                     @":-(":@"😒",
                     @":_(":@"😭",
                     @":((":@"😩",
                     @":o":@"😨",
                     @"3-)":@"😌",
                     @">(":@"😠",
                     @">((":@"😡",
                     @"O:)":@"😇",
                     @";o":@"😰",
                     @"8|":@"😳",
                     @"8o":@"😲",
                     @":X":@"😷",
                     @":-*":@"😚",
                     @"}:)":@"😈",
                     @"<3":@"❤️",
                     @">((":@"😡",
                     @">((":@"😡",
                     @">((":@"😡"
                     };
        
    });
    
    return replaces;

}

-(NSString *)replaceSmilesToEmoji {
    
    
    __block NSString *text = self;
    
   
    [[NSString emojiReplaceDictionary] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        
            NSRange emojiRange;
        
            NSRange nextRange = NSMakeRange(0, text.length);
        
            while ((emojiRange = [text rangeOfString:key options:0 range:nextRange]).location != NSNotFound) {
                
                NSUInteger length = emojiRange.length;
                
                NSString *c_prev = @"!";
                NSString *c_next = @"!";
                
                
                NSRange r_p = NSMakeRange(MAX(0,(int)emojiRange.location - 1), emojiRange.location == 0 ? 0 : 1);
                NSRange r_n = NSMakeRange(MAX(0,emojiRange.length + emojiRange.location),MIN(1, text.length - (emojiRange.location + emojiRange.length)));
                
                c_prev = [text substringWithRange:r_p];
                
                c_next = [text substringWithRange:r_n];
                
                if([c_prev trim].length == 0 && [c_next trim].length == 0) { //!checkInLinksRange(emojiRange)
                    text = [text stringByReplacingCharactersInRange:emojiRange withString:obj];
                    length = [obj length];
                }
                
                nextRange = NSMakeRange(emojiRange.location + length, text.length - emojiRange.location - length);
                
            }
        
       
    }];
    
    return text;
    
}


//   'D83DDC4D': [27, ':like:'], 'D83DDC4E': [28, ':dislike:'], '261D': [29, ':up:'], '270C': [30, ':v:'], 'D83DDC4C': [31, ':ok:']

-(NSString *)emojiString {
    return [[self getEmojiFromString:YES] componentsJoinedByString:@""];
}

- (NSArray *)getEmojiFromString:(BOOL)checkColor {
    
    __block NSMutableDictionary *temp = [NSMutableDictionary dictionary];

    
    [self enumerateSubstringsInRange: NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         
         const unichar hs = [substring characterAtIndex: 0];
         
         
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                unichar ls = [substring characterAtIndex:1];
                int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 129300) {
                    
                    [temp setObject:substring forKey:@(uc)];
                }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3 || ls == 65039) {
                   [temp setObject:substring forKey:@(ls)];
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 [temp setObject:substring forKey:@(hs)];
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                [temp setObject:substring forKey:@(hs)];
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 [temp setObject:substring forKey:@(hs)];
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 [temp setObject:substring forKey:@(hs)];
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 [temp setObject:substring forKey:@(hs)];
             }
         }
         
//         // surrogate pair
//         if (0xd800 <= hs && hs <= 0xdbff) {
//             const unichar ls = [substring characterAtIndex: 1];
//             const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
//
//             if((0x1d000 <= uc && uc <= 0x1f77f)) {
//                 [temp setObject:substring forKey:@(uc)];
//             }
//
//
//             // non surrogate
//         } else {
//             if((0x2100 <= hs && hs <= 0x26ff)) {
//                 [temp setObject:substring forKey:@(hs)];
//             }
//
//         }
     }];
    
    if(checkColor) {
        NSMutableDictionary *t = [[NSMutableDictionary alloc] init];
        
        [temp enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
           
            NSString *e = [self realEmoji:obj];
            
            [t setObject:e forKey:key];
            
            
            
        }];
        
        return [t allValues];
    }
    
    
    return [temp allValues];
    
}

-(NSString *)realEmoji:(NSString *)raceEmoji {
    
    NSString *e = raceEmoji;
    
    if(raceEmoji.length == 4) {
        NSData *data = [raceEmoji dataUsingEncoding:NSNonLossyASCIIStringEncoding];
        NSString *e = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSArray *s = [e componentsSeparatedByString:@"\\"];
        
        
        
        if(s.count == 5) {
            e = [NSString stringWithFormat:@"\\%@",[[s subarrayWithRange:NSMakeRange(1, 2)] componentsJoinedByString:@"\\"]];
        }
        
        
        data = [e dataUsingEncoding:NSUTF8StringEncoding];
        
        e = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

        return e;
        
    }

    return e;
}

-(NSString *)emojiModifier:(NSString *)emoji {
    
    if(emoji.length == 4) {
        NSData *data = [emoji dataUsingEncoding:NSNonLossyASCIIStringEncoding];
        NSString *e = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSArray *s = [e componentsSeparatedByString:@"\\"];
        
        
        
        if(s.count == 5) {
            e = [NSString stringWithFormat:@"\\%@",[[s subarrayWithRange:NSMakeRange(3, 2)] componentsJoinedByString:@"\\"]];
        }
        
        
        data = [e dataUsingEncoding:NSUTF8StringEncoding];
        
        e = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
        return e;
        
    }
    
    return nil;
}

-(NSString *)emojiWithModifier:(NSString *)modifier emoji:(NSString *)emoji {
    
    
    
    NSData *data = [emoji dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *e = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    e = [NSString stringWithFormat:@"%@%@",e,[[NSString alloc] initWithData:[modifier dataUsingEncoding:NSNonLossyASCIIStringEncoding] encoding:NSUTF8StringEncoding]];
    
    data = [e dataUsingEncoding:NSUTF8StringEncoding];
    
    e = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    return e;
}

static NSTextField *testTextField() {
    static NSTextField *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSTextField alloc] init];
        [instance setBordered:NO];
        [instance setEditable:NO];
        [instance setBezeled:NO];
        [instance setSelectable:NO];
    });
    return instance;
}

- (NSSize) sizeForTextFieldForWidth:(int)width {
    NSTextField *textField = testTextField();
    [textField setStringValue:self];
    NSSize size = [[textField cell] cellSizeForBounds:NSMakeRect(0, 0, width, FLT_MAX)];
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}

- (NSString*)htmlentities {
    // take this string obj and wrap it in a root element to ensure only a single root element exists
//    NSString* string = [NSString stringWithFormat:@"<root>%@</root>", self];
//
//    // add the string to the xml parser
//    NSStringEncoding encoding = string.fastestEncoding;
//    NSData* data = [string dataUsingEncoding:encoding];
//    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
//
//    // parse the content keeping track of any chars found outside tags (this will be the stripped content)
//    NSString_stripHtml_XMLParsee* parsee = [[NSString_stripHtml_XMLParsee alloc] init];
//    parser.delegate = parsee;
//    [parser parse];
//
//    // log any errors encountered while parsing
//    //NSError * error = nil;
//    //if((error = [parser parserError])) {
//    //    MTLog(@"This is a warning only. There was an error parsing the string to strip HTML. This error may be because the string did not contain valid XML, however the result will likely have been decoded correctly anyway.: %@", error);
//    //}
//
//    // any chars found while parsing are the stripped content
//    NSString* strippedString = [parsee getCharsFound];
    
    NSString *strippedString = [self stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    
    strippedString = [strippedString stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    
    // get the raw text out of the parsee after parsing, and return it
    return strippedString;
}

-(BOOL)searchInStringByWordsSeparated:(NSString *)search {
    
    
    NSMutableString *transform = [[[search lowercaseString] trim] mutableCopy];
    CFMutableStringRef bufferRef = (__bridge CFMutableStringRef)transform;
    CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, false);
    
    NSMutableString *transformReverse = [search mutableCopy];
    bufferRef = (__bridge CFMutableStringRef)transformReverse;
    CFStringTransform(bufferRef, NULL, kCFStringTransformLatinCyrillic, true);
    
    
    
    NSArray *compare = @[search,transform,transformReverse];
    
    __block BOOL result = NO;
    
    [compare enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSRange range = [self rangeOfString:obj options:NSCaseInsensitiveSearch];
        
        if(range.location != NSNotFound) {
            
            NSRange acceptRange = NSMakeRange(0, 0);
            
            if(range.location != 0) {
                NSString *s = [self substringWithRange:NSMakeRange(range.location - 1, 1)];
                
                acceptRange = [s rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet] options:NSCaseInsensitiveSearch];
            }
            
            
            if(range.location == 0 || acceptRange.location == NSNotFound) {
                result = YES;
                *stop = YES;
            }
            
        }
        
    }];
    
    
//    NSArray *parts = [self partsOfSearchString];
//
//    [parts enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
//
//        NSString *lowerCaseObj = [obj lowercaseString];
//
//        if([lowerCaseObj hasPrefix:search] || [lowerCaseObj hasPrefix:transform] || [lowerCaseObj hasPrefix:transformReverse]) {
//
//            result = YES;
//            *stop = YES;
//
//        }
//
//
//    }];
    
    return result;
}

-(NSArray *)partsOfSearchString {
    NSArray *separated = [[self trim] componentsSeparatedByString:@" "];
    
    
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    
    [separated enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        
        NSUInteger nextIdx = MIN(idx + 1,separated.count - 1);
        
        __block NSString *c = obj;
        
        [separated enumerateObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(nextIdx, separated.count - (idx + 1))] options:0 usingBlock:^(NSString *part, NSUInteger idx, BOOL *stop) {
            
            c = [NSString stringWithFormat:@"%@ %@",c, part];
            
        }];
        
        [parts addObject:c];
        
    }];
    
    return parts;
}

@end

