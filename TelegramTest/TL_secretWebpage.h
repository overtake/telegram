//
//  TL_secretWebpage.h
//  Telegram
//
//  Created by keepcoder on 27/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "MTProto.h"

@interface TL_secretWebpage : TLWebPage


+(TL_secretWebpage *)createWithUrl:(NSString *)url date:(int)date;

@end
