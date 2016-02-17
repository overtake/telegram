//
//  TGContextBotsPanelView.h
//  Telegram
//
//  Created by keepcoder on 15/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TMView.h"

@interface TGContextBotsPanelView : TMView


-(void)initializeContextBotWithUser:(TLInputUser *)user contextRequestString:(NSString *)requestString;

@end
