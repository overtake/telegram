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
                     // People
                     @":grinning:": @"😀",
                     @":grin:": @"😁",
                     @":joy:": @"😂",
                     @":rofl:": @"🤣",
                     @":smiley:": @"😃",
                     @":smile:": @"😄",
                     @":sweat_smile:": @"😅",
                     @":laughing:": @"😆",
                     @":wink:": @"😉",
                     @":blush:": @"😊",
                     @":yum:": @"😋",
                     @":sunglasses:": @"😎",
                     @":heart_eyes:": @"😍",
                     @":kissing_heart:": @"😘",
                     @":kissing:": @"😗",
                     @":kissing_smiling_eyes:": @"😙",
                     @":kissing_closed_eyes:": @"😚",
                     @":relaxed:": @"☺️",
                     @":slight_smile:": @"🙂",
                     @":hugging:": @"🤗",
                     @":thinking:": @"🤔",
                     @":neutral_face:": @"😐",
                     @":expressionless:": @"😑",
                     @":no_mouth:": @"😶",
                     @":rolling_eyes:": @"🙄",
                     @":smirk:": @"😏",
                     @":persevere:": @"😣",
                     @":disappointed_relieved:": @"😥",
                     @":open_mouth:": @"😮",
                     @":zipper_mouth:": @"🤐",
                     @":hushed:": @"😯",
                     @":sleepy:": @"😪",
                     @":tired_face:": @"😫",
                     @":sleeping:": @"😴",
                     @":relieved:": @"😌",
                     @":nerd:": @"🤓",
                     @":stuck_out_tongue:": @"😛",
                     @":stuck_out_tongue_winking_eye:": @"😜",
                     @":stuck_out_tongue_closed_eyes:": @"😝",
                     @":drooling_face:": @"🤤",
                     @":unamused:": @"😒",
                     @":sweat:": @"😓",
                     @":pensive:": @"😔",
                     @":confused:": @"😕",
                     @":upside_down:": @"🙃",
                     @":money_mouth:": @"🤑",
                     @":astonished:": @"😲",
                     @":frowning2:": @"☹️",
                     @":slight_frown:": @"🙁",
                     @":confounded:": @"😖",
                     @":disappointed:": @"😞",
                     @":worried:": @"😟",
                     @":triumph:": @"😤",
                     @":cry:": @"😢",
                     @":sob:": @"😭",
                     @":frowning:": @"😦",
                     @":anguished:": @"😧",
                     @":fearful:": @"😨",
                     @":weary:": @"😩",
                     @":grimacing:": @"😬",
                     @":cold_sweat:": @"😰",
                     @":scream:": @"😱",
                     @":flushed:": @"😳",
                     @":dizzy_face:": @"😵",
                     @":rage:": @"😡",
                     @":angry:": @"😠",
                     @":innocent:": @"😇",
                     @":cowboy:": @"🤠",
                     @":clown:": @"🤡",
                     @":lying_face:": @"🤥",
                     @":mask:": @"😷",
                     @":thermometer_face:": @"🤒",
                     @":head_bandage:": @"🤕",
                     @":nauseated_face:": @"🤢",
                     @":sneezing_face:": @"🤧",
                     @":smiling_imp:": @"😈",
                     @":imp:": @"👿",
                     @":japanese_ogre:": @"👹",
                     @":japanese_goblin:": @"👺",
                     @":skull:": @"💀",
                     @":ghost:": @"👻",
                     @":alien:": @"👽",
                     @":robot:": @"🤖",
                     @":poop:": @"💩",
                     @":smiley_cat:": @"😺",
                     @":smile_cat:": @"😸",
                     @":joy_cat:": @"😹",
                     @":heart_eyes_cat:": @"😻",
                     @":smirk_cat:": @"😼",
                     @":kissing_cat:": @"😽",
                     @":scream_cat:": @"🙀",
                     @":crying_cat_face:": @"😿",
                     @":pouting_cat:": @"😾",
                     @":boy:": @"👦",
                     @":girl:": @"👧",
                     @":man:": @"👨",
                     @":woman:": @"👩",
                     @":older_man:": @"👴",
                     @":older_woman:": @"👵",
                     @":baby:": @"👶",
                     @":angel:": @"👼",
                     @":cop:": @"👮",
                     @":spy:": @"🕵️",
                     @":guardsman:": @"💂",
                     @":construction_worker:": @"👷",
                     @":man_with_turban:": @"👳",
                     @":person_with_blond_hair:": @"👱",
                     @":santa:": @"🎅",
                     @":mrs_claus:": @"🤶",
                     @":princess:": @"👸",
                     @":prince:": @"🤴",
                     @":bride_with_veil:": @"👰",
                     @":man_in_tuxedo:": @"🤵",
                     @":pregnant_woman:": @"🤰",
                     @":man_with_gua_pi_mao:": @"👲",
                     @":person_frowning:": @"🙍",
                     @":person_with_pouting_face:": @"🙎",
                     @":no_good:": @"🙅",
                     @":ok_woman:": @"🙆",
                     @":information_desk_person:": @"💁",
                     @":raising_hand:": @"🙋",
                     @":bow:": @"🙇",
                     @":face_palm:": @"🤦",
                     @":shrug:": @"🤷",
                     @":massage:": @"💆",
                     @":haircut:": @"💇",
                     @":walking:": @"🚶",
                     @":runner:": @"🏃",
                     @":dancer:": @"💃",
                     @":man_dancing:": @"🕺",
                     @":dancers:": @"👯",
                     @":speaking_head:": @"🗣️",
                     @":bust_in_silhouette:": @"👤",
                     @":busts_in_silhouette:": @"👥",
                     @":couple:": @"👫",
                     @":two_men_holding_hands:": @"👬",
                     @":two_women_holding_hands:": @"👭",
                     @":couplekiss:": @"💏",
                     @":kiss_mm:": @"👨‍❤️‍💋‍👨",
                     @":kiss_ww:": @"👩‍❤️‍💋‍👩",
                     @":couple_with_heart:": @"💑",
                     @":couple_mm:": @"👨‍❤️‍👨",
                     @":couple_ww:": @"👩‍❤️‍👩",
                     @":family:": @"👪",
                     @":family_mwg:": @"👨‍👩‍👧",
                     @":family_mwgb:": @"👨‍👩‍👧‍👦",
                     @":family_mwbb:": @"👨‍👩‍👦‍👦",
                     @":family_mwgg:": @"👨‍👩‍👧‍👧",
                     @":family_mmb:": @"👨‍👨‍👦",
                     @":family_mmg:": @"👨‍👨‍👧",
                     @":family_mmgb:": @"👨‍👨‍👧‍👦",
                     @":family_mmbb:": @"👨‍👨‍👦‍👦",
                     @":family_mmgg:": @"👨‍👨‍👧‍👧",
                     @":family_wwb:": @"👩‍👩‍👦",
                     @":family_wwg:": @"👩‍👩‍👧",
                     @":family_wwgb:": @"👩‍👩‍👧‍👦",
                     @":family_wwbb:": @"👩‍👩‍👦‍👦",
                     @":family_wwgg:": @"👩‍👩‍👧‍👧",
                     @":muscle:": @"💪",
                     @":selfie:": @"🤳",
                     @":point_left:": @"👈",
                     @":point_right:": @"👉",
                     @":point_up:": @"☝️",
                     @":point_up_2:": @"👆",
                     @":middle_finger:": @"🖕",
                     @":point_down:": @"👇",
                     @":v:": @"✌️",
                     @":fingers_crossed:": @"🤞",
                     @":vulcan:": @"🖖",
                     @":metal:": @"🤘",
                     @":call_me:": @"🤙",
                     @":hand_splayed:": @"🖐️",
                     @":raised_hand:": @"✋",
                     @":ok_hand:": @"👌",
                     @":thumbsup:": @"👍",
                     @":thumbsdown:": @"👎",
                     @":fist:": @"✊",
                     @":punch:": @"👊",
                     @":left_facing_fist:": @"🤛",
                     @":right_facing_fist:": @"🤜",
                     @":raised_back_of_hand:": @"🤚",
                     @":wave:": @"👋",
                     @":clap:": @"👏",
                     @":writing_hand:": @"✍️",
                     @":open_hands:": @"👐",
                     @":raised_hands:": @"🙌",
                     @":pray:": @"🙏",
                     @":handshake:": @"🤝",
                     @":nail_care:": @"💅",
                     @":ear:": @"👂",
                     @":nose:": @"👃",
                     @":footprints:": @"👣",
                     @":eyes:": @"👀",
                     @":eye:": @"👁️",
                     @":tongue:": @"👅",
                     @":lips:": @"👄",
                     @":kiss:": @"💋",
                     @":zzz:": @"💤",
                     @":eyeglasses:": @"👓",
                     @":dark_sunglasses:": @"🕶️",
                     @":necktie:": @"👔",
                     @":shirt:": @"👕",
                     @":jeans:": @"👖",
                     @":dress:": @"👗",
                     @":kimono:": @"👘",
                     @":bikini:": @"👙",
                     @":womans_clothes:": @"👚",
                     @":purse:": @"👛",
                     @":handbag:": @"👜",
                     @":pouch:": @"👝",
                     @":school_satchel:": @"🎒",
                     @":mans_shoe:": @"👞",
                     @":athletic_shoe:": @"👟",
                     @":high_heel:": @"👠",
                     @":sandal:": @"👡",
                     @":boot:": @"👢",
                     @":crown:": @"👑",
                     @":womans_hat:": @"👒",
                     @":tophat:": @"🎩",
                     @":mortar_board:": @"🎓",
                     @":helmet_with_cross:": @"⛑️",
                     @":lipstick:": @"💄",
                     @":ring:": @"💍",
                     @":closed_umbrella:": @"🌂",
                     @":briefcase:": @"💼",
                     // Nature
                     @":see_no_evil:": @"🙈",
                     @":hear_no_evil:": @"🙉",
                     @":speak_no_evil:": @"🙊",
                     @":sweat_drops:": @"💦",
                     @":dash:": @"💨",
                     @":monkey_face:": @"🐵",
                     @":monkey:": @"🐒",
                     @":gorilla:": @"🦍",
                     @":dog:": @"🐶",
                     @":dog2:": @"🐕",
                     @":poodle:": @"🐩",
                     @":wolf:": @"🐺",
                     @":fox:": @"🦊",
                     @":cat:": @"🐱",
                     @":cat2:": @"🐈",
                     @":lion_face:": @"🦁",
                     @":tiger:": @"🐯",
                     @":tiger2:": @"🐅",
                     @":leopard:": @"🐆",
                     @":horse:": @"🐴",
                     @":racehorse:": @"🐎",
                     @":deer:": @"🦌",
                     @":unicorn:": @"🦄",
                     @":cow:": @"🐮",
                     @":ox:": @"🐂",
                     @":water_buffalo:": @"🐃",
                     @":cow2:": @"🐄",
                     @":pig:": @"🐷",
                     @":pig2:": @"🐖",
                     @":boar:": @"🐗",
                     @":pig_nose:": @"🐽",
                     @":ram:": @"🐏",
                     @":sheep:": @"🐑",
                     @":goat:": @"🐐",
                     @":dromedary_camel:": @"🐪",
                     @":camel:": @"🐫",
                     @":elephant:": @"🐘",
                     @":rhino:": @"🦏",
                     @":mouse:": @"🐭",
                     @":mouse2:": @"🐁",
                     @":rat:": @"🐀",
                     @":hamster:": @"🐹",
                     @":rabbit:": @"🐰",
                     @":rabbit2:": @"🐇",
                     @":chipmunk:": @"🐿️",
                     @":bat:": @"🦇",
                     @":bear:": @"🐻",
                     @":koala:": @"🐨",
                     @":panda_face:": @"🐼",
                     @":feet:": @"🐾",
                     @":turkey:": @"🦃",
                     @":chicken:": @"🐔",
                     @":rooster:": @"🐓",
                     @":hatching_chick:": @"🐣",
                     @":baby_chick:": @"🐤",
                     @":hatched_chick:": @"🐥",
                     @":bird:": @"🐦",
                     @":penguin:": @"🐧",
                     @":dove:": @"🕊️",
                     @":eagle:": @"🦅",
                     @":duck:": @"🦆",
                     @":owl:": @"🦉",
                     @":frog:": @"🐸",
                     @":crocodile:": @"🐊",
                     @":turtle:": @"🐢",
                     @":lizard:": @"🦎",
                     @":snake:": @"🐍",
                     @":dragon_face:": @"🐲",
                     @":dragon:": @"🐉",
                     @":whale:": @"🐳",
                     @":whale2:": @"🐋",
                     @":dolphin:": @"🐬",
                     @":fish:": @"🐟",
                     @":tropical_fish:": @"🐠",
                     @":blowfish:": @"🐡",
                     @":shark:": @"🦈",
                     @":octopus:": @"🐙",
                     @":shell:": @"🐚",
                     @":crab:": @"🦀",
                     @":shrimp:": @"🦐",
                     @":squid:": @"🦑",
                     @":butterfly:": @"🦋",
                     @":snail:": @"🐌",
                     @":bug:": @"🐛",
                     @":ant:": @"🐜",
                     @":bee:": @"🐝",
                     @":beetle:": @"🐞",
                     @":spider:": @"🕷️",
                     @":spider_web:": @"🕸️",
                     @":scorpion:": @"🦂",
                     @":bouquet:": @"💐",
                     @":cherry_blossom:": @"🌸",
                     @":rosette:": @"🏵️",
                     @":rose:": @"🌹",
                     @":wilted_rose:": @"🥀",
                     @":hibiscus:": @"🌺",
                     @":sunflower:": @"🌻",
                     @":blossom:": @"🌼",
                     @":tulip:": @"🌷",
                     @":seedling:": @"🌱",
                     @":evergreen_tree:": @"🌲",
                     @":deciduous_tree:": @"🌳",
                     @":palm_tree:": @"🌴",
                     @":cactus:": @"🌵",
                     @":ear_of_rice:": @"🌾",
                     @":herb:": @"🌿",
                     @":shamrock:": @"☘️",
                     @":four_leaf_clover:": @"🍀",
                     @":maple_leaf:": @"🍁",
                     @":fallen_leaf:": @"🍂",
                     @":leaves:": @"🍃",
                     @":mushroom:": @"🍄",
                     @":chestnut:": @"🌰",
                     @":earth_africa:": @"🌍",
                     @":earth_americas:": @"🌎",
                     @":earth_asia:": @"🌏",
                     @":new_moon:": @"🌑",
                     @":waxing_crescent_moon:": @"🌒",
                     @":first_quarter_moon:": @"🌓",
                     @":waxing_gibbous_moon:": @"🌔",
                     @":full_moon:": @"🌕",
                     @":waning_gibbous_moon:": @"🌖",
                     @":last_quarter_moon:": @"🌗",
                     @":waning_crescent_moon:": @"🌘",
                     @":crescent_moon:": @"🌙",
                     @":new_moon_with_face:": @"🌚",
                     @":first_quarter_moon_with_face:": @"🌛",
                     @":last_quarter_moon_with_face:": @"🌜",
                     @":sunny:": @"☀️",
                     @":full_moon_with_face:": @"🌝",
                     @":sun_with_face:": @"🌞",
                     @":star:": @"⭐️",
                     @":star2:": @"🌟",
                     @":cloud:": @"☁️",
                     @":partly_sunny:": @"⛅️",
                     @":thunder_cloud_rain:": @"⛈️",
                     @":white_sun_small_cloud:": @"🌤️",
                     @":white_sun_cloud:": @"🌥️",
                     @":white_sun_rain_cloud:": @"🌦️",
                     @":cloud_rain:": @"🌧️",
                     @":cloud_snow:": @"🌨️",
                     @":cloud_lightning:": @"🌩️",
                     @":cloud_tornado:": @"🌪️",
                     @":fog:": @"🌫️",
                     @":wind_blowing_face:": @"🌬️",
                     @":umbrella2:": @"☂️",
                     @":umbrella:": @"☔️",
                     @":zap:": @"⚡️",
                     @":snowflake:": @"❄️",
                     @":snowman2:": @"☃️",
                     @":snowman:": @"⛄️",
                     @":comet:": @"☄️",
                     @":fire:": @"🔥",
                     @":droplet:": @"💧",
                     @":ocean:": @"🌊",
                     @":jack_o_lantern:": @"🎃",
                     @":christmas_tree:": @"🎄",
                     @":sparkles:": @"✨",
                     @":tanabata_tree:": @"🎋",
                     @":bamboo:": @"🎍",
                     // Food
                     @":grapes:": @"🍇",
                     @":melon:": @"🍈",
                     @":watermelon:": @"🍉",
                     @":tangerine:": @"🍊",
                     @":lemon:": @"🍋",
                     @":banana:": @"🍌",
                     @":pineapple:": @"🍍",
                     @":apple:": @"🍎",
                     @":green_apple:": @"🍏",
                     @":pear:": @"🍐",
                     @":peach:": @"🍑",
                     @":cherries:": @"🍒",
                     @":strawberry:": @"🍓",
                     @":kiwi:": @"🥝",
                     @":tomato:": @"🍅",
                     @":avocado:": @"🥑",
                     @":eggplant:": @"🍆",
                     @":potato:": @"🥔",
                     @":carrot:": @"🥕",
                     @":corn:": @"🌽",
                     @":hot_pepper:": @"🌶️",
                     @":cucumber:": @"🥒",
                     @":peanuts:": @"🥜",
                     @":bread:": @"🍞",
                     @":croissant:": @"🥐",
                     @":french_bread:": @"🥖",
                     @":pancakes:": @"🥞",
                     @":cheese:": @"🧀",
                     @":meat_on_bone:": @"🍖",
                     @":poultry_leg:": @"🍗",
                     @":bacon:": @"🥓",
                     @":hamburger:": @"🍔",
                     @":fries:": @"🍟",
                     @":pizza:": @"🍕",
                     @":hotdog:": @"🌭",
                     @":taco:": @"🌮",
                     @":burrito:": @"🌯",
                     @":stuffed_flatbread:": @"🥙",
                     @":egg:": @"🥚",
                     @":cooking:": @"🍳",
                     @":shallow_pan_of_food:": @"🥘",
                     @":stew:": @"🍲",
                     @":salad:": @"🥗",
                     @":popcorn:": @"🍿",
                     @":bento:": @"🍱",
                     @":rice_cracker:": @"🍘",
                     @":rice_ball:": @"🍙",
                     @":rice:": @"🍚",
                     @":curry:": @"🍛",
                     @":ramen:": @"🍜",
                     @":spaghetti:": @"🍝",
                     @":sweet_potato:": @"🍠",
                     @":oden:": @"🍢",
                     @":sushi:": @"🍣",
                     @":fried_shrimp:": @"🍤",
                     @":fish_cake:": @"🍥",
                     @":dango:": @"🍡",
                     @":icecream:": @"🍦",
                     @":shaved_ice:": @"🍧",
                     @":ice_cream:": @"🍨",
                     @":doughnut:": @"🍩",
                     @":cookie:": @"🍪",
                     @":birthday:": @"🎂",
                     @":cake:": @"🍰",
                     @":chocolate_bar:": @"🍫",
                     @":candy:": @"🍬",
                     @":lollipop:": @"🍭",
                     @":custard:": @"🍮",
                     @":honey_pot:": @"🍯",
                     @":baby_bottle:": @"🍼",
                     @":milk:": @"🥛",
                     @":coffee:": @"☕️",
                     @":tea:": @"🍵",
                     @":sake:": @"🍶",
                     @":champagne:": @"🍾",
                     @":wine_glass:": @"🍷",
                     @":cocktail:": @"🍸",
                     @":tropical_drink:": @"🍹",
                     @":beer:": @"🍺",
                     @":beers:": @"🍻",
                     @":champagne_glass:": @"🥂",
                     @":tumbler_glass:": @"🥃",
                     @":fork_knife_plate:": @"🍽️",
                     @":fork_and_knife:": @"🍴",
                     @":spoon:": @"🥄",
                     // Activity
                     @":space_invader:": @"👾",
                     @":levitate:": @"🕴️",
                     @":fencer:": @"🤺",
                     @":horse_racing:": @"🏇",
                     @":skier:": @"⛷️",
                     @":snowboarder:": @"🏂",
                     @":golfer:": @"🏌️",
                     @":surfer:": @"🏄",
                     @":rowboat:": @"🚣",
                     @":swimmer:": @"🏊",
                     @":basketball_player:": @"⛹️",
                     @":lifter:": @"🏋️",
                     @":bicyclist:": @"🚴",
                     @":mountain_bicyclist:": @"🚵",
                     @":cartwheel:": @"🤸",
                     @":wrestlers:": @"🤼",
                     @":water_polo:": @"🤽",
                     @":handball:": @"🤾",
                     @":juggling:": @"🤹",
                     @":circus_tent:": @"🎪",
                     @":performing_arts:": @"🎭",
                     @":art:": @"🎨",
                     @":slot_machine:": @"🎰",
                     @":bath:": @"🛀",
                     @":reminder_ribbon:": @"🎗️",
                     @":tickets:": @"🎟️",
                     @":ticket:": @"🎫",
                     @":military_medal:": @"🎖️",
                     @":trophy:": @"🏆",
                     @":medal:": @"🏅",
                     @":first_place:": @"🥇",
                     @":second_place:": @"🥈",
                     @":third_place:": @"🥉",
                     @":soccer:": @"⚽️",
                     @":baseball:": @"⚾️",
                     @":basketball:": @"🏀",
                     @":volleyball:": @"🏐",
                     @":football:": @"🏈",
                     @":rugby_football:": @"🏉",
                     @":tennis:": @"🎾",
                     @":8ball:": @"🎱",
                     @":bowling:": @"🎳",
                     @":cricket:": @"🏏",
                     @":field_hockey:": @"🏑",
                     @":hockey:": @"🏒",
                     @":ping_pong:": @"🏓",
                     @":badminton:": @"🏸",
                     @":boxing_glove:": @"🥊",
                     @":martial_arts_uniform:": @"🥋",
                     @":goal:": @"🥅",
                     @":dart:": @"🎯",
                     @":golf:": @"⛳️",
                     @":ice_skate:": @"⛸️",
                     @":fishing_pole_and_fish:": @"🎣",
                     @":running_shirt_with_sash:": @"🎽",
                     @":ski:": @"🎿",
                     @":video_game:": @"🎮",
                     @":game_die:": @"🎲",
                     @":musical_score:": @"🎼",
                     @":microphone:": @"🎤",
                     @":headphones:": @"🎧",
                     @":saxophone:": @"🎷",
                     @":guitar:": @"🎸",
                     @":musical_keyboard:": @"🎹",
                     @":trumpet:": @"🎺",
                     @":violin:": @"🎻",
                     @":drum:": @"🥁",
                     @":clapper:": @"🎬",
                     @":bow_and_arrow:": @"🏹",
                     // Travel
                     @":race_car:": @"🏎️",
                     @":motorcycle:": @"🏍️",
                     @":japan:": @"🗾",
                     @":mountain_snow:": @"🏔️",
                     @":mountain:": @"⛰️",
                     @":volcano:": @"🌋",
                     @":mount_fuji:": @"🗻",
                     @":camping:": @"🏕️",
                     @":beach:": @"🏖️",
                     @":desert:": @"🏜️",
                     @":island:": @"🏝️",
                     @":park:": @"🏞️",
                     @":stadium:": @"🏟️",
                     @":classical_building:": @"🏛️",
                     @":construction_site:": @"🏗️",
                     @":homes:": @"🏘️",
                     @":cityscape:": @"🏙️",
                     @":house_abandoned:": @"🏚️",
                     @":house:": @"🏠",
                     @":house_with_garden:": @"🏡",
                     @":office:": @"🏢",
                     @":post_office:": @"🏣",
                     @":european_post_office:": @"🏤",
                     @":hospital:": @"🏥",
                     @":bank:": @"🏦",
                     @":hotel:": @"🏨",
                     @":love_hotel:": @"🏩",
                     @":convenience_store:": @"🏪",
                     @":school:": @"🏫",
                     @":department_store:": @"🏬",
                     @":factory:": @"🏭",
                     @":japanese_castle:": @"🏯",
                     @":european_castle:": @"🏰",
                     @":wedding:": @"💒",
                     @":tokyo_tower:": @"🗼",
                     @":statue_of_liberty:": @"🗽",
                     @":church:": @"⛪️",
                     @":mosque:": @"🕌",
                     @":synagogue:": @"🕍",
                     @":shinto_shrine:": @"⛩️",
                     @":kaaba:": @"🕋",
                     @":fountain:": @"⛲️",
                     @":tent:": @"⛺️",
                     @":foggy:": @"🌁",
                     @":night_with_stars:": @"🌃",
                     @":sunrise_over_mountains:": @"🌄",
                     @":sunrise:": @"🌅",
                     @":city_dusk:": @"🌆",
                     @":city_sunset:": @"🌇",
                     @":bridge_at_night:": @"🌉",
                     @":milky_way:": @"🌌",
                     @":carousel_horse:": @"🎠",
                     @":ferris_wheel:": @"🎡",
                     @":roller_coaster:": @"🎢",
                     @":steam_locomotive:": @"🚂",
                     @":railway_car:": @"🚃",
                     @":bullettrain_side:": @"🚄",
                     @":bullettrain_front:": @"🚅",
                     @":train2:": @"🚆",
                     @":metro:": @"🚇",
                     @":light_rail:": @"🚈",
                     @":station:": @"🚉",
                     @":tram:": @"🚊",
                     @":monorail:": @"🚝",
                     @":mountain_railway:": @"🚞",
                     @":train:": @"🚋",
                     @":bus:": @"🚌",
                     @":oncoming_bus:": @"🚍",
                     @":trolleybus:": @"🚎",
                     @":minibus:": @"🚐",
                     @":ambulance:": @"🚑",
                     @":fire_engine:": @"🚒",
                     @":police_car:": @"🚓",
                     @":oncoming_police_car:": @"🚔",
                     @":taxi:": @"🚕",
                     @":oncoming_taxi:": @"🚖",
                     @":red_car:": @"🚗",
                     @":oncoming_automobile:": @"🚘",
                     @":blue_car:": @"🚙",
                     @":truck:": @"🚚",
                     @":articulated_lorry:": @"🚛",
                     @":tractor:": @"🚜",
                     @":bike:": @"🚲",
                     @":scooter:": @"🛴",
                     @":motor_scooter:": @"🛵",
                     @":busstop:": @"🚏",
                     @":motorway:": @"🛣️",
                     @":railway_track:": @"🛤️",
                     @":fuelpump:": @"⛽️",
                     @":rotating_light:": @"🚨",
                     @":traffic_light:": @"🚥",
                     @":vertical_traffic_light:": @"🚦",
                     @":construction:": @"🚧",
                     @":anchor:": @"⚓️",
                     @":sailboat:": @"⛵️",
                     @":canoe:": @"🛶",
                     @":speedboat:": @"🚤",
                     @":cruise_ship:": @"🛳️",
                     @":ferry:": @"⛴️",
                     @":motorboat:": @"🛥️",
                     @":ship:": @"🚢",
                     @":airplane:": @"✈️",
                     @":airplane_small:": @"🛩️",
                     @":airplane_departure:": @"🛫",
                     @":airplane_arriving:": @"🛬",
                     @":seat:": @"💺",
                     @":helicopter:": @"🚁",
                     @":suspension_railway:": @"🚟",
                     @":mountain_cableway:": @"🚠",
                     @":aerial_tramway:": @"🚡",
                     @":rocket:": @"🚀",
                     @":satellite_orbital:": @"🛰️",
                     @":stars:": @"🌠",
                     @":rainbow:": @"🌈",
                     @":fireworks:": @"🎆",
                     @":sparkler:": @"🎇",
                     @":rice_scene:": @"🎑",
                     @":checkered_flag:": @"🏁",
                     // Objects
                     @":skull_crossbones:": @"☠️",
                     @":love_letter:": @"💌",
                     @":bomb:": @"💣",
                     @":hole:": @"🕳️",
                     @":shopping_bags:": @"🛍️",
                     @":prayer_beads:": @"📿",
                     @":gem:": @"💎",
                     @":knife:": @"🔪",
                     @":amphora:": @"🏺",
                     @":map:": @"🗺️",
                     @":barber:": @"💈",
                     @":frame_photo:": @"🖼️",
                     @":bellhop:": @"🛎️",
                     @":door:": @"🚪",
                     @":sleeping_accommodation:": @"🛌",
                     @":bed:": @"🛏️",
                     @":couch:": @"🛋️",
                     @":toilet:": @"🚽",
                     @":shower:": @"🚿",
                     @":bathtub:": @"🛁",
                     @":hourglass:": @"⌛️",
                     @":hourglass_flowing_sand:": @"⏳",
                     @":watch:": @"⌚️",
                     @":alarm_clock:": @"⏰",
                     @":stopwatch:": @"⏱️",
                     @":timer:": @"⏲️",
                     @":clock:": @"🕰️",
                     @":thermometer:": @"🌡️",
                     @":beach_umbrella:": @"⛱️",
                     @":balloon:": @"🎈",
                     @":tada:": @"🎉",
                     @":confetti_ball:": @"🎊",
                     @":dolls:": @"🎎",
                     @":flags:": @"🎏",
                     @":wind_chime:": @"🎐",
                     @":ribbon:": @"🎀",
                     @":gift:": @"🎁",
                     @":joystick:": @"🕹️",
                     @":postal_horn:": @"📯",
                     @":microphone2:": @"🎙️",
                     @":level_slider:": @"🎚️",
                     @":control_knobs:": @"🎛️",
                     @":radio:": @"📻",
                     @":iphone:": @"📱",
                     @":calling:": @"📲",
                     @":telephone:": @"☎️",
                     @":telephone_receiver:": @"📞",
                     @":pager:": @"📟",
                     @":fax:": @"📠",
                     @":battery:": @"🔋",
                     @":electric_plug:": @"🔌",
                     @":computer:": @"💻",
                     @":desktop:": @"🖥️",
                     @":printer:": @"🖨️",
                     @":keyboard:": @"⌨️",
                     @":mouse_three_button:": @"🖱️",
                     @":trackball:": @"🖲️",
                     @":minidisc:": @"💽",
                     @":floppy_disk:": @"💾",
                     @":cd:": @"💿",
                     @":dvd:": @"📀",
                     @":movie_camera:": @"🎥",
                     @":film_frames:": @"🎞️",
                     @":projector:": @"📽️",
                     @":tv:": @"📺",
                     @":camera:": @"📷",
                     @":camera_with_flash:": @"📸",
                     @":video_camera:": @"📹",
                     @":vhs:": @"📼",
                     @":mag:": @"🔍",
                     @":mag_right:": @"🔎",
                     @":microscope:": @"🔬",
                     @":telescope:": @"🔭",
                     @":satellite:": @"📡",
                     @":candle:": @"🕯️",
                     @":bulb:": @"💡",
                     @":flashlight:": @"🔦",
                     @":izakaya_lantern:": @"🏮",
                     @":notebook_with_decorative_cover:": @"📔",
                     @":closed_book:": @"📕",
                     @":book:": @"📖",
                     @":green_book:": @"📗",
                     @":blue_book:": @"📘",
                     @":orange_book:": @"📙",
                     @":books:": @"📚",
                     @":notebook:": @"📓",
                     @":ledger:": @"📒",
                     @":page_with_curl:": @"📃",
                     @":scroll:": @"📜",
                     @":page_facing_up:": @"📄",
                     @":newspaper:": @"📰",
                     @":newspaper2:": @"🗞️",
                     @":bookmark_tabs:": @"📑",
                     @":bookmark:": @"🔖",
                     @":label:": @"🏷️",
                     @":moneybag:": @"💰",
                     @":yen:": @"💴",
                     @":dollar:": @"💵",
                     @":euro:": @"💶",
                     @":pound:": @"💷",
                     @":money_with_wings:": @"💸",
                     @":credit_card:": @"💳",
                     @":envelope:": @"✉️",
                     @":e-mail:": @"📧",
                     @":incoming_envelope:": @"📨",
                     @":envelope_with_arrow:": @"📩",
                     @":outbox_tray:": @"📤",
                     @":inbox_tray:": @"📥",
                     @":package:": @"📦",
                     @":mailbox:": @"📫",
                     @":mailbox_closed:": @"📪",
                     @":mailbox_with_mail:": @"📬",
                     @":mailbox_with_no_mail:": @"📭",
                     @":postbox:": @"📮",
                     @":ballot_box:": @"🗳️",
                     @":pencil2:": @"✏️",
                     @":black_nib:": @"✒️",
                     @":pen_fountain:": @"🖋️",
                     @":pen_ballpoint:": @"🖊️",
                     @":paintbrush:": @"🖌️",
                     @":crayon:": @"🖍️",
                     @":pencil:": @"📝",
                     @":file_folder:": @"📁",
                     @":open_file_folder:": @"📂",
                     @":dividers:": @"🗂️",
                     @":date:": @"📅",
                     @":calendar:": @"📆",
                     @":notepad_spiral:": @"🗒️",
                     @":calendar_spiral:": @"🗓️",
                     @":card_index:": @"📇",
                     @":chart_with_upwards_trend:": @"📈",
                     @":chart_with_downwards_trend:": @"📉",
                     @":bar_chart:": @"📊",
                     @":clipboard:": @"📋",
                     @":pushpin:": @"📌",
                     @":round_pushpin:": @"📍",
                     @":paperclip:": @"📎",
                     @":paperclips:": @"🖇️",
                     @":straight_ruler:": @"📏",
                     @":triangular_ruler:": @"📐",
                     @":scissors:": @"✂️",
                     @":card_box:": @"🗃️",
                     @":file_cabinet:": @"🗄️",
                     @":wastebasket:": @"🗑️",
                     @":lock:": @"🔒",
                     @":unlock:": @"🔓",
                     @":lock_with_ink_pen:": @"🔏",
                     @":closed_lock_with_key:": @"🔐",
                     @":key:": @"🔑",
                     @":key2:": @"🗝️",
                     @":hammer:": @"🔨",
                     @":pick:": @"⛏️",
                     @":hammer_pick:": @"⚒️",
                     @":tools:": @"🛠️",
                     @":dagger:": @"🗡️",
                     @":crossed_swords:": @"⚔️",
                     @":gun:": @"🔫",
                     @":shield:": @"🛡️",
                     @":wrench:": @"🔧",
                     @":nut_and_bolt:": @"🔩",
                     @":gear:": @"⚙️",
                     @":compression:": @"🗜️",
                     @":alembic:": @"⚗️",
                     @":scales:": @"⚖️",
                     @":link:": @"🔗",
                     @":chains:": @"⛓️",
                     @":syringe:": @"💉",
                     @":pill:": @"💊",
                     @":smoking:": @"🚬",
                     @":coffin:": @"⚰️",
                     @":urn:": @"⚱️",
                     @":moyai:": @"🗿",
                     @":oil:": @"🛢️",
                     @":crystal_ball:": @"🔮",
                     @":shopping_cart:": @"🛒",
                     @":triangular_flag_on_post:": @"🚩",
                     @":crossed_flags:": @"🎌",
                     @":flag_black:": @"🏴",
                     @":flag_white:": @"🏳️",
                     @":rainbow_flag:": @"🏳🌈",
                     // Symbols
                     @":eye_in_speech_bubble:": @"👁‍🗨",
                     @":cupid:": @"💘",
                     @":heart:": @"❤️",
                     @":heartbeat:": @"💓",
                     @":broken_heart:": @"💔",
                     @":two_hearts:": @"💕",
                     @":sparkling_heart:": @"💖",
                     @":heartpulse:": @"💗",
                     @":blue_heart:": @"💙",
                     @":green_heart:": @"💚",
                     @":yellow_heart:": @"💛",
                     @":purple_heart:": @"💜",
                     @":black_heart:": @"🖤",
                     @":gift_heart:": @"💝",
                     @":revolving_hearts:": @"💞",
                     @":heart_decoration:": @"💟",
                     @":heart_exclamation:": @"❣️",
                     @":anger:": @"💢",
                     @":boom:": @"💥",
                     @":dizzy:": @"💫",
                     @":speech_balloon:": @"💬",
                     @":speech_left:": @"🗨️",
                     @":anger_right:": @"🗯️",
                     @":thought_balloon:": @"💭",
                     @":white_flower:": @"💮",
                     @":globe_with_meridians:": @"🌐",
                     @":hotsprings:": @"♨️",
                     @":octagonal_sign:": @"🛑",
                     @":clock12:": @"🕛",
                     @":clock1230:": @"🕧",
                     @":clock1:": @"🕐",
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
                     @":clock10:": @"🕙",
                     @":clock1030:": @"🕥",
                     @":clock11:": @"🕚",
                     @":clock1130:": @"🕦",
                     @":cyclone:": @"🌀",
                     @":spades:": @"♠️",
                     @":hearts:": @"♥️",
                     @":diamonds:": @"♦️",
                     @":clubs:": @"♣️",
                     @":black_joker:": @"🃏",
                     @":mahjong:": @"🀄️",
                     @":flower_playing_cards:": @"🎴",
                     @":mute:": @"🔇",
                     @":speaker:": @"🔈",
                     @":sound:": @"🔉",
                     @":loud_sound:": @"🔊",
                     @":loudspeaker:": @"📢",
                     @":mega:": @"📣",
                     @":bell:": @"🔔",
                     @":no_bell:": @"🔕",
                     @":musical_note:": @"🎵",
                     @":notes:": @"🎶",
                     @":chart:": @"💹",
                     @":currency_exchange:": @"💱",
                     @":heavy_dollar_sign:": @"💲",
                     @":atm:": @"🏧",
                     @":put_litter_in_its_place:": @"🚮",
                     @":potable_water:": @"🚰",
                     @":wheelchair:": @"♿️",
                     @":mens:": @"🚹",
                     @":womens:": @"🚺",
                     @":restroom:": @"🚻",
                     @":baby_symbol:": @"🚼",
                     @":wc:": @"🚾",
                     @":passport_control:": @"🛂",
                     @":customs:": @"🛃",
                     @":baggage_claim:": @"🛄",
                     @":left_luggage:": @"🛅",
                     @":warning:": @"⚠️",
                     @":children_crossing:": @"🚸",
                     @":no_entry:": @"⛔️",
                     @":no_entry_sign:": @"🚫",
                     @":no_bicycles:": @"🚳",
                     @":no_smoking:": @"🚭",
                     @":do_not_litter:": @"🚯",
                     @":non-potable_water:": @"🚱",
                     @":no_pedestrians:": @"🚷",
                     @":no_mobile_phones:": @"📵",
                     @":underage:": @"🔞",
                     @":radioactive:": @"☢️",
                     @":biohazard:": @"☣️",
                     @":arrow_up:": @"⬆️",
                     @":arrow_upper_right:": @"↗️",
                     @":arrow_right:": @"➡️",
                     @":arrow_lower_right:": @"↘️",
                     @":arrow_down:": @"⬇️",
                     @":arrow_lower_left:": @"↙️",
                     @":arrow_left:": @"⬅️",
                     @":arrow_upper_left:": @"↖️",
                     @":arrow_up_down:": @"↕️",
                     @":left_right_arrow:": @"↔️",
                     @":leftwards_arrow_with_hook:": @"↩️",
                     @":arrow_right_hook:": @"↪️",
                     @":arrow_heading_up:": @"⤴️",
                     @":arrow_heading_down:": @"⤵️",
                     @":arrows_clockwise:": @"🔃",
                     @":arrows_counterclockwise:": @"🔄",
                     @":back:": @"🔙",
                     @":end:": @"🔚",
                     @":on:": @"🔛",
                     @":soon:": @"🔜",
                     @":top:": @"🔝",
                     @":place_of_worship:": @"🛐",
                     @":atom:": @"⚛️",
                     @":om_symbol:": @"🕉️",
                     @":star_of_david:": @"✡️",
                     @":wheel_of_dharma:": @"☸️",
                     @":yin_yang:": @"☯️",
                     @":cross:": @"✝️",
                     @":orthodox_cross:": @"☦️",
                     @":star_and_crescent:": @"☪️",
                     @":peace:": @"☮️",
                     @":menorah:": @"🕎",
                     @":six_pointed_star:": @"🔯",
                     @":aries:": @"♈️",
                     @":taurus:": @"♉️",
                     @":gemini:": @"♊️",
                     @":cancer:": @"♋️",
                     @":leo:": @"♌️",
                     @":virgo:": @"♍️",
                     @":libra:": @"♎️",
                     @":scorpius:": @"♏️",
                     @":sagittarius:": @"♐️",
                     @":capricorn:": @"♑️",
                     @":aquarius:": @"♒️",
                     @":pisces:": @"♓️",
                     @":ophiuchus:": @"⛎",
                     @":twisted_rightwards_arrows:": @"🔀",
                     @":repeat:": @"🔁",
                     @":repeat_one:": @"🔂",
                     @":arrow_forward:": @"▶️",
                     @":fast_forward:": @"⏩",
                     @":track_next:": @"⏭️",
                     @":play_pause:": @"⏯️",
                     @":arrow_backward:": @"◀️",
                     @":rewind:": @"⏪",
                     @":track_previous:": @"⏮️",
                     @":arrow_up_small:": @"🔼",
                     @":arrow_double_up:": @"⏫",
                     @":arrow_down_small:": @"🔽",
                     @":arrow_double_down:": @"⏬",
                     @":pause_button:": @"⏸️",
                     @":stop_button:": @"⏹️",
                     @":record_button:": @"⏺️",
                     @":eject:": @"⏏️",
                     @":cinema:": @"🎦",
                     @":low_brightness:": @"🔅",
                     @":high_brightness:": @"🔆",
                     @":signal_strength:": @"📶",
                     @":vibration_mode:": @"📳",
                     @":mobile_phone_off:": @"📴",
                     @":recycle:": @"♻️",
                     @":name_badge:": @"📛",
                     @":fleur-de-lis:": @"⚜️",
                     @":beginner:": @"🔰",
                     @":trident:": @"🔱",
                     @":o:": @"⭕️",
                     @":white_check_mark:": @"✅",
                     @":ballot_box_with_check:": @"☑️",
                     @":heavy_check_mark:": @"✔️",
                     @":heavy_multiplication_x:": @"✖️",
                     @":x:": @"❌",
                     @":negative_squared_cross_mark:": @"❎",
                     @":heavy_plus_sign:": @"➕",
                     @":heavy_minus_sign:": @"➖",
                     @":heavy_division_sign:": @"➗",
                     @":curly_loop:": @"➰",
                     @":loop:": @"➿",
                     @":part_alternation_mark:": @"〽️",
                     @":eight_spoked_asterisk:": @"✳️",
                     @":eight_pointed_black_star:": @"✴️",
                     @":sparkle:": @"❇️",
                     @":bangbang:": @"‼️",
                     @":interrobang:": @"⁉️",
                     @":question:": @"❓",
                     @":grey_question:": @"❔",
                     @":grey_exclamation:": @"❕",
                     @":exclamation:": @"❗️",
                     @":wavy_dash:": @"〰️",
                     @":copyright:": @"©️",
                     @":registered:": @"®️",
                     @":tm:": @"™️",
                     @":hash:": @"#️⃣",
                     @":asterisk:": @"*️⃣",
                     @":zero:": @"0️⃣",
                     @":one:": @"1️⃣",
                     @":two:": @"2️⃣",
                     @":three:": @"3️⃣",
                     @":four:": @"4️⃣",
                     @":five:": @"5️⃣",
                     @":six:": @"6️⃣",
                     @":seven:": @"7️⃣",
                     @":eight:": @"8️⃣",
                     @":nine:": @"9️⃣",
                     @":keycap_ten:": @"🔟",
                     @":100:": @"💯",
                     @":capital_abcd:": @"🔠",
                     @":abcd:": @"🔡",
                     @":1234:": @"🔢",
                     @":symbols:": @"🔣",
                     @":abc:": @"🔤",
                     @":a:": @"🅰",
                     @":ab:": @"🆎",
                     @":b:": @"🅱",
                     @":cl:": @"🆑",
                     @":cool:": @"🆒",
                     @":free:": @"🆓",
                     @":information_source:": @"ℹ️",
                     @":id:": @"🆔",
                     @":m:": @"Ⓜ️",
                     @":new:": @"🆕",
                     @":ng:": @"🆖",
                     @":o2:": @"🅾",
                     @":ok:": @"🆗",
                     @":parking:": @"🅿️",
                     @":sos:": @"🆘",
                     @":up:": @"🆙",
                     @":vs:": @"🆚",
                     @":koko:": @"🈁",
                     @":sa:": @"🈂️",
                     @":u6708:": @"🈷️",
                     @":u6709:": @"🈶",
                     @":u6307:": @"🈯️",
                     @":ideograph_advantage:": @"🉐",
                     @":u5272:": @"🈹",
                     @":u7121:": @"🈚️",
                     @":u7981:": @"🈲",
                     @":accept:": @"🉑",
                     @":u7533:": @"🈸",
                     @":u5408:": @"🈴",
                     @":u7a7a:": @"🈳",
                     @":congratulations:": @"㊗️",
                     @":secret:": @"㊙️",
                     @":u55b6:": @"🈺",
                     @":u6e80:": @"🈵",
                     @":black_small_square:": @"▪️",
                     @":white_small_square:": @"▫️",
                     @":white_medium_square:": @"◻️",
                     @":black_medium_square:": @"◼️",
                     @":white_medium_small_square:": @"◽️",
                     @":black_medium_small_square:": @"◾️",
                     @":black_large_square:": @"⬛️",
                     @":white_large_square:": @"⬜️",
                     @":large_orange_diamond:": @"🔶",
                     @":large_blue_diamond:": @"🔷",
                     @":small_orange_diamond:": @"🔸",
                     @":small_blue_diamond:": @"🔹",
                     @":small_red_triangle:": @"🔺",
                     @":small_red_triangle_down:": @"🔻",
                     @":diamond_shape_with_a_dot_inside:": @"💠",
                     @":radio_button:": @"🔘",
                     @":black_square_button:": @"🔲",
                     @":white_square_button:": @"🔳",
                     @":white_circle:": @"⚪️",
                     @":black_circle:": @"⚫️",
                     @":red_circle:": @"🔴",
                     @":blue_circle:": @"🔵",
                     // Flags
                     @":flag_ac:": @"🇦🇨",
                     @":flag_ad:": @"🇦🇩",
                     @":flag_ae:": @"🇦🇪",
                     @":flag_af:": @"🇦🇫",
                     @":flag_ag:": @"🇦🇬",
                     @":flag_ai:": @"🇦🇮",
                     @":flag_al:": @"🇦🇱",
                     @":flag_am:": @"🇦🇲",
                     @":flag_ao:": @"🇦🇴",
                     @":flag_aq:": @"🇦🇶",
                     @":flag_ar:": @"🇦🇷",
                     @":flag_as:": @"🇦🇸",
                     @":flag_at:": @"🇦🇹",
                     @":flag_au:": @"🇦🇺",
                     @":flag_aw:": @"🇦🇼",
                     @":flag_ax:": @"🇦🇽",
                     @":flag_az:": @"🇦🇿",
                     @":flag_ba:": @"🇧🇦",
                     @":flag_bb:": @"🇧🇧",
                     @":flag_bd:": @"🇧🇩",
                     @":flag_be:": @"🇧🇪",
                     @":flag_bf:": @"🇧🇫",
                     @":flag_bg:": @"🇧🇬",
                     @":flag_bh:": @"🇧🇭",
                     @":flag_bi:": @"🇧🇮",
                     @":flag_bj:": @"🇧🇯",
                     @":flag_bl:": @"🇧🇱",
                     @":flag_bm:": @"🇧🇲",
                     @":flag_bn:": @"🇧🇳",
                     @":flag_bo:": @"🇧🇴",
                     @":flag_bq:": @"🇧🇶",
                     @":flag_br:": @"🇧🇷",
                     @":flag_bs:": @"🇧🇸",
                     @":flag_bt:": @"🇧🇹",
                     @":flag_bv:": @"🇧🇻",
                     @":flag_bw:": @"🇧🇼",
                     @":flag_by:": @"🇧🇾",
                     @":flag_bz:": @"🇧🇿",
                     @":flag_ca:": @"🇨🇦",
                     @":flag_cc:": @"🇨🇨",
                     @":flag_cd:": @"🇨🇩",
                     @":flag_cf:": @"🇨🇫",
                     @":flag_cg:": @"🇨🇬",
                     @":flag_ch:": @"🇨🇭",
                     @":flag_ci:": @"🇨🇮",
                     @":flag_ck:": @"🇨🇰",
                     @":flag_cl:": @"🇨🇱",
                     @":flag_cm:": @"🇨🇲",
                     @":flag_cn:": @"🇨🇳",
                     @":flag_co:": @"🇨🇴",
                     @":flag_cp:": @"🇨🇵",
                     @":flag_cr:": @"🇨🇷",
                     @":flag_cu:": @"🇨🇺",
                     @":flag_cv:": @"🇨🇻",
                     @":flag_cw:": @"🇨🇼",
                     @":flag_cx:": @"🇨🇽",
                     @":flag_cy:": @"🇨🇾",
                     @":flag_cz:": @"🇨🇿",
                     @":flag_de:": @"🇩🇪",
                     @":flag_dg:": @"🇩🇬",
                     @":flag_dj:": @"🇩🇯",
                     @":flag_dk:": @"🇩🇰",
                     @":flag_dm:": @"🇩🇲",
                     @":flag_do:": @"🇩🇴",
                     @":flag_dz:": @"🇩🇿",
                     @":flag_ea:": @"🇪🇦",
                     @":flag_ec:": @"🇪🇨",
                     @":flag_ee:": @"🇪🇪",
                     @":flag_eg:": @"🇪🇬",
                     @":flag_eh:": @"🇪🇭",
                     @":flag_er:": @"🇪🇷",
                     @":flag_es:": @"🇪🇸",
                     @":flag_et:": @"🇪🇹",
                     @":flag_eu:": @"🇪🇺",
                     @":flag_fi:": @"🇫🇮",
                     @":flag_fj:": @"🇫🇯",
                     @":flag_fk:": @"🇫🇰",
                     @":flag_fm:": @"🇫🇲",
                     @":flag_fo:": @"🇫🇴",
                     @":flag_fr:": @"🇫🇷",
                     @":flag_ga:": @"🇬🇦",
                     @":flag_gb:": @"🇬🇧",
                     @":flag_gd:": @"🇬🇩",
                     @":flag_ge:": @"🇬🇪",
                     @":flag_gf:": @"🇬🇫",
                     @":flag_gg:": @"🇬🇬",
                     @":flag_gh:": @"🇬🇭",
                     @":flag_gi:": @"🇬🇮",
                     @":flag_gl:": @"🇬🇱",
                     @":flag_gm:": @"🇬🇲",
                     @":flag_gn:": @"🇬🇳",
                     @":flag_gp:": @"🇬🇵",
                     @":flag_gq:": @"🇬🇶",
                     @":flag_gr:": @"🇬🇷",
                     @":flag_gs:": @"🇬🇸",
                     @":flag_gt:": @"🇬🇹",
                     @":flag_gu:": @"🇬🇺",
                     @":flag_gw:": @"🇬🇼",
                     @":flag_gy:": @"🇬🇾",
                     @":flag_hk:": @"🇭🇰",
                     @":flag_hm:": @"🇭🇲",
                     @":flag_hn:": @"🇭🇳",
                     @":flag_hr:": @"🇭🇷",
                     @":flag_ht:": @"🇭🇹",
                     @":flag_hu:": @"🇭🇺",
                     @":flag_ic:": @"🇮🇨",
                     @":flag_id:": @"🇮🇩",
                     @":flag_ie:": @"🇮🇪",
                     @":flag_il:": @"🇮🇱",
                     @":flag_im:": @"🇮🇲",
                     @":flag_in:": @"🇮🇳",
                     @":flag_io:": @"🇮🇴",
                     @":flag_iq:": @"🇮🇶",
                     @":flag_ir:": @"🇮🇷",
                     @":flag_is:": @"🇮🇸",
                     @":flag_it:": @"🇮🇹",
                     @":flag_je:": @"🇯🇪",
                     @":flag_jm:": @"🇯🇲",
                     @":flag_jo:": @"🇯🇴",
                     @":flag_jp:": @"🇯🇵",
                     @":flag_ke:": @"🇰🇪",
                     @":flag_kg:": @"🇰🇬",
                     @":flag_kh:": @"🇰🇭",
                     @":flag_ki:": @"🇰🇮",
                     @":flag_km:": @"🇰🇲",
                     @":flag_kn:": @"🇰🇳",
                     @":flag_kp:": @"🇰🇵",
                     @":flag_kr:": @"🇰🇷",
                     @":flag_kw:": @"🇰🇼",
                     @":flag_ky:": @"🇰🇾",
                     @":flag_kz:": @"🇰🇿",
                     @":flag_la:": @"🇱🇦",
                     @":flag_lb:": @"🇱🇧",
                     @":flag_lc:": @"🇱🇨",
                     @":flag_li:": @"🇱🇮",
                     @":flag_lk:": @"🇱🇰",
                     @":flag_lr:": @"🇱🇷",
                     @":flag_ls:": @"🇱🇸",
                     @":flag_lt:": @"🇱🇹",
                     @":flag_lu:": @"🇱🇺",
                     @":flag_lv:": @"🇱🇻",
                     @":flag_ly:": @"🇱🇾",
                     @":flag_ma:": @"🇲🇦",
                     @":flag_mc:": @"🇲🇨",
                     @":flag_md:": @"🇲🇩",
                     @":flag_me:": @"🇲🇪",
                     @":flag_mf:": @"🇲🇫",
                     @":flag_mg:": @"🇲🇬",
                     @":flag_mh:": @"🇲🇭",
                     @":flag_mk:": @"🇲🇰",
                     @":flag_ml:": @"🇲🇱",
                     @":flag_mm:": @"🇲🇲",
                     @":flag_mn:": @"🇲🇳",
                     @":flag_mo:": @"🇲🇴",
                     @":flag_mp:": @"🇲🇵",
                     @":flag_mq:": @"🇲🇶",
                     @":flag_mr:": @"🇲🇷",
                     @":flag_ms:": @"🇲🇸",
                     @":flag_mt:": @"🇲🇹",
                     @":flag_mu:": @"🇲🇺",
                     @":flag_mv:": @"🇲🇻",
                     @":flag_mw:": @"🇲🇼",
                     @":flag_mx:": @"🇲🇽",
                     @":flag_my:": @"🇲🇾",
                     @":flag_mz:": @"🇲🇿",
                     @":flag_na:": @"🇳🇦",
                     @":flag_nc:": @"🇳🇨",
                     @":flag_ne:": @"🇳🇪",
                     @":flag_nf:": @"🇳🇫",
                     @":flag_ng:": @"🇳🇬",
                     @":flag_ni:": @"🇳🇮",
                     @":flag_nl:": @"🇳🇱",
                     @":flag_no:": @"🇳🇴",
                     @":flag_np:": @"🇳🇵",
                     @":flag_nr:": @"🇳🇷",
                     @":flag_nu:": @"🇳🇺",
                     @":flag_nz:": @"🇳🇿",
                     @":flag_om:": @"🇴🇲",
                     @":flag_pa:": @"🇵🇦",
                     @":flag_pe:": @"🇵🇪",
                     @":flag_pf:": @"🇵🇫",
                     @":flag_pg:": @"🇵🇬",
                     @":flag_ph:": @"🇵🇭",
                     @":flag_pk:": @"🇵🇰",
                     @":flag_pl:": @"🇵🇱",
                     @":flag_pm:": @"🇵🇲",
                     @":flag_pn:": @"🇵🇳",
                     @":flag_pr:": @"🇵🇷",
                     @":flag_ps:": @"🇵🇸",
                     @":flag_pt:": @"🇵🇹",
                     @":flag_pw:": @"🇵🇼",
                     @":flag_py:": @"🇵🇾",
                     @":flag_qa:": @"🇶🇦",
                     @":flag_re:": @"🇷🇪",
                     @":flag_ro:": @"🇷🇴",
                     @":flag_rs:": @"🇷🇸",
                     @":flag_ru:": @"🇷🇺",
                     @":flag_rw:": @"🇷🇼",
                     @":flag_sa:": @"🇸🇦",
                     @":flag_sb:": @"🇸🇧",
                     @":flag_sc:": @"🇸🇨",
                     @":flag_sd:": @"🇸🇩",
                     @":flag_se:": @"🇸🇪",
                     @":flag_sg:": @"🇸🇬",
                     @":flag_sh:": @"🇸🇭",
                     @":flag_si:": @"🇸🇮",
                     @":flag_sj:": @"🇸🇯",
                     @":flag_sk:": @"🇸🇰",
                     @":flag_sl:": @"🇸🇱",
                     @":flag_sm:": @"🇸🇲",
                     @":flag_sn:": @"🇸🇳",
                     @":flag_so:": @"🇸🇴",
                     @":flag_sr:": @"🇸🇷",
                     @":flag_ss:": @"🇸🇸",
                     @":flag_st:": @"🇸🇹",
                     @":flag_sv:": @"🇸🇻",
                     @":flag_sx:": @"🇸🇽",
                     @":flag_sy:": @"🇸🇾",
                     @":flag_sz:": @"🇸🇿",
                     @":flag_ta:": @"🇹🇦",
                     @":flag_tc:": @"🇹🇨",
                     @":flag_td:": @"🇹🇩",
                     @":flag_tf:": @"🇹🇫",
                     @":flag_tg:": @"🇹🇬",
                     @":flag_th:": @"🇹🇭",
                     @":flag_tj:": @"🇹🇯",
                     @":flag_tk:": @"🇹🇰",
                     @":flag_tl:": @"🇹🇱",
                     @":flag_tm:": @"🇹🇲",
                     @":flag_tn:": @"🇹🇳",
                     @":flag_to:": @"🇹🇴",
                     @":flag_tr:": @"🇹🇷",
                     @":flag_tt:": @"🇹🇹",
                     @":flag_tv:": @"🇹🇻",
                     @":flag_tw:": @"🇹🇼",
                     @":flag_tz:": @"🇹🇿",
                     @":flag_ua:": @"🇺🇦",
                     @":flag_ug:": @"🇺🇬",
                     @":flag_um:": @"🇺🇲",
                     @":flag_us:": @"🇺🇸",
                     @":flag_uy:": @"🇺🇾",
                     @":flag_uz:": @"🇺🇿",
                     @":flag_va:": @"🇻🇦",
                     @":flag_vc:": @"🇻🇨",
                     @":flag_ve:": @"🇻🇪",
                     @":flag_vg:": @"🇻🇬",
                     @":flag_vi:": @"🇻🇮",
                     @":flag_vn:": @"🇻🇳",
                     @":flag_vu:": @"🇻🇺",
                     @":flag_wf:": @"🇼🇫",
                     @":flag_ws:": @"🇼🇸",
                     @":flag_xk:": @"🇽🇰",
                     @":flag_ye:": @"🇾🇪",
                     @":flag_yt:": @"🇾🇹",
                     @":flag_za:": @"🇿🇦",
                     @":flag_zm:": @"🇿🇲",
                     @":flag_zw:": @"🇿🇼",

                     // Custom aliases - These aliases exist in the legacy versions and
                     // the non-conflicting ones are kept here for backward compatibility
                     @":hm:": @"🤔",
                     @":satisfied:": @"😌",
                     @":collision:": @"💥",
                     @":shit:": @"💩",
                     @":+1:": @"👍",
                     @":-1:": @"👎",
                     @":ok:": @"👌",
                     @":facepunch:": @"👊",
                     @":hand:": @"✋",
                     @":running:": @"🏃",
                     @":honeybee:": @"🐝",
                     @":paw_prints:": @"🐾",
                     @":moon:": @"🌙",
                     @":hocho:": @"🔪",
                     @":shoe:": @"👞",
                     @":tshirt:": @"👕",
                     @":city_sunrise:": @"🌇",
                     @":city_sunset:": @"🌆",
                     @":flag_uk:": @"🇬🇧",

                     // Custom emoticon-to-emoji conversion
                     // Note: Do not define two char shortcuts with the second char 
                     // being a lower case letter of the alphabet, such as :p or :x
                     // or else user will not be able to use emojis starting with p or x!
                     @":)": @"🙂",
                     @":-)": @"🙂",
                     @"(:": @"🙂",
                     @":D": @"😄",
                     @":-D": @"😄",
                     @"=D": @"😃",
                     @"=-D": @"😃",
                     @":')": @"😂",
                     @":'-)": @"😂",
                     @":*)": @"😊",
                     @";)": @"😉",
                     @";-)": @"😉",
                     @":>": @"😆",
                     @":->": @"😆",
                     @"XD": @"😆",
                     @"O:)": @"😇",
                     @"3-)": @"😌",
                     @":P": @"😛",
                     @":-P": @"😛",
                     @";P": @"😜",
                     @";-P": @"😜",
                     @"8)": @"😍",
                     @":*": @"😚",
                     @":-*": @"😚",
                     @"B)": @"😎",
                     @"B-)": @"😎",
                     @":J": @"😏",
                     @":-J": @"😏",
                     @"3(": @"😔",
                     @":|": @"😐",
                     @":(": @"🙁",
                     @":-(": @"🙁",
                     @":'(": @"😢",
                     @":/": @"😕",
                     @":-/": @"😕",
                     @":\\": @"😕",
                     @":-\\": @"😕",
                     @"D:": @"😧",
                     @":O": @"😮",
                     @":-O": @"😮",
                     @">:(": @"😠",
                     @">:-(": @"😠",
                     @";o": @"😰",
                     @";-o": @"😰",
                     @":$": @"😳",
                     @":-$": @"😳",
                     @"8o": @"😲",
                     @"8-o": @"😲",
                     @":X": @"😷",
                     @":-X": @"😷",
                     @"%)": @"😵",
                     @"%-)": @"😵",
                     @"}:)": @"😈",
                     @"}:-)": @"😈",
                     @"<3": @"❤️",
                     @"</3": @"💔",
                     @"<_<": @"🌝",
                     @">_>": @"🌚",
                     @"9_9": @"🙄",
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

