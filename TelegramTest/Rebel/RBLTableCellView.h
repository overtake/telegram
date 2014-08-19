//
//  RBLTableCellView.h
//  Rebel
//
//  Created by Jonathan Willing on 10/23/12.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// A subclass of NSTableCellView that adds a method
// which notifies when the cell view will be reused.
// Useful to clear properties and bindings before reuse.
@interface RBLTableCellView : NSTableCellView


// Called when the cell view has either been removed from
// its superview (the row view), or has just been created.
//
// Either way, the cell will not have a superview during this
// time and will be in an enqueued state.
- (void)rbl_prepareForReuse;

@end
