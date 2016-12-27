//
//  TGGameObject.m
//  Telegram
//
//  Created by keepcoder on 27/09/2016.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGGameObject.h"

@interface TGGameObject ()



@end

@implementation TGGameObject

- (instancetype)initWithGame:(TLGame *)game message:(TL_localMessage *)message text:(NSAttributedString *)text {
    self = [super init];
    if (self) {
        
        if (game == nil) {
            game = [TL_game createWithFlags:0 n_id:0 access_hash:0 short_name:message.media.bot_result.title title:message.media.bot_result.title n_description:message.media.bot_result.n_description photo:message.media.bot_result.photo document:message.media.bot_result.document];
        }
        
        _message = message;
        _game = game;
        NSMutableAttributedString *t = [[NSMutableAttributedString alloc] init];
        [t appendString:game.title withColor:LINK_COLOR];
        [t setFont:TGSystemMediumFont(13) forRange:t.range];
        _title = [t copy];
        
        if (text.length == 0) {
            NSMutableAttributedString *d = [[NSMutableAttributedString alloc] init];
            [d appendString:message.message.length > 0 ? message.message : game.n_description withColor:TEXT_COLOR];
            [d setFont:TGSystemFont(13) forRange:d.range];
            _desc = [d copy];
        } else {
            _desc = text;
        }
        
        
        if (game.document != nil) {
            TL_localMessage *fake = [[TL_localMessage alloc] init];
            fake.media = [TL_messageMediaDocument createWithDocument:game.document caption:@""];
            fake.n_id = rand_int();
            _gifItem = [MessageTableItem messageItemFromObject:fake];
        } else {
            if (game.photo != nil) {
                TLPhotoSize *photo = game.photo.sizes.lastObject;
                _imageObject = [[TGImageObject alloc] initWithLocation:photo.location];
                
            }
        }
        
        
    }
    return self;
}

-(void)makeSize:(int)width {
    
    TLPhotoSize *photo = self.game.photo.sizes.lastObject;
    _imageObject.imageSize = strongsize(NSMakeSize(photo.w, photo.h), MIN(width - 20,MIN_IMG_SIZE.width - 20));
    [_gifItem makeSizeByWidth:MIN(width - 20,MIN_IMG_SIZE.width - 20)];
    
    int max = MAX(_gifItem.contentSize.width + 10 ,_imageObject.imageSize.width + 10);
    
    NSSize title = [self.title coreTextSizeOneLineForWidth:max-10];
    _descSize = [self.desc coreTextSizeForTextFieldForWidth:max-10];
    
   
    
    _size = NSMakeSize(max, title.height + _descSize.height + 2 + _imageObject.imageSize.height + _gifItem.blockSize.height + 4);
    
}

@end
