//
//  ViewController.m
//  FirstGuideDemo
//
//  Created by RongJun on 2018/12/11.
//  Copyright © 2018 RJ. All rights reserved.
//

#import "ViewController.h"
#import "RJGuide.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.button.showInGuideView = YES;
    self.button1.showInGuideView = YES;
    self.button2.showInGuideView = YES;
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [[RJGuideView sharedInstance] show];

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)buttonAction:(UIButton *)sender{
    sender.showInGuideView = !sender.showInGuideView;
}


@end
