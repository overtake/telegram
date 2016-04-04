//
//  TGContextRowItem.h
//  Telegram
//
//  Created by keepcoder on 23/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TMRowItem.h"
#import "TGWebpageObject.h"
#import "TGGeneralRowItem.h"
#import "TGExternalImageObject.h"
#import "TGAudioController.h"
@interface TGContextRowItem : TGGeneralRowItem
@property (nonatomic,strong,readonly) TLBotInlineResult *botResult;
@property (nonatomic,strong,readonly) TLUser *bot;
@property (nonatomic,assign,readonly) long queryId;
@property (nonatomic,strong,readonly) NSMutableAttributedString *desc;
@property (nonatomic,assign,readonly) NSSize descSize;
@property (nonatomic,strong,readonly) NSString *domainSymbol;
@property (nonatomic,strong) TGImageObject *imageObject;

@property (nonatomic,strong,readonly) DownloadItem *downloadItem;

@property (nonatomic,strong,readonly) DownloadEventListener *downloadEventListener;

@property (nonatomic,strong) TGAudioController *audioController;

-(TL_localMessage *)fakeMessage;


-(void)startDownload:(BOOL)cancel;
-(BOOL)isset;
-(NSString *)path;

-(id)initWithObject:(id)object bot:(TLUser *)bot queryId:(long)queryId;

@end
