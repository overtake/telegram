//
//  TMHyperlinkTextField.m
//  Telegram P-Edition
//
//  Created by Dmitry Kondratyev on 1/28/14.
//  Copyright (c) 2014 keepcoder. All rights reserved.
//

#import "TMHyperlinkTextField.h"
#import "TMInAppLinks.h"

@interface TMHyperlinkTextField()
@property (nonatomic, strong) NSTextStorage *URLStorage;
@property (nonatomic, strong) NSLayoutManager *URLManager;
@property (nonatomic, strong) NSTextContainer *URLContainer;
@property (nonatomic, strong) NSURL *clickedURL;
@property (nonatomic) BOOL canCopyURLs;
@property (nonatomic) NSTrackingRectTag trackingRect;
@end

@implementation TMHyperlinkTextField

- (id)initWithCoder:(NSCoder *)coder {
	if ( (self = [super initWithCoder:coder]) ) {
		[self setEditable:NO];
		[self setSelectable:NO];
		self.canCopyURLs = NO;
        self.hardYOffset = 4;
	}
	
	return self;
}

+ (id)defaultTextField {
    TMHyperlinkTextField *textField = [[self alloc] init];
    [textField setBordered:NO];
    [textField setDrawsBackground:NO];
    [textField setSelectable:NO];
    [textField setEditable:NO];
    return textField;
}


- (id)initWithFrame:(NSRect)frameRect {
	if ( (self = [super initWithFrame:frameRect]) ) {
		[self setEditable:NO];
		[self setSelectable:NO];
		self.canCopyURLs = NO;
        self.hardYOffset = 4;
	}
	return self;
}

- (void)dealloc {
}

/* Enforces that the text field be non-editable and
 non-selectable. Probably not needed, but I always
 like to be cautious.
 */

- (void)setAttributedStringValue:(NSAttributedString *)aStr {
	self.URLStorage = nil;
	[super setAttributedStringValue:aStr];
    [self.window invalidateCursorRectsForView:self];
}

- (void)setStringValue:(NSString *)aStr {
    if(!aStr) aStr = @"";
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:aStr attributes:nil];
	[self setAttributedStringValue:attrString];
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self removeTrackingRect:self.trackingRect];
    self.trackingRect = [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
}

- (void) setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    [self removeTrackingRect:self.trackingRect];
    self.trackingRect = [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
}

- (void)resetCursorRects {
	if ( [[self attributedStringValue] length] == 0 ) {
		[super resetCursorRects];
		return;
	}
	
	NSRect cellBounds = [[self cell] drawingRectForBounds:[self bounds]];
    
	if ( self.URLStorage == nil ) {
		BOOL cellWraps = ![[self cell] isScrollable];
		NSSize containerSize = NSMakeSize( cellWraps ? cellBounds.size.width : MAXFLOAT, cellWraps ? MAXFLOAT : cellBounds.size.height );
		self.URLContainer = [[NSTextContainer alloc] initWithContainerSize:containerSize];
		self.URLManager = [[NSLayoutManager alloc] init];
		self.URLStorage = [[NSTextStorage alloc] init];
		
		[self.URLStorage addLayoutManager:self.URLManager];
		[self.URLManager addTextContainer:self.URLContainer];
		[self.URLContainer setLineFragmentPadding:2.f];
        
        
		
		[self.URLStorage setAttributedString:[self attributedStringValue]];
        
        
        
	}
	
	NSUInteger myLength = [self.URLStorage length];
	NSRange returnRange = { NSNotFound, 0 }, stringRange = { 0, myLength }, glyphRange = { NSNotFound, 0 };
	NSCursor *pointingCursor = nil;
	
	/* Here mainly for 10.2 compatibility (in case anyone even tries for that anymore) */
	if ( [NSCursor respondsToSelector:@selector(pointingHandCursor)] ) {
		pointingCursor = [NSCursor performSelector:@selector(pointingHandCursor)];
	} else {
		[super resetCursorRects];
		return;
	}
    
//    MTLog(@"log cursor");
	
	/* Moved out of the while and for loops as there's no need to recalculate
     it every time through */
	NSRect superVisRect = [self convertRect:[[self superview] visibleRect] fromView:[self superview]];
    
    
	while ( stringRange.location < myLength ) {
		id aVal = [self.URLStorage attribute:NSLinkAttributeName atIndex:stringRange.location longestEffectiveRange:&returnRange inRange:stringRange];
		
		if ( aVal != nil ) {
			NSRectArray aRectArray = NULL;
			NSUInteger numRects = 0, j = 0;
			glyphRange = [self.URLManager glyphRangeForCharacterRange:returnRange actualCharacterRange:nil];
			aRectArray = [self.URLManager rectArrayForGlyphRange:glyphRange withinSelectedGlyphRange:glyphRange inTextContainer:self.URLContainer rectCount:&numRects];
			for ( j = 0; j < numRects; j++ ) {
				/* Check to make sure the rect is visible before setting the cursor */
				NSRect glyphRect = aRectArray[j];
				glyphRect.origin.x += cellBounds.origin.x;
				glyphRect.origin.y += cellBounds.origin.y;
				NSRect textRect = NSIntersectionRect(glyphRect, cellBounds);
				NSRect cursorRect = NSIntersectionRect(textRect, superVisRect);
				if ( NSIntersectsRect( textRect, superVisRect ) ) {
                    cursorRect.origin.y +=self.hardYOffset;
                    cursorRect.origin.x +=self.hardXOffset;
//                    cursorRect.size.height += 0;
                    [self addCursorRect:cursorRect cursor:pointingCursor];
//                    MTLog(@"clicable");
                }
			}
		}
		stringRange.location = NSMaxRange(returnRange);
		stringRange.length = myLength - stringRange.location;
	}
}

- (NSURL *) urlAtMouse:(NSEvent *)mouseEvent {
	NSURL *urlAtMouse = nil;
	NSPoint mousePoint = [self convertPoint:[mouseEvent locationInWindow] fromView:nil];
	NSRect cellBounds = [[self cell] drawingRectForBounds:[self bounds]];
    
    mousePoint.y -= self.hardYOffset;
    mousePoint.x -= self.hardXOffset;
	if ( ([self.URLStorage length] > 0 ) && [self mouse:mousePoint inRect:cellBounds] ) {
		id aVal = nil;
		NSRange returnRange = { NSNotFound, 0 }, glyphRange = { NSNotFound, 0 };
		NSRectArray linkRect = NULL;
		NSUInteger glyphIndex = [self.URLManager glyphIndexForPoint:mousePoint inTextContainer:self.URLContainer];
		NSUInteger charIndex = [self.URLManager characterIndexForGlyphAtIndex:glyphIndex];
		NSUInteger numRects = 0, j = 0;
		
		aVal = [self.URLStorage attribute:NSLinkAttributeName atIndex:charIndex longestEffectiveRange:&returnRange inRange:NSMakeRange(charIndex, [self.URLStorage length] - charIndex)];
        
//        NSLog@"test %c", [self.stringValue characterAtIndex:charIndex]);
        
		if ( (aVal != nil) ) {
			glyphRange = [self.URLManager glyphRangeForCharacterRange:returnRange actualCharacterRange:nil];
			linkRect = [self.URLManager rectArrayForGlyphRange:glyphRange withinSelectedGlyphRange:glyphRange inTextContainer:self.URLContainer rectCount:&numRects];
            
			for ( j = 0; j < numRects; j++ ) {
				NSRect testHit = linkRect[j];
                
                
				testHit.origin.x += cellBounds.origin.x;
				testHit.origin.x += cellBounds.origin.y;

				if ( [self mouse:mousePoint inRect:NSIntersectionRect(testHit, cellBounds)] ) {
					// be smart about links stored as strings
					if ( [aVal isKindOfClass:[NSString class]] )
						aVal = [NSURL URLWithString:aVal];
					urlAtMouse = aVal;
					break;
				}
			}
		}
	}
	return urlAtMouse;
}

- (NSMenu *)menuForEvent:(NSEvent *)aEvent {
	if ( !self.canCopyURLs )
		return nil;
	
	NSURL *anURL = [self urlAtMouse:aEvent];
	
	if ( anURL != nil ) {
		NSMenu *aMenu = [[NSMenu alloc] initWithTitle:@"Conversation.CopyURL"];
		NSMenuItem *anItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Conversation.CopyURL", nil) action:@selector(copyURL:) keyEquivalent:@""];
		[anItem setTarget:self];
		[anItem setRepresentedObject:anURL];
		[aMenu addItem:anItem];
		
		return aMenu;
	}
	
	return nil;
}



- (void)copyURL:(id)sender {
	NSPasteboard *copyBoard = [NSPasteboard pasteboardWithName:NSGeneralPboard];
	NSURL *copyURL = [sender representedObject];
	
	[copyBoard declareTypes:[NSArray arrayWithObjects:NSURLPboardType, NSStringPboardType, nil] owner:nil];
	[copyURL writeToPasteboard:copyBoard];
	[copyBoard setString:[copyURL absoluteString] forType:NSStringPboardType];
}

- (void)mouseDown:(NSEvent *)mouseEvent {
	/* Not calling [super mouseDown:] because there are some situations where
     the mouse tracking is ignored otherwise. */
	
	/* Remember which URL was clicked originally, so we don't end up opening
     the wrong URL accidentally.
     */
	self.clickedURL = [self urlAtMouse:mouseEvent];
    
    if(!self.clickedURL) {
        [super mouseDown:mouseEvent];
    }
}



- (void)mouseUp:(NSEvent *)mouseEvent {
	NSURL* urlAtMouse = [self urlAtMouse:mouseEvent];
    MTLog(@" %@", urlAtMouse);
	if ( (urlAtMouse != nil)  &&  [urlAtMouse isEqualTo:self.clickedURL] ) {
        if(self.url_delegate) {
            [self.url_delegate textField:self handleURLClick:[urlAtMouse absoluteString]];
        } else {
            [TMInAppLinks parseUrlAndDo:[urlAtMouse absoluteString]];
        }
	}

	self.clickedURL = nil;
    if(!urlAtMouse)
        [super mouseUp:mouseEvent];
}

- (void) mouseEntered:(NSEvent *)theEvent {
    [super mouseEntered:theEvent];
    
    [self.window invalidateCursorRectsForView:self];
//    [self resetCursorRects];
}


@end
