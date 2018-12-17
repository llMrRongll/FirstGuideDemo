//
//  RJGuideView.h
//  FirstGuideDemo
//
//  Created by RongJun on 2018/12/11.
//  Copyright © 2018 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RJGuideView : UIView

+ (RJGuideView *)sharedInstance;
- (void)prepareShowGuide;
- (void)show;

@property (strong, nonatomic) UIColor *guideViewBackgroundColor;
@property (strong, nonatomic) UIColor *introduceStringColor;

/// 确定按钮背景图片
@property (strong, nonatomic) UIImage *confirmButtonBackgroundImage;


@end

NS_ASSUME_NONNULL_END
