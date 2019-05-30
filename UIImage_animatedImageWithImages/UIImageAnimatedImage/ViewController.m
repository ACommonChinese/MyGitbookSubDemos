//
//  ViewController.m
//  UIImageAnimatedImage
//
//  Created by liuweizhen on 2018/12/6.
//  Copyright © 2018 daliu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *images = @[
        [UIImage imageNamed:@"loading_1.png"],
        [UIImage imageNamed:@"loading_2.png"],
        [UIImage imageNamed:@"loading_3.png"],
        [UIImage imageNamed:@"loading_4.png"],
        [UIImage imageNamed:@"loading_5.png"]
    ];
    
    UIImage *image = [UIImage animatedImageWithImages:images duration:1];
    // self.imageView1.animationDuration = 2;
    self.imageView1.animationRepeatCount = 0;
    // self.imageView1.animationImages = images;
    // self.imageView1.image = nil;
    self.imageView1.image = image;
    [self.imageView1 startAnimating];
}

@end
