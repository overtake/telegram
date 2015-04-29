#import "TelegramSerialization.h"

#import <MTProtoKit/MTDatacenterAddress.h>
#import <MTProtoKit/MTDatacenterSaltInfo.h>
#import "RpcError.h"
#import "NSData+Extensions.h"
#import "RpcErrorParser.h"

@implementation TelegramSerialization

- (NSData *)serializeMessage:(id)message
{
    if(!message)
        return nil;
    if([message respondsToSelector:@selector(getData)])
        return  [message getData];
    return [TLClassStore serialize:message];
}

- (id)parseMessage:(NSInputStream *)is responseParsingBlock:(int32_t (^)(int64_t, bool *))responseParsingBlock
{
    
    id obj = [TLClassStore constructObject:is];
    if([obj isKindOfClass:[TL_gzip_packed class]]) {
        obj = [TLClassStore deserialize:[[obj packed_data] gzipInflate]];
    }
    
    return obj;
}

- (NSString *)messageDescription:(id)messageBody messageId:(int64_t)messageId messageSeqNo:(int32_t)messageSeqNo
{
    return NSStringFromClass([messageBody class]);
}

- (id)reqPq:(NSData *)nonce
{
    return [TL_req_pq createWithNonce:nonce];
}

- (id)reqDhParams:(NSData *)nonce serverNonce:(NSData *)serverNonce p:(NSData *)p q:(NSData *)q publicKeyFingerprint:(int64_t)publicKeyFingerprint encryptedData:(NSData *)encryptedData
{
    return [TL_req_DH_params createWithNonce:nonce server_nonce:serverNonce p:p q:q public_key_fingerprint:publicKeyFingerprint encrypted_data:encryptedData];
}

- (id)setDhParams:(NSData *)nonce serverNonce:(NSData *)serverNonce encryptedData:(NSData *)encryptedData
{
    return [TL_set_client_DH_params createWithNonce:nonce server_nonce:serverNonce encrypted_data:encryptedData];
}

- (id)pqInnerData:(NSData *)nonce serverNonce:(NSData *)serverNonce pq:(NSData *)pq p:(NSData *)p q:(NSData *)q newNonce:(NSData *)newNonce
{
    return [TL_p_q_inner_data createWithPq:pq p:p q:q nonce:nonce server_nonce:serverNonce n_nonce:newNonce];
}

- (id)clientDhInnerData:(NSData *)nonce serverNonce:(NSData *)serverNonce g_b:(NSData *)g_b retryId:(int32_t)retryId
{
    return [TL_client_DH_inner_data createWithNonce:nonce server_nonce:serverNonce retry_id:retryId g_b:g_b];
}

- (bool)isMessageResPq:(id)message
{
    return [message isKindOfClass:[TL_resPQ class]];
}

- (NSData *)resPqNonce:(id)message
{
    return [(TL_resPQ *)message nonce];
}

- (NSData *)resPqServerNonce:(id)message
{
    return [message server_nonce];
}

- (NSData *)resPqPq:(id)message
{
    return [message pq];
}

- (NSArray *)resPqServerPublicKeyFingerprints:(id)message
{
    return [message server_public_key_fingerprints];
}

- (bool)isMessageServerDhParams:(id)message
{
    return [message isKindOfClass:[TL_server_DH_params_ok class]] || [message isKindOfClass:[TL_server_DH_params_fail class]];
}

- (NSData *)serverDhParamsNonce:(id)message
{
    return [(TL_server_DH_params_ok *)message nonce];
}

- (NSData *)serverDhParamsServerNonce:(id)message
{
    return [message server_nonce];
}

- (bool)isMessageServerDhParamsOk:(id)message
{
    return [message isKindOfClass:[TL_server_DH_params_ok class]];
}

- (NSData *)serverDhParamsOkEncryptedAnswer:(id)message
{
    return [message encrypted_answer];
}

- (bool)isMessageServerDhInnerData:(id)message
{
    return [message isKindOfClass:[TL_server_DH_inner_data class]];
}

- (NSData *)serverDhInnerDataNonce:(id)message
{
    return [(TL_server_DH_inner_data *)message nonce];
}

- (NSData *)serverDhInnerDataServerNonce:(id)message
{
    return [message server_nonce];
}

- (int32_t)serverDhInnerDataG:(id)message
{
    return [message g];
}

- (NSData *)serverDhInnerDataDhPrime:(id)message
{
    return [message dh_prime];
}

- (NSData *)serverDhInnerDataGA:(id)message
{
    return [message g_a];
}


- (bool)isMessageSetClientDhParamsAnswer:(id)message
{
    return [TL_set_client_DH_params class];
}

- (bool)isMessageSetClientDhParamsAnswerOk:(id)message
{
    return [message isKindOfClass:[TL_dh_gen_ok class]];
}

- (bool)isMessageSetClientDhParamsAnswerRetry:(id)message
{
    return [message isKindOfClass:[TL_dh_gen_retry class]];
}

- (bool)isMessageSetClientDhParamsAnswerFail:(id)message
{
    return [message isKindOfClass:[TL_dh_gen_fail class]];
}

- (NSData *)setClientDhParamsNonce:(id)message
{
    return [(TLSet_client_DH_params_answer *)message nonce];
}

- (NSData *)setClientDhParamsServerNonce:(id)message
{
    return [message server_nonce];
}

- (NSData *)setClientDhParamsNewNonceHash1:(id)message
{
    return [message n_nonce_hash1];
}

- (NSData *)setClientDhParamsNewNonceHash2:(id)message
{
    return [message n_nonce_hash2];
}

- (NSData *)setClientDhParamsNewNonceHash3:(id)message
{
    return [message n_nonce_hash3];
}

- (id)exportAuthorization:(int32_t)datacenterId
{
    return [TLAPI_auth_exportAuthorization createWithDc_id:datacenterId];
}

- (NSData *)exportedAuthorizationBytes:(id)message
{
    return ((TL_auth_exportedAuthorization *)message).bytes;
}

- (int32_t)exportedAuthorizationId:(id)message
{
    return ((TL_auth_exportedAuthorization *)message).n_id;
}

- (id)importAuthorization:(int32_t)authId bytes:(NSData *)bytes
{
    return [TLAPI_auth_importAuthorization createWithN_id:authId bytes:bytes];
}

- (id)getConfig
{
    return [TLAPI_help_getConfig create];
}

- (NSArray *)datacenterAddressListFromConfig:(id)config datacenterId:(NSInteger)datacenterId
{
    if ([config isKindOfClass:[TL_config class]])
    {
        TL_config *concreteConfig = config;
        NSMutableArray *addressList = [[NSMutableArray alloc] init];
        
        for (TL_dcOption *dcOption in concreteConfig.dc_options)
        {
            if (dcOption.n_id == datacenterId)
            {
                MTDatacenterAddress *address = [[MTDatacenterAddress alloc] initWithIp:dcOption.ip_address port:(uint16_t)dcOption.port];
                [addressList addObject:address];
            }
        }
        
        return addressList;
    }
    
    return nil;
    
}

- (id)getFutureSalts:(int32_t)count
{
    return [TL_get_future_salts createWithNum:count];
}

- (bool)isMessageFutureSalts:(id)message
{
    return [message isKindOfClass:[TL_future_salts class]];
}

- (NSArray *)saltInfoListFromMessage:(id)message
{
    if ([self isMessageFutureSalts:message])
    {
        TL_future_salts *futureSalts = message;
        NSMutableArray *saltList = [[NSMutableArray alloc] init];
        for (TL_future_salt *salt in futureSalts.salts)
        {
            [saltList addObject:[[MTDatacenterSaltInfo alloc] initWithSalt:salt.salt firstValidMessageId:salt.valid_since * 4294967296 lastValidMessageId:salt.valid_until * 4294967296]];
        }
        
        return saltList;
    }
    
    return nil;
}



-(int64_t)pongPingId:(id)message {
    return [(TL_pong *)message ping_id];
}

- (id)resendMessagesRequest:(NSArray *)messageIds
{
    return [TL_msg_resend_req createWithMsg_ids:[messageIds mutableCopy]];
}

- (id)connectionWithApiId:(int32_t)apiId deviceModel:(NSString *)deviceModel systemVersion:(NSString *)systemVersion appVersion:(NSString *)appVersion langCode:(NSString *)langCode query:(id)query
{
    TL_initConnection *initConnection = [[TL_initConnection alloc] init];
    initConnection.api_id = API_ID;
    initConnection.device_model = deviceModel;
    initConnection.system_version = systemVersion;
    initConnection.app_version = appVersion;
    initConnection.lang_code = langCode;
    initConnection.query = query;
    return initConnection;
}

- (id)invokeAfterMessageId:(int64_t)messageId query:(id)query
{
    TL_invokeAfter *invoke = [[TL_invokeAfter alloc] init];
    invoke.msg_id = messageId;
    invoke.query = [query getData];
    return invoke;
}

- (bool)isMessageContainer:(id)message
{
    return [message isKindOfClass:[TL_msg_container class]];
}

- (NSArray *)containerMessages:(id)message
{
    return [message messages];
}

- (bool)isMessageProtoMessage:(id)message
{
    return [message isKindOfClass:[TL_proto_message class]];
}

- (id)protoMessageBody:(id)message messageId:(int64_t *)messageId seqNo:(int32_t *)seqNo length:(int32_t *)length
{
    if ([self isMessageProtoMessage:message])
    {
        if (messageId != NULL)
            *messageId = ((TL_proto_message *)message).msg_id;
        if (seqNo != NULL)
            *seqNo = ((TL_proto_message *)message).seqno;
        if (length != NULL)
            *length = ((TL_proto_message *)message).bytes;
        
        return ((TL_proto_message *)message).body;
    }
    
    return nil;
}

- (bool)isMessageProtoCopyMessage:(id)message
{
    return [message isKindOfClass:[TL_msg_copy class]];
}

- (id)protoCopyMessageBody:(id)message messageId:(int64_t *)messageId seqNo:(int32_t *)seqNo length:(int32_t *)length
{
    return nil;
}

- (bool)isMessageRpcWithLayer:(id)message
{
    return true;
}

- (id)wrapInLayer:(id)message
{
   // RpcLayer *layer = [[RpcLayer alloc] init];
   // layer.query = message;
    return message;
}

- (id)dropAnswerToMessageId:(int64_t)messageId
{
    return [TL_rpc_drop_answer createWithReq_msg_id:messageId];
}

- (bool)isRpcDroppedAnswer:(id)message
{
    return [message isKindOfClass:[TL_rpc_drop_answer class]];
}

- (int64_t)rpcDropedAnswerDropMessageId:(id)message
{
    if ([self isRpcDroppedAnswer:message])
        return ((TL_rpc_result *)message).req_msg_id;
    
    return 0;
}

- (bool)isMessageRpcResult:(id)message
{
    return [message isKindOfClass:[TL_rpc_result class]];
}


- (id)rpcResultBody:(id)message requestMessageId:(int64_t *)requestMessageId
{
    if ([self isMessageRpcResult:message])
    {
        if (requestMessageId != NULL)
            *requestMessageId = ((TL_rpc_result *)message).req_msg_id;
        TL_rpc_result *rpc = message;
        if([rpc.result isKindOfClass:[TL_gzip_packed class]])
            return  [TLClassStore deserialize:[[rpc.result packed_data] gzipInflate]];
        return rpc.result;
    }
    
    return nil;
}

- (id)rpcResult:(id)resultBody requestBody:(id)requestBody isError:(bool *)isError
{
    if ([resultBody isKindOfClass:[TL_rpc_error class]])
    {
        if (isError != NULL)
            *isError = true;
        
        return resultBody;
    }
    return resultBody;
}

- (int32_t)rpcRequestBodyResponseSignature:(id)requestBody
{
    return 0;
}


- (NSString *)rpcErrorDescription:(id)error
{
    if ([error isKindOfClass:[TL_rpc_error class]]) {
        
        RpcError *rpc_error = [RpcErrorParser parseRpcError:error];
        
        if( rpc_error.error_code == 401)
        {
            
            if(![rpc_error.error_msg isEqualToString:@"SESSION_PASSWORD_NEEDED"]) {
                
                 [[Telegram delegate] logoutWithForce:YES];
            
            }
        } else if( rpc_error.error_code == 303 ) {
            
            [[MTNetwork instance] setDatacenter:rpc_error.resultId];
            [[MTNetwork instance] initConnectionWithId:rpc_error.resultId];
        } else {
            MTLog(@"%@",rpc_error.error_msg);
        }
        
        
        
        return [[NSString alloc] initWithFormat:@"%d: %@", ((TL_rpc_error *)error).error_code, ((TL_rpc_error *)error).error_message];
        
    }
    
    return @"Undefined error description";
}

- (int32_t)rpcErrorCode:(id)error
{
    if ([error isKindOfClass:[TL_rpc_error class]])
        return ((TL_rpc_error *)error).error_code;
    return 0;
}

- (NSString *)rpcErrorText:(id)error
{
    if ([error isKindOfClass:[TL_rpc_error class]])
        return ((TL_rpc_error *)error).error_message;
    return @"Undefined error";
}

- (id)ping:(int64_t)pingId
{
    return [TL_ping createWithPing_id:pingId];
}

- (bool)isMessagePong:(id)message
{
    return [message isKindOfClass:[TL_pong class]];
}

- (int64_t)pongMessageId:(id)message
{
    return [(TL_pong *)message msg_id];
}


- (id)msgsAck:(NSArray *)messageIds
{
    return [TL_msgs_ack createWithMsg_ids:[messageIds mutableCopy]];
}

- (bool)isMessageMsgsAck:(id)message
{
    return [message isKindOfClass:[TL_msgs_ack class]];
}

- (NSArray *)msgsAckMessageIds:(id)message
{
    return [message msg_ids];
}

- (bool)isMessageBadMsgNotification:(id)message
{
    return [message isKindOfClass:[TLBadMsgNotification class]];
}

- (int64_t)badMessageBadMessageId:(id)message
{
    if ([self isMessageBadMsgNotification:message])
        return ((TL_bad_msg_notification *)message).bad_msg_id;
    
    return 0;
}

- (bool)isMessageBadServerSaltNotification:(id)message
{
    return [message isKindOfClass:[TL_bad_server_salt class]];
}

- (int64_t)badMessageNewServerSalt:(id)message
{
    if ([self isMessageBadServerSaltNotification:message])
        return ((TL_bad_server_salt *)message).new_server_salt;
    
    return 0;
}

- (int32_t)badMessageErrorCode:(id)message
{
    if ([self isMessageBadMsgNotification:message])
        return ((TL_bad_msg_notification *)message).error_code;
    
    return 0;
}


- (bool)isMessageDetailedInfo:(id)message
{
    return [message isKindOfClass:[TL_msg_detailed_info class]];
}

- (bool)isMessageDetailedResponseInfo:(id)message
{
    return [message isKindOfClass:[TL_msg_new_detailed_info class]];
}

- (int64_t)detailedInfoResponseRequestMessageId:(id)message
{
    return [(TL_msg_detailed_info *)message msg_id];
}

- (int64_t)detailedInfoResponseMessageId:(id)message
{
    return [message answer_msg_id];
}

- (int64_t)detailedInfoResponseMessageLength:(id)message
{
    if ([self isMessageDetailedInfo:message])
        return ((TL_msg_detailed_info *)message).bytes;
    
    return 0;
    
}

-(bool)isMessageMsgsStateInfo:(id)message forInfoRequestMessageId:(int64_t)infoRequestMessageId {
    return NO;
}

- (bool)isMessageNewSession:(id)message
{
    return [message isKindOfClass:[TL_new_session_created class]];
}

- (int64_t)messageNewSessionFirstValidMessageId:(id)message
{
    if ([self isMessageNewSession:message])
        return ((TL_new_session_created *)message).first_msg_id;
    
    return 0;
}

- (id)httpWaitWithMaxDelay:(int32_t)maxDelay waitAfter:(int32_t)waitAfter maxWait:(int32_t)maxWait
{
    return [TL_http_wait createWithMax_delay:maxDelay wait_after:waitAfter max_wait:maxWait];
}



@end
