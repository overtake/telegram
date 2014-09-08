//
//  ImageUtils.m
//  TelegramTest
//
//  Created by keepcoder on 26.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#import "ImageUtils.h"
#import <Accelerate/Accelerate.h>

#define CACHE_IMAGE(Name) NSImage* image_##Name () { \
static NSImage *image;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
image = [NSImage imageNamed:@""#Name]; \
}); \
return image; \
}


CACHE_IMAGE(actions)
CACHE_IMAGE(actionsActive)
CACHE_IMAGE(actionsHover)
CACHE_IMAGE(addContact)
CACHE_IMAGE(AddSharedContact)
CACHE_IMAGE(AddSharedContactHighlighted)
CACHE_IMAGE(AppIcon)
CACHE_IMAGE(AttachFile)
CACHE_IMAGE(AttachFileHighlighted)
CACHE_IMAGE(AttachHighlighted)
CACHE_IMAGE(AttachLocation)
CACHE_IMAGE(AttachLocationHighlighted)
CACHE_IMAGE(AttachPhotoVideo)
CACHE_IMAGE(AttachPhotoVideoHighlighted)
CACHE_IMAGE(AttachTakePhoto)
CACHE_IMAGE(AttachTakePhotoHighlighted)
CACHE_IMAGE(BottomAttach)
CACHE_IMAGE(boxBack)
CACHE_IMAGE(CancelDownload)
CACHE_IMAGE(chat)
CACHE_IMAGE(chatHighlighted)
CACHE_IMAGE(ChatMessageError)
CACHE_IMAGE(checked)
CACHE_IMAGE(ScrollDownArrow)
CACHE_IMAGE(clear)
CACHE_IMAGE(clearActive)
CACHE_IMAGE(clearHover)
CACHE_IMAGE(ClosePopupDialog)
CACHE_IMAGE(compose)
CACHE_IMAGE(composeActive)
CACHE_IMAGE(composeHover)
CACHE_IMAGE(Download)
CACHE_IMAGE(emojiContainer1)
CACHE_IMAGE(emojiContainer1Highlighted)
CACHE_IMAGE(emojiContainer2)
CACHE_IMAGE(emojiContainer2Highlighted)
CACHE_IMAGE(emojiContainer3)
CACHE_IMAGE(emojiContainer3Highlighted)
CACHE_IMAGE(emojiContainer4)
CACHE_IMAGE(emojiContainer4Highlighted)
CACHE_IMAGE(emojiContainer5)
CACHE_IMAGE(emojiContainer5Highlighted)
CACHE_IMAGE(emojiContainer6)
CACHE_IMAGE(emojiContainer6Highlighted)
CACHE_IMAGE(emojiContainer7)
CACHE_IMAGE(emojiContainer7Highlighted)
CACHE_IMAGE(GIFPlay)
CACHE_IMAGE(group)
CACHE_IMAGE(HeaderDropdownArrow)
CACHE_IMAGE(iconCancelDownload)
CACHE_IMAGE(kick)
CACHE_IMAGE(logo)
CACHE_IMAGE(logoAbout)
CACHE_IMAGE(MessageFile)
CACHE_IMAGE(MessageFileCancel)
CACHE_IMAGE(MessageFileDownload)
CACHE_IMAGE(MessageMapPin)
CACHE_IMAGE(muted)
CACHE_IMAGE(mutedSld)
CACHE_IMAGE(noDialogs)
CACHE_IMAGE(noResults)
CACHE_IMAGE(searchIcon)
CACHE_IMAGE(secret)
CACHE_IMAGE(secretBlack)
CACHE_IMAGE(secretGray)
CACHE_IMAGE(secretHiglighted)
CACHE_IMAGE(select)
CACHE_IMAGE(selectPopup)
CACHE_IMAGE(smile)
CACHE_IMAGE(smileActive)
CACHE_IMAGE(smileHover)
CACHE_IMAGE(typingGIF)
CACHE_IMAGE(unchecked)
CACHE_IMAGE(uncheckedHover)
CACHE_IMAGE(UnpinPhoto)
CACHE_IMAGE(VideoPlay)
CACHE_IMAGE(DialogSelectedSendError)
CACHE_IMAGE(VoiceMessageCancel)
CACHE_IMAGE(VoiceMessageDownload)
CACHE_IMAGE(VoiceMessagePause)
CACHE_IMAGE(VoiceMessagePlay)
CACHE_IMAGE(VoiceMessageUpload)
CACHE_IMAGE(VoiceMic)
CACHE_IMAGE(VoiceMicHighlighted)
CACHE_IMAGE(VoiceMicHighlighted2)
CACHE_IMAGE(TelegramNotifications)




@implementation ImageUtils

NSImage *previewImageForDocument(NSString *path) {
    int sizeSquere = IS_RETINA ? 200 : 100;
    
    CGImageRef quickLookIcon = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)[NSURL fileURLWithPath:path], CGSizeMake(sizeSquere * 2, sizeSquere * 2), nil);
    
    NSImage *thumbIcon = nil;
    
    if (quickLookIcon != NULL) {
        thumbIcon = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSMakeSize(0, 0)];
        CFRelease(quickLookIcon);
    }

    if(!thumbIcon)
        return nil;
    
    NSSize needSize = NSMakeSize(100, 100);
    NSRect rect;
    if(thumbIcon.size.width > thumbIcon.size.height) {
        float k = thumbIcon.size.height / needSize.height;
        float width = roundf(thumbIcon.size.width / k);
        rect = NSMakeRect(-roundf((width - needSize.width) / 2), 0, width, needSize.height);
    } else {
        float k = thumbIcon.size.width / needSize.width;
        float height = roundf(thumbIcon.size.height / k);
        rect = NSMakeRect(0, -roundf((height - needSize.height) / 2), needSize.width, height);
    }
    
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(100, 100)];
    [image lockFocus];
    [thumbIcon drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    [image unlockFocus];
    
    
    return image;
}

+ (NSImage*)roundCorners:(NSImage *)image size:(NSSize)size
{
    
    if(!image)
        return image;
    NSImage *existingImage = image;
    NSSize existingSize = [existingImage size];
    NSSize newSize = NSMakeSize(existingSize.width, existingSize.height);
    
    
    NSImage *composedImage = [[NSImage alloc] initWithSize:newSize];
    
    [composedImage lockFocus];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    
    NSRect imageFrame = NSRectFromCGRect(CGRectMake(1, 1, image.size.width-1, image.size.height-1));
    
    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:imageFrame xRadius:size.width yRadius:size.height];
    [clipPath setWindingRule:NSEvenOddWindingRule];
    [clipPath addClip];
    
    [image drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositeSourceOver fraction:1];
    
    [composedImage unlockFocus];
    
    return composedImage;
}

+ (NSImage *)blurImage:(NSImage *)image blurRadius:(int)radius frameSize:(CGSize)size {
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)[image TIFFRepresentation], NULL);
    
    NSImage *newImage = nil;
    if(source != NULL) {
        CGImageRef imageRef =  CGImageSourceCreateImageAtIndex(source, 0, NULL);
        CFRelease(source);
        
        CGContextRef context = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                     size.width,
                                                     size.height,
                                                     8 /*bitsPerComponent*/,
                                                     0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                     [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                     kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
        
        CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), imageRef);
        CGImageRef cgImage = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        
        
        CGImageRef cgBlurImage = CGImageCreateBlurredImage(cgImage, radius);
        //    CGImageRelease(imageRef);
        CGImageRelease(cgImage);
        
        newImage = [[NSImage alloc] initWithCGImage:cgBlurImage size:size];
        CGImageRelease(imageRef);
        CGImageRelease(cgBlurImage);
    }
    return newImage;
}

CGImageRef CGImageCreateBlurredImage(CGImageRef inImage, NSUInteger blurRadius)
{
    blurRadius = (blurRadius % 2) ? blurRadius : blurRadius + 1; // blurRadius must be odd
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    size_t bytesPerRow = CGImageGetBytesPerRow(inImage);
    
    //    DLog(@"width %zu", width);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(inImage);
    CFDataRef dataRef = CGDataProviderCopyData(CGImageGetDataProvider(inImage));
    void *destinationData = malloc(bytesPerRow * height);
    
    vImage_Buffer sourceBuffer = {(void *)CFDataGetBytePtr(dataRef), height, width, bytesPerRow};
    vImage_Buffer destinationBuffer = {destinationData, height, width, bytesPerRow};
    // Tent convolve is within 3% of a gaussian blur.
    vImageTentConvolve_ARGB8888(&sourceBuffer, &destinationBuffer, NULL, 0, 0,(uint32_t) blurRadius, (uint32_t)blurRadius, NULL, kvImageEdgeExtend);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(destinationData, width, height, 8, bytesPerRow, colorSpace, bitmapInfo);
    CGImageRef outImage = CGBitmapContextCreateImage(imageContext);
    
    CFRelease(dataRef);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(imageContext);
    free(destinationData);
    return outImage;
}


NSImage *TGIdenticonImage(NSData *data, CGSize size)
{
    
    uint8_t bits[128];
    memset(bits, 0, 128);
    
    [data getBytes:bits length:MIN(128, data.length)];
    
    static CGColorRef colors[6];
    
    //int ptr = 0;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      static const int textColors[] =
                      {
                          0xffffff,
                          0xd5e6f3,
                          0x2d5775,
                          0x2f99c9
                      };
                      
                      for (int i = 0; i < 4; i++)
                      {
                          colors[i] = CGColorRetain(NSColorFromRGB(textColors[i]).CGColor);
                      }
                  });
    
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0,CGColorSpaceCreateDeviceRGB(),kCGImageAlphaPremultipliedLast);
    
    int bitPointer = 0;
    
    float rectSize = floorf(size.width / 8.0f);
    
    for (int iy = 7; iy >= 0; iy--)
    {
        for (int ix = 0; ix < 8; ix++)
        {
            int32_t byteValue = get_bits(bits, bitPointer, 2);
            bitPointer += 2;
            int colorIndex = ABS(byteValue) % 4;
            
            
            CGContextSetFillColorWithColor(context, colors[colorIndex]);
            CGContextFillRect(context, CGRectMake(ix * rectSize, iy * rectSize, rectSize, rectSize));
        }
    }
    
    
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    
    
    NSImage *image = [[NSImage alloc] initWithCGImage:cgImage size:size];
    
    CGContextRelease(context);
    CGImageRelease(cgImage);
    
    return image;
}

static int32_t get_bits(uint8_t const *bytes, unsigned int bitOffset, unsigned int numBits)
{
    uint8_t const *data = bytes;
    numBits = (unsigned int)pow(2, numBits) - 1; //this will only work up to 32 bits, of course
    data += bitOffset / 8;
    bitOffset %= 8;
    return (*((int*)data) >> bitOffset) & numBits;
}


NSImage *cropCenterWithSize(NSImage *image, NSSize cropSize) {
    if(!image)
        return nil;
    
    NSImage *result = [[NSImage alloc] initWithSize:cropSize];
    
    NSRect cropedRect;
    
    if(image.size.width > image.size.height) {
        cropedRect = NSMakeRect(ceil((image.size.width - image.size.height) / 2), 0, image.size.height, image.size.height);
    } else {
        cropedRect = NSMakeRect(0, ceil((image.size.height - image.size.width) / 2), image.size.width, image.size.width);
    }
    
    [result lockFocus];
    [image drawInRect:NSMakeRect(0, 0, result.size.width, result.size.height)
             fromRect:cropedRect
            operation:NSCompositeSourceOver
             fraction:1.0];
    [result unlockFocus];
    return result;
}

NSData* compressImage(NSData *data, float coef) {
    NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:data];
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:coef] forKey:NSImageCompressionFactor];
    NSData *compressedData = [imageRep representationUsingType:NSJPEGFileType properties:options];
    return compressedData;
}


NSImage *imageFromFile(NSString *filePath) {
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:filePath];
    return img;
}


NSImage *prettysize(NSImage *img) {
    if(img.representations.count > 0) {
        
        NSSize size = img.size;
        for (NSImageRep * imageRep in img.representations) {
            if ([imageRep pixelsWide] > size.width)
                size.width = [imageRep pixelsWide];
            if ([imageRep pixelsHigh] > size.height)
                size.height = [imageRep pixelsHigh];
        }
        img.size = size;
    }
    
    return img;
}

NSImage* strongResize(NSImage *image, int maxSize) {
    float scale = 1.0;
    NSImage *img = [image copy];
    
    if(img.size.width < maxSize && img.size.height < maxSize)
        return img;
    
    if(img.size.width > maxSize) {
        scale = maxSize/(float)img.size.width;
        img = [ImageUtils imageResize:img newSize:NSMakeSize(img.size.width * scale, img.size.height * scale)];
    }
    
    if(img.size.height > maxSize) {
        scale = maxSize/(float)img.size.height;
        img = [ImageUtils imageResize:img newSize:NSMakeSize(img.size.width * scale, img.size.height*scale)];
    }
    
    
    return prettysize(img);
}

NSSize strongsize(NSSize from, float max)  {
    float scale;
    if (from.width > max) {
        scale = max/from.width;
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
    if(from.height > max) {
        scale = max/from.height;
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
    return from;
}

NSSize resizeToMaxCorner(NSSize from, float size) {
    NSSize newSize;
    
    if(from.width < 90)
        from.width = 90;
    
    if(from.height < 90)
        from.height = 90;
    
    if(from.width > from.height) {
        float k = from.width / size;
        newSize.width = size;
        newSize.height = ceil(from.height / k);
    } else {
        float k = from.height / size;
        newSize.height = size;
        newSize.width = ceil(from.width / k);
    }
    
    
    return newSize;
}

NSSize strongsizeWithMinMax(NSSize from, float min, float max) {
    float scale;
    
    if (from.width > max) {
        scale = max/from.width;
        if(!scale) {
            DLog(@"");
        }
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
 
    if(from.height > max) {
        scale = max/from.height;
        if(!scale) {
            DLog(@"");
        }
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
    
    if(from.width < min) {
        scale = min / from.width;
        if(!scale) {
            DLog(@"");
        }
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
    
    if(from.height < min) {
        scale = min / from.height;
        if(!scale) {
            DLog(@"");
        }
        from.width = ceil(from.width * scale);
        from.height = ceil(from.height * scale);
    }
   
    if(from.width > max)
        from.width = max;
    
    if(from.height > max)
        from.height = max;
    
    if(isnan(from.width) || isnan(from.height)) {
        
    }
    return from;
}



+ (NSImage *)imageResize:(NSImage*)anImage newSize:(NSSize)newSize {
    NSImage *sourceImage = anImage;
    [sourceImage setScalesWhenResized:YES];
    
    if (![sourceImage isValid]) {
        DLog(@"Invalid Image");
    } else {

        NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
        [smallImage lockFocus];
        [sourceImage setSize: newSize];
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
        [sourceImage drawAtPoint:NSMakePoint(0, 0) fromRect:NSZeroRect operation:NSCompositeCopy fraction:1];
        [smallImage unlockFocus];
        return smallImage;
    }
    return nil;
}


@end
