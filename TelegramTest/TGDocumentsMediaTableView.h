//
//  TGDocumentsMediaTableView.h
//  Telegram
//
//  Created by keepcoder on 27.01.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import "TMTableView.h"
#import "TGDocumentMediaRowView.h"
@interface TGDocumentsMediaTableView : MessagesTableView
@property (nonatomic,assign) BOOL isProgress;

-(void)setConversation:(TL_conversation *)conversation;

-(BOOL)isNeedCap;
@end
