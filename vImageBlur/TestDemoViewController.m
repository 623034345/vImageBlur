//
//  TestDemoViewController.m
//  vImageBlur
//
//  Created by Kael on 16/4/12.
//  Copyright © 2016年 Kael. All rights reserved.
//

#import "TestDemoViewController.h"
#import "ViewController.h"
#import <Accelerate/Accelerate.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import <ImageIO/ImageIO.h>
@interface TestDemoViewController ()
@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, weak) UIImageView *view1;
@property (nonatomic, weak) UIImageView *view2;
@property (nonatomic, weak) UISlider *slider;
@end

@implementation TestDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
}

-(void)demo1
{
    _image1=[UIImage imageNamed:@"abaddon"];
    
    [self readExif:_image1];
    NSLog(@"image1-%@",[self typeForImageData:UIImagePNGRepresentation(_image1)]);
    
    CGSize imageSize=_image1.size;
    
    UIImageView *view1=[[UIImageView alloc]initWithImage:_image1];
    view1.frame=CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width/imageSize.width*imageSize.height);
    [self.view addSubview:_view1=view1];
    
    
    UISlider *slider=[[UISlider alloc]initWithFrame:CGRectMake(50, CGRectGetMaxY(view1.frame)+50, self.view.frame.size.width-100, 20)];
    slider.minimumValue=0.00;
    slider.maximumValue=1.00;
    [slider addTarget:self action:@selector(siliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_slider=slider];
}

-(void)demo2
{
    [self demo1];
    UIImageView *view2=[[UIImageView alloc]init];
    view2.frame=(CGRect){{0, CGRectGetMaxY(_view1.frame)+50}, _view1.frame.size};
    [view2 sd_setImageWithURL:[NSURL URLWithString:@"https://img.alicdn.com/imgextra/i3/373400920/TB2KIkfmVXXXXbYXXXXXXXXXXXX_!!373400920.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _image2=image;
        [self readExif:_image2];
    }];
    [self.view addSubview:_view2=view2];
    _slider.frame=CGRectMake(50, CGRectGetMaxY(view2.frame)+50, self.view.frame.size.width-100, 20);
}

-(void)siliderValueChanged:(UISlider *)slider
{
    if (slider.value==0) {
        _view1.image=_image1;
        _view2.image=_image2;
    }
    else
    {
        _view1.image=[self boxblurImageWithBlur:slider.value oImg:_image1];
        if (_image2) {
            _view2.image=[self boxblurImageWithBlur:slider.value oImg:_image2];
        }
        
    }
    
}

-(void)readExif:(UIImage *)image
{
    NSData *data=UIImagePNGRepresentation(image);
    CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data,NULL);
    
    CFDictionaryRef imageInfo = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0,NULL);
    
    NSLog(@"imageInfo-%@",imageInfo);
}


-(NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur oImg:(UIImage *)oImg{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = oImg.CGImage;
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
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
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