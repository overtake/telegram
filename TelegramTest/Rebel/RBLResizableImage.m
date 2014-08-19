//
//  RBLResizableImage.m
//  Rebel
//
//  Created by Justin Spahr-Summers on 2012-07-24.
//  Copyright (c) 2012 GitHub. All rights reserved.
//
//  Portions copyright (c) 2011 Twitter. All rights reserved.
//  See the LICENSE file for more information.
//

#import "RBLResizableImage.h"

@implementation RBLResizableImage

#pragma mark Drawing

- (void)drawInRect:(NSRect)dstRect fromRect:(NSRect)srcRect operation:(NSCompositingOperation)op fraction:(CGFloat)alpha {
	[self drawInRect:dstRect fromRect:srcRect operation:op fraction:alpha respectFlipped:YES hints:nil];
}

- (void)drawInRect:(NSRect)dstRect fromRect:(NSRect)srcRect operation:(NSCompositingOperation)op fraction:(CGFloat)alpha respectFlipped:(BOOL)respectFlipped hints:(NSDictionary *)hints {
	if (NSIsEmptyRect(dstRect)) {
		CGContextRef context = NSGraphicsContext.currentContext.graphicsPort;
		dstRect = CGContextGetClipBoundingBox(context);
	}
	CGImageRef image = [self CGImageForProposedRect:&dstRect context:NSGraphicsContext.currentContext hints:hints];
	NSAssert(image != NULL, @"Could not get CGImage of %@ for resizing", self);

	// Calculate scale factors from the pixel-independent representation to the
	// specific one we're using for this context.
	CGFloat widthScale = CGImageGetWidth(image) / self.size.width;
	CGFloat heightScale = CGImageGetHeight(image) / self.size.height;

	NSEdgeInsets insets = self.capInsets;

	// TODO: Cache the nine-part images for this common case of wanting to draw
	// the whole source image.
	if (CGRectIsEmpty(srcRect)) {
		// Match the image creation that occurs in the 'else' clause.
		CGImageRetain(image);
	} else {
		CGRect scaledRect = CGRectMake(srcRect.origin.x * widthScale, srcRect.origin.y * heightScale, srcRect.size.width * widthScale, srcRect.size.height * heightScale);
		image = CGImageCreateWithImageInRect(image, scaledRect);
		if (image == NULL) return;

		// Reduce insets to account for taking only part of the original image.
		insets.left = fmax(0, insets.left - CGRectGetMinX(srcRect));
		insets.bottom = fmax(0, insets.bottom - CGRectGetMinY(srcRect));

		CGFloat srcRightInset = self.size.width - CGRectGetMaxX(srcRect);
		insets.right = fmax(0, insets.right - srcRightInset);

		CGFloat srcTopInset = self.size.height - CGRectGetMaxY(srcRect);
		insets.top = fmax(0, insets.top - srcTopInset);
	}

	NSImage *topLeft = nil, *topEdge = nil, *topRight = nil;
	NSImage *leftEdge = nil, *center = nil, *rightEdge = nil;
	NSImage *bottomLeft = nil, *bottomEdge = nil, *bottomRight = nil;

	// Length of sides that run vertically.
	CGFloat verticalEdgeLength = fmax(0, self.size.height - insets.top - insets.bottom);

	// Length of sides that run horizontally.
	CGFloat horizontalEdgeLength = fmax(0, self.size.width - insets.left - insets.right);

	NSImage *(^imageWithRect)(CGRect) = ^ id (CGRect rect) {
		CGRect scaledRect = CGRectMake(rect.origin.x * widthScale, rect.origin.y * heightScale, rect.size.width * widthScale, rect.size.height * heightScale);
		CGImageRef part = CGImageCreateWithImageInRect(image, scaledRect);
		if (part == NULL) return nil;

		NSImage *image = [[NSImage alloc] initWithCGImage:part size:rect.size];
		CGImageRelease(part);

		return image;
	};

	if (verticalEdgeLength > 0) {
		if (insets.left > 0) {
			CGRect partRect = CGRectMake(0, insets.bottom, insets.left, verticalEdgeLength);
			leftEdge = imageWithRect(partRect);
		}

		if (insets.right > 0) {
			CGRect partRect = CGRectMake(self.size.width - insets.right, insets.bottom, insets.right, verticalEdgeLength);
			rightEdge = imageWithRect(partRect);
		}
	}

	if (horizontalEdgeLength > 0) {
		if (insets.bottom > 0) {
			CGRect partRect = CGRectMake(insets.left, 0, horizontalEdgeLength, insets.bottom);
			bottomEdge = imageWithRect(partRect);
		}

		if (insets.top > 0) {
			CGRect partRect = CGRectMake(insets.left, self.size.height - insets.top, horizontalEdgeLength, insets.top);
			topEdge = imageWithRect(partRect);
		}
	}

	if (insets.left > 0 && insets.top > 0) {
		CGRect partRect = CGRectMake(0, self.size.height - insets.top, insets.left, insets.top);
		topLeft = imageWithRect(partRect);
	}

	if (insets.left > 0 && insets.bottom > 0) {
		CGRect partRect = CGRectMake(0, 0, insets.left, insets.bottom);
		bottomLeft = imageWithRect(partRect);
	}

	if (insets.right > 0 && insets.top > 0) {
		CGRect partRect = CGRectMake(self.size.width - insets.right, self.size.height - insets.top, insets.right, insets.top);
		topRight = imageWithRect(partRect);
	}

	if (insets.right > 0 && insets.bottom > 0) {
		CGRect partRect = CGRectMake(self.size.width - insets.right, 0, insets.right, insets.bottom);
		bottomRight = imageWithRect(partRect);
	}

	CGRect centerRect = CGRectMake(insets.left, insets.bottom, horizontalEdgeLength, verticalEdgeLength);
	if (centerRect.size.width > 0 && centerRect.size.height > 0) {
		center = imageWithRect(centerRect);
	}

	CGImageRelease(image);

	BOOL flipped = NO;
	if (respectFlipped) {
		flipped = [NSGraphicsContext.currentContext isFlipped];
	}

	if (topLeft != nil || bottomRight != nil) {
		NSDrawNinePartImage(dstRect, bottomLeft, bottomEdge, bottomRight, leftEdge, center, rightEdge, topLeft, topEdge, topRight, op, alpha, flipped);
	} else if (leftEdge != nil) {
		// Horizontal three-part image.
		NSDrawThreePartImage(dstRect, leftEdge, center, rightEdge, NO, op, alpha, flipped);
	} else {
		// Vertical three-part image.
		NSDrawThreePartImage(dstRect, (flipped ? bottomEdge : topEdge), center, (flipped ? topEdge : bottomEdge), YES, op, alpha, flipped);
	}
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	RBLResizableImage *image = [super copyWithZone:zone];
	image.capInsets = self.capInsets;
	return image;
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (self == nil) return nil;

	self.capInsets = NSEdgeInsetsMake(
		[coder decodeDoubleForKey:@"capInsetTop"],
		[coder decodeDoubleForKey:@"capInsetLeft"],
		[coder decodeDoubleForKey:@"capInsetBottom"],
		[coder decodeDoubleForKey:@"capInsetRight"]
	);

	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];

	[coder encodeDouble:self.capInsets.top forKey:@"capInsetTop"];
	[coder encodeDouble:self.capInsets.left forKey:@"capInsetLeft"];
	[coder encodeDouble:self.capInsets.bottom forKey:@"capInsetBottom"];
	[coder encodeDouble:self.capInsets.right forKey:@"capInsetRight"];
}

#pragma mark NSObject

- (BOOL)isEqual:(RBLResizableImage *)image {
	if (self == image) return YES;
	if (![image isKindOfClass:RBLResizableImage.class]) return NO;
	if (![super isEqual:image]) return NO;

	NSEdgeInsets a = self.capInsets;
	NSEdgeInsets b = image.capInsets;

	if (fabs(a.left - b.left) > 0.1) return NO;
	if (fabs(a.top - b.top) > 0.1) return NO;
	if (fabs(a.right - b.right) > 0.1) return NO;
	if (fabs(a.bottom - b.bottom) > 0.1) return NO;

	return YES;
}

- (NSString *)description {
	NSEdgeInsets insets = self.capInsets;
	return [NSString stringWithFormat:@"<%@: %p>{ size = %@, capInsets = (%f, %f, %f, %f) }", self.class, self, NSStringFromSize(self.size), insets.top, insets.left, insets.bottom, insets.right];
}

@end
