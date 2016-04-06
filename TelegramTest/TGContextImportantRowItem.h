//
//  TGContextImportantItem.h
//  Telegram
//
//  Created by keepcoder on 06/04/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TMRowItem.h"

@interface TGContextImportantRowItem : TMRowItem

-(id)initWithObject:(id)object bot:(TLUser *)bot;

@property (nonatomic,strong) NSAttributedString *header;
@end
