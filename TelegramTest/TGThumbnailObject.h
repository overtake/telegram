//
//  TGThumbnailObject.h
//  Telegram
//
//  Created by keepcoder on 14/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGImageObject.h"

@interface TGThumbnailObject : TGImageObject

@property (nonatomic,strong) NSString *path;


-(id)initWithFilepath:(NSString *)filepath;
@end
