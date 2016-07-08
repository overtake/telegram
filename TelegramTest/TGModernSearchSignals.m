//
//  TGModernSearchSignals.m
//  Telegram
//
//  Created by keepcoder on 07/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModernSearchSignals.h"
#import "TGModernSearchItem.h"
#import "SearchMessageTableItem.h"
#import "SearchHashtagItem.h"
@implementation TGModernSearchSignals


+(SSignal *)usersAndChatsSignal:(NSString *)search {
     
    SSignal *s = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        
        NSArray *searchChats = [[ChatsManager sharedManager] searchWithString:search selector:@"title username" checker:^BOOL(TLChat *chat) {
            return !chat.isDeactivated && !chat.isLeft && !chat.dialog.isInvisibleChannel;
        }];
        
        
        NSArray *searchUsers = [[UsersManager sharedManager] searchWithString:search selector:@"fullName username" checker:^BOOL(TLUser *user) {
            
            if(!user.isMin) {
                TL_conversation *dialog = [[DialogsManager sharedManager] find:user.n_id];
                return (dialog && !dialog.fake) || user.isContact;
            }
            
            return NO;
            
            
        }];
        
        [subscriber putNext:[searchChats arrayByAddingObjectsFromArray:searchUsers]];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            

        }];
        
    }];
    
    
    return [s map:^id(NSArray *next) {
        
        NSMutableArray *results = [NSMutableArray array];
        
        NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:next.count];
        
        [next enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [items addObject:[[TGModernSearchItem alloc] initWithObject:[obj dialog] selectText:nil]];
        }];
        
        [results addObjectsFromArray:items];
        
        return [results sortedArrayUsingComparator:^NSComparisonResult(TGModernSearchItem *obj1, TGModernSearchItem *obj2) {
            
            TL_conversation *c1 = obj1.conversation;
            TL_conversation *c2 = obj2.conversation;
            
            return c1.last_message_date > c2.last_message_date ? NSOrderedAscending : c1.last_message_date < c2.last_message_date ? NSOrderedDescending : NSOrderedSame;
            
        }];
        
    }];
}

+(SSignal *)globalUsersSignal:(NSString *)search  {
    
    SSignal *request = [[MTNetwork instance] requestSignal:[TLAPI_contacts_search createWithQ:search limit:100]];
    
    return [[request map:^id(TL_contacts_found *response) {
        
        if(response.users.count > 0 || response.chats > 0) {
            
            NSMutableArray *chatIds = [[NSMutableArray alloc] init];
            
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            
            NSArray *acceptUsers = [response.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",ids]];
            
            NSArray *acceptChats = [response.chats filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",chatIds]];
            
            [[UsersManager sharedManager] add:acceptUsers];
            
            [[ChatsManager sharedManager] add:acceptChats];
            
            NSArray *merge = [acceptUsers arrayByAddingObjectsFromArray:acceptChats];
            
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:merge.count];
            
            
            [merge enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [items addObject:[[TGModernSearchItem alloc] initWithObject:[obj dialog] selectText:search]];
            }];
            
            return items;
        }

        return @[];
        
    }] deliverOn:[SQueue mainQueue]];
    
}

+(SSignal *)messagesSignal:(NSString *)search {
    
    SSignal *signal = [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        SAtomic *offset_date = [[SAtomic alloc] initWithValue:@(0)];
        SAtomic *offset_id = [[SAtomic alloc] initWithValue:@(0)];

        NSMutableArray *messages = [NSMutableArray array];
        
        SSignal *msignal = [[MTNetwork instance] requestSignal:[TLAPI_messages_searchGlobal createWithQ:search offset_date:[offset_date.value intValue] offset_peer:[TL_inputPeerEmpty create] offset_id:[offset_id.value intValue] limit:100]];
        
        
        id (^map)(id response) = ^id(TL_messages_messagesSlice *response) {
            [TL_localMessage convertReceivedMessages:[response messages]];
            
            NSArray *messages = [[response messages] copy];
            
            [[response messages] removeAllObjects];
            
            [[UsersManager sharedManager] add:response.users];
            [[ChatsManager sharedManager] add:response.chats];
            
            NSMutableArray *filterIds = [[NSMutableArray alloc] init];
            
            NSArray *m = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT(self.n_id IN %@)",filterIds]];
            
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:m.count];
            
            [m enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [items addObject:[[SearchMessageTableItem alloc] initWithMessage:obj selectedText:search]];
            }];
            
            return items;
        };
        
        __block id <SDisposable> dispose = [[msignal map:map] startWithNext:^(NSArray *next) {
            
            [messages addObjectsFromArray:next];
            
            SearchMessageTableItem *last = [next lastObject];
            
            [offset_date swap:@(last.message.date)];
            [offset_id swap:@(last.message.n_id)];
            
            [subscriber putNext:messages];
            
            if(next.count > 0) {
                dispose = [msignal startWithNext:^(id next) {
                    
                    [subscriber putNext:messages];
                    
                }];
            } else
                [subscriber putCompletion];
            
        }];
        
        return [[SBlockDisposable alloc] initWithBlock:^{
            
            [dispose dispose];
            
        }];
        
    }];
    
    return [signal deliverOn:[SQueue mainQueue]];
    
}

+(SSignal *)hashtagSignal:(NSString *)search {
    return [[SSignal alloc] initWithGenerator:^id<SDisposable>(SSubscriber *subscriber) {
        
        NSString *hs = [search substringFromIndex:1];
        
        __block NSMutableDictionary *tags;
        
        [[Storage yap] readWithBlock:^(YapDatabaseReadTransaction *transaction) {
            
            tags = [transaction objectForKey:@"htags" inCollection:@"hashtags"];
            
        }];
        
        NSArray *list = [[tags allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            return obj1[@"count"] < obj2[@"count"];
            
        }];
        
        if(hs.length > 0)
        {
            list = [list filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag BEGINSWITH[c] %@",hs]];
        }
        
        NSMutableArray *items = [[NSMutableArray alloc] init];

        [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [items addObject:[[SearchHashtagItem alloc] initWithObject:obj[@"tag"]]];
        }];
        
        [subscriber putNext:items];
        [subscriber putCompletion];
        
        
        return nil;
        
    }];
}

@end
