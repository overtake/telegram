//
//  TGWebpageDocumentObject.h
//  Telegram
//
//  Created by keepcoder on 12/01/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGWebpageObject.h"

@interface TGWebpageDocumentObject : TGWebpageObject

-(TL_localMessage *)fakeMessage;

-(DownloadItem *)downloadItem;
-(BOOL)isset;
-(void)startDownload:(BOOL)cancel force:(BOOL)force;
@end
