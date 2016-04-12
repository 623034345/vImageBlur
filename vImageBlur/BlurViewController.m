//
//  BlurViewController.m
//  vImageBlur
//
//  Created by Kael on 16/4/12.
//  Copyright © 2016年 Kael. All rights reserved.
//

#import "BlurViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "UIImage+Blur.h"
@interface BlurViewController ()
@property (nonatomic, strong) UIImage *image1;
@property (nonatomic, strong) UIImage *image2;
@property (nonatomic, weak) UIImageView *view1;
@property (nonatomic, weak) UIImageView *view2;
@end

@implementation BlurViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    _image1=[UIImage imageNamed:@"abaddon"];
    
    CGSize imageSize=_image1.size;
    
    UIImageView *view1=[[UIImageView alloc]initWithImage:_image1];
    view1.frame=CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width/imageSize.width*imageSize.height);
    [self.view addSubview:_view1=view1];
    
    UIImageView *view2=[[UIImageView alloc]init];
    view2.frame=(CGRect){{0, CGRectGetMaxY(_view1.frame)+50}, _view1.frame.size};
    [view2 sd_setImageWithURL:[NSURL URLWithString:@"https://img.alicdn.com/imgextra/i3/373400920/TB2KIkfmVXXXXbYXXXXXXXXXXXX_!!373400920.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _image2=image;
    }];
    [self.view addSubview:_view2=view2];
    
    UISlider *slider=[[UISlider alloc]initWithFrame:CGRectMake(50, CGRectGetMaxY(view2.frame)+50, self.view.frame.size.width-100, 20)];
    slider.minimumValue=0.00;
    slider.maximumValue=1.00;
    [slider addTarget:self action:@selector(siliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:slider];
}

-(void)siliderValueChanged:(UISlider *)slider
{
    if (slider.value==0) {
        _view1.image=_image1;
        _view2.image=_image2;
    }
    else
    {
        _view1.image=[_image1 boxblurImageWithBlur:slider.value];
        _view2.image=[_image2 boxblurImageWithBlur:slider.value];
        
    }
    
}

@end
