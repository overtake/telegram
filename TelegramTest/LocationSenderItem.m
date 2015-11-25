//
//  LocationSenderItem.m
//  Telegram
//
//  Created by keepcoder on 17.07.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "LocationSenderItem.h"

@implementation LocationSenderItem


-(id)initWithCoordinates:(CLLocationCoordinate2D)coordinates conversation:(TL_conversation *)conversation additionFlags:(int)additionFlags
{
    if(self = [super init]) {
        
        self.conversation = conversation;
        
        self.message = [MessageSender createOutMessage:@"" media:[TL_messageMediaGeo createWithGeo:[TL_geoPoint createWithN_long:coordinates.longitude lat:coordinates.latitude]] conversation:conversation];
        
        if(additionFlags & (1 << 4))
            self.message.from_id = 0;

        
        [self.message save:YES];
    }
    
    return self;
}



-(void)performRequest {
    
    TLAPI_messages_sendMedia *request = [TLAPI_messages_sendMedia createWithFlags:[self senderFlags] peer:[self.conversation inputPeer] reply_to_msg_id:self.message.reply_to_msg_id media:[TL_inputMediaGeoPoint createWithGeo_point:[TL_inputGeoPoint createWithLat:self.message.media.geo.lat n_long:self.message.media.geo.n_long]] random_id:self.message.randomId reply_markup:[TL_replyKeyboardMarkup createWithFlags:0 rows:[@[]mutableCopy]]];
    
    self.rpc_request = [RPCRequest sendRequest:request successHandler:^(RPCRequest *request, TLUpdates * response) {
        
        [self updateMessageId:response];
        
        
        TL_localMessage *msg = [TL_localMessage convertReceivedMessage:[[self updateNewMessageWithUpdates:response] message]];
        
        if(msg == nil)
        {
            [self cancel];
            return;
        }
        
        ((TL_localMessage *)self.message).n_id = msg.n_id;
        ((TL_localMessage *)self.message).date = msg.date;
        ((TL_localMessage *)self.message).dstate = DeliveryStateNormal;
        
        [self.message save:YES];
        
        self.state = MessageSendingStateSent;
        
        
    } errorHandler:^(RPCRequest *request, RpcError *error) {
        self.state = MessageSendingStateError;
    } timeout:0 queue:[ASQueue globalQueue].nativeQueue];
    
}


@end
