# FirstGuideDemo
新用户引导页面，镂空高亮显示控件
![截图](FirstGuideDemo/screenshot.png.png)
# 使用方法
1. 引入头文件
```
#import "RJGuide.h"
```
2. 设置要高亮显示的控件
```
[[RJGuideView sharedInstance] prepareShowGuide];
[RJGuideView sharedInstance].confirmButtonBackgroundImage = [UIImage imageNamed:@"buttonbg"];
self.button.showInGuideView = YES;
self.button.introduceString = @"测试按钮1";

self.button1.showInGuideView = YES;
self.button1.introduceString = @"测试按钮2";

self.button2.showInGuideView = YES;
self.button2.introduceString = @"测试按钮3";
[[RJGuideView sharedInstance] show];
```
3. 可以自定义的部分
```
/// 背景颜色
@property (strong, nonatomic) UIColor *guideViewBackgroundColor;

/// 控件描述文字的颜色
@property (strong, nonatomic) UIColor *introduceStringColor;

/// 确定按钮背景图片
@property (strong, nonatomic) UIImage *confirmButtonBackgroundImage;
```
