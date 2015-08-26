//
//  TGObservableObject.h
//  Telegram
//
//  Created by keepcoder on 24.08.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TGObservableDelegate <NSObject>

-(void)didChangedEventStateWithObject:(id)object;

@end


@interface TGObservableObject : NSObject


//strong listeners
-(void)addEventListener:(id <TGObservableDelegate>)listener;
//weak
-(void)addWeakEventListener:(id <TGObservableDelegate>)listener;


-(void)removeEventListener:(id <TGObservableDelegate>)listener;
-(void)notifyListenersWithObject:(id)object;

@end
