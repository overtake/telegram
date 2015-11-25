//
//  TGPhotoViewerBehavior.h
//  Telegram
//
//  Created by keepcoder on 09/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TGPhotoViewerBehavior : NSObject

@property (nonatomic,strong,readonly) ChatHistoryController *controller;


-(id)initWithConversation:(TL_conversation *)conversation commonItem:(PreviewObject *)object;

-(void)drop;

@end
