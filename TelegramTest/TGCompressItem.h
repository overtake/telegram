//
//  TGCompressItem.h
//  Telegram
//
//  Created by keepcoder on 16/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TGCompressDelegate <NSObject>

-(void)didStartCompressing:(id)item;
-(void)didEndCompressing:(id)item success:(BOOL)success;
-(void)didProgressUpdate:(id)item progress:(int)progress;
-(void)didCancelCompressing:(id)item;



@end

@interface TGCompressItem : NSOperation<NSCoding>

typedef enum {
    TGCompressItemStateWaitingCompress,
    TGCompressItemStateCompressing,
    TGCompressItemStateCompressingSuccess,
    TGCompressItemStateCompressingFail,
    TGCompressItemStateCompressingCancel
} TGCompressItemState;

@property (nonatomic,assign) TGCompressItemState state;

@property (nonatomic,strong,readonly) NSString *path;
@property (nonatomic,assign) NSSize size;

@property (nonatomic,strong,readonly) NSString *outputPath;

@property (nonatomic,assign,readonly) float progress;

@property (nonatomic,weak) id<TGCompressDelegate> delegate;
@property (nonatomic,strong,readonly) TL_conversation *conversation;

-(id)initWithPath:(NSString *)path conversation:(TL_conversation *)conversation;

-(void)readyAndStart;


-(NSString *)mime_type;
-(NSArray *)attributes;

@end
