//
//  NSAlertCategory.m
//  Messenger for Telegram
//
//  Created by Dmitry Kondratyev on 3/5/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "NSAlertCategory.h"

static char * const qBlockActionKey = "BlockActionKey";

@implementation NSAlert (Category)

+ (NSAlert *)alertWithMessageText:(NSString *)message informativeText:(NSString *)informativeText block:(void (^)(id))block {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert setMessageText:message];
    [alert setInformativeText:informativeText];
    objc_setAssociatedObject(alert, qBlockActionKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return alert;
}

- (void)show {

    [self beginSheetModalForWindow:[NSApp keyWindow]
                      modalDelegate:self
                     didEndSelector:@selector(testDatabaseConnectionDidEnd:returnCode:contextInfo:)
                        contextInfo:nil];
    
}

- (void (^)(id))blockAction {
    return objc_getAssociatedObject(self, qBlockActionKey);
}

- (void)testDatabaseConnectionDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
    void (^block)(id) = objc_getAssociatedObject(self, qBlockActionKey);
    
    if(block)
        block(@(returnCode));
}
@end
