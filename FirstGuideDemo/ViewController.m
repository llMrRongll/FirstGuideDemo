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
    self.contentView.showInGuideView = YES;
    self.contentView.introduceString = @"测试容器";
    
    self.button.showInGuideView = YES;
    self.button.introduceString = @"测试按钮1";
    self.button1.showInGuideView = YES;
    self.button1.introduceString = @"测试按钮2";

    self.button2.showInGuideView = YES;
    self.button2.introduceString = @"测试按钮3";

    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    

    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)buttonAction:(UIButton *)sender{
//    sender.showInGuideView = !sender.showInGuideView;
    [[RJGuideView sharedInstance] show];
}


@end
