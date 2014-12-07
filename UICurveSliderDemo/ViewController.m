//
//  ViewController.m
//  UICurveSlider
//
//  Created by matthew on 14-12-7.
//  Copyright (c) 2014年 Matthew. All rights reserved.
//

#import "ViewController.h"
#import "UICurveSlider.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UICurveSlider *curveSlider;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.curveSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventValueChanged];
    self.curveSlider.minimumValue = 0;
    self.curveSlider.maximumValue = 100;
    self.curveSlider.continuous = NO;
    self.curveSlider.maximumTrackTintColor = [UIColor greenColor];
    self.curveSlider.sliderCenter = CGPointMake(140, 140);
    self.curveSlider.sliderRadius = 120;
    self.curveSlider.startAngel = M_PI_4*5;
    self.curveSlider.endAngel = M_PI_4*7;
    self.curveSlider.clockwise = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateProgress:(UICurveSlider *)sender
{
    NSLog(@"value:%.2f", sender.value);
}

@end
