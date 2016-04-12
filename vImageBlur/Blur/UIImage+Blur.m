//
//  UIImage+Blur.m
//  Items4Dota2
//
//  Created by Kael on 16/4/8.
//  Copyright © 2016年 Kael. All rights reserved.
//

#import "UIImage+Blur.h"
#import <Accelerate/Accelerate.h>
#import <objc/runtime.h>
#import <ImageIO/ImageIO.h>
static NSString *alpaInfoKey;
@implementation UIImage (Blur)

-(CGImageAlphaInfo)getAlphaInfo
{
    NSNumber *infoObj=objc_getAssociatedObject(self, &alpaInfoKey);
    if (!infoObj) {
        NSData *data=UIImagePNGRepresentation(self);
        if (!data) {
            data=UIImageJPEGRepresentation(self,1);
        }
        CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,NULL);
        
        CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0,NULL);
        
        id obj=CFDictionaryGetValue(imageInfo,@"HasAlpha");
        infoObj=obj?@(kCGImageAlphaNoneSkipFirst):@(kCGImageAlphaNoneSkipLast);
        objc_setAssociatedObject(self, &alpaInfoKey, infoObj, OBJC_ASSOCIATION_RETAIN);
    }
    return (CGImageAlphaInfo)[infoObj intValue];
}

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = self.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"JFDepthView: error from convolution %ld", error);
    }
    
    uint32_t bitmapInfo=[self getAlphaInfo];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             bitmapInfo);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end


