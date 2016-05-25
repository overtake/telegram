//
//  TLDocument+Extension.h
//  Telegram
//
//  Created by keepcoder on 15.12.14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLDocument (Extension)

-(int)duration;
-(NSString *)file_name;
-(NSString *)path_with_cache;
- (BOOL)isset;

-(BOOL)isSticker;
-(BOOL)isVoice;
-(BOOL)isAudio;
-(BOOL)isGif;
-(BOOL)isVideo;
-(TLDocumentAttribute *)attributeWithClass:(Class)className;
-(NSSize)imageSize;
-(BOOL)isExist;
-(TL_documentAttributeAudio *)audioAttr;
-(TL_documentAttributeSticker *)stickerAttr;
-(NSArray *)serverAttributes;


@end
