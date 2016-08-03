//
//  TGConfirmPhoneModalView.h
//  Telegram
//
//  Created by keepcoder on 27/07/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TGModalView.h"

@interface TGConfirmPhoneModalView : TGModalView
-(void)show:(NSWindow *)window animated:(BOOL)animated response:(TLauth_SentCode *)response;
@end
