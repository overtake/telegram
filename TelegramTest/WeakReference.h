//
//  WeakReference.h
//  Telegram
//
//  Created by keepcoder on 15.09.15.
//  Copyright (c) 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeakReference : NSObject {
    __weak id nonretainedObjectValue;
    __unsafe_unretained id originalObjectValue;
}

+ (WeakReference *) weakReferenceWithObject:(id) object;

- (id) nonretainedObjectValue;
- (void *) originalObjectValue;


@end
