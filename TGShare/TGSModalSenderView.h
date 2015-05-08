//
//  TGSModalSenderView.h
//  Telegram
//
//  Created by keepcoder on 07.05.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMView.h"
#import "TGS_ConversationRowItem.h"
@interface TGSModalSenderView : TMView


-(void)sendItems:(NSArray *)shareItems rowItems:(NSArray *)rowItems completionHandler:(dispatch_block_t)completionHandler errorHandler:(dispatch_block_t)errorHandler;

@end
