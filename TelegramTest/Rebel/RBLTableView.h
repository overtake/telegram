//
//  RBLTableView.h
//  Rebel
//
//  Created by Danny Greg on 20/04/2013.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// A standard table view with one fix.
//
// As opposed to trying to scroll rects into the middle of the view each time,
// we move them just enough as to make them visible. This fixes the table view
// appearing to have some kind of seizure when you, for example, hold down an
// arrow key to scroll through table cells really fast.
//
// This fix applies to both cell and view based tableviews.
@interface RBLTableView : NSTableView

@end
