#import "NSView-DisableSubsAdditions.h"

@implementation NSView (DisableSubsAdditions)

- (void)disableSubViews {
    
    [self setSubViewsEnabled:NO];
}

- (void)enableSubViews {
    [self setSubViewsEnabled:YES];
}

- (void)setSubViewsEnabled:(BOOL)enabled {
    NSView *currentView = NULL;
    NSEnumerator *viewEnumerator = [[self subviews] objectEnumerator];
    
    while( currentView = [viewEnumerator nextObject] )
    {
        
        if(currentView.class == [NSTextView class]) {
            if( [currentView respondsToSelector:@selector(setSelectable:)] )
            {
                [(NSTextField*)currentView setSelectable:enabled];
            }
        }
        
        if( [currentView respondsToSelector:@selector(setEnabled:)] )
        {
            [(NSControl*)currentView setEnabled:enabled];
        }
        
        [currentView setSubViewsEnabled:enabled];
//        [currentView display];
    }
}

@end