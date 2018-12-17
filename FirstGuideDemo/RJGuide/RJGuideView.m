//
//  RJGuideView.m
//  FirstGuideDemo
//
//  Created by RongJun on 2018/12/11.
//  Copyright © 2018 RJ. All rights reserved.
//

#import "RJGuideView.h"
#import "Const.h"
#import "UIView+Guide.h"

@implementation RJGuideView
{
    BOOL _presented;
    NSMutableArray * _showGuideViews;
    int _guideIndex;
    CGRect _touchArea;
}

+ (RJGuideView *)sharedInstance{
    static RJGuideView *guideView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        guideView = [[self alloc] init];
        guideView.backgroundColor = [UIColor clearColor];
    });
    return guideView;
}

- (instancetype)init{
    if(self = [super init]){
        self.frame = [UIScreen mainScreen].bounds;
        self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        _showGuideViews = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addView:) name:RJGUIDE_NOTIFICATION_TYPE_ADD_VIEW object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeView:) name:RJGUIDE_NOTIFICATION_TYPE_REMOVE_VIEW object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
   
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RJGUIDE_NOTIFICATION_TYPE_REMOVE_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RJGUIDE_NOTIFICATION_TYPE_ADD_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma NotificationObserver
- (void)addView:(NSNotification *)notification{
    if(![_showGuideViews containsObject:notification.object]){
        [_showGuideViews addObject:notification.object];
    }
    NSLog(@"views count %ld", _showGuideViews.count);
}

- (void)removeView:(NSNotification *)notification{
    if([_showGuideViews containsObject:notification.object]){
        [_showGuideViews removeObject:notification.object];
    }
    NSLog(@"views count %ld", _showGuideViews.count);
    
}
// 适配一下屏幕旋转
- (void)screenOrientationChanged:(NSNotification *)notification{
    self.frame = [UIScreen mainScreen].bounds;
    [self setNeedsDisplay];
}

// 获取view对应所属的控制器
- (UIViewController *)getControllerFromView:(UIView *)view {
    // 遍历响应者链。返回第一个找到视图控制器
    UIResponder *responder = view;
    while ((responder = [responder nextResponder])){
        if ([responder isKindOfClass: [UIViewController class]]){
            NSLog(@"%@", responder.class);
            return (UIViewController *)responder;
        }
    }
    // 如果没有找到则返回nil
    return nil;
}

// 获取当前控制器
-  (UIViewController *)getCurrentVC {
    for (UIWindow *window in [UIApplication sharedApplication].windows.reverseObjectEnumerator) {
        
        UIView *tempView = window.subviews.lastObject;
        
        for (UIView *subview in window.subviews.reverseObjectEnumerator) {
            if ([subview isKindOfClass:NSClassFromString(@"UILayoutContainerView")]) {
                tempView = subview;
                break;
            }
        }
        
        BOOL(^canNext)(UIResponder *) = ^(UIResponder *responder){
            if (![responder isKindOfClass:[UIViewController class]]) {
                return YES;
            } else if ([responder isKindOfClass:[UINavigationController class]]) {
                return YES;
            } else if ([responder isKindOfClass:[UITabBarController class]]) {
                return YES;
            } else if ([responder isKindOfClass:NSClassFromString(@"UIInputWindowController")]) {
                return YES;
            }
            return NO;
        };
        
        UIResponder *nextResponder = tempView.nextResponder;
        
        while (canNext(nextResponder)) {
            tempView = tempView.subviews.firstObject;
            if (!tempView) {
                return nil;
            }
            nextResponder = tempView.nextResponder;
        }
        
        UIViewController *currentVC = (UIViewController *)nextResponder;
        if (currentVC) {
            return currentVC;
        }
    }
    return nil;
    
}

- (void)prepareShowGuide{
    //prepare
    _guideIndex = 0;
    [_showGuideViews removeAllObjects];

}

- (void)show{
    [self dismiss];
    UIViewController *currentVC = [self getCurrentVC];
    for(int i = 0; i < _showGuideViews.count;){
        UIView *tmpView = _showGuideViews[i];
        UIViewController *vc = [self getControllerFromView:tmpView];
        if(vc == nil || ![currentVC isEqual:vc]){
            NSLog(@"删除");
            [_showGuideViews removeObjectAtIndex:i];
            i = 0;
        } else {
            i++;
        }
    }
    if(_showGuideViews.count == 0){
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *w = [[UIApplication sharedApplication] delegate].window;
        [w addSubview:self];
        [w bringSubviewToFront:self];
        [self setNeedsDisplay];
    });
    
}

- (void)dismiss{
    _presented = NO;
    _guideIndex = 0;
    [self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSArray *tmpArray = _showGuideViews;
    if(tmpArray.count > 0){
        UIView *tmpView = tmpArray[_guideIndex];
        
        CGRect convertedFrame = [tmpView.superview convertRect:tmpView.frame toView:self];
        CGFloat(^calculateDistance)(CGPoint point1, CGPoint point2) = ^(CGPoint point1, CGPoint point2) {
            CGFloat distance = sqrtf(powf(point1.x - point2.x, 2) + powf(point1.y - point2.y, 2));
            return distance;
        };
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, rect);

        
        CGMutablePathRef backgroundPath = CGPathCreateMutable();
        CGFloat parentRatio = calculateDistance(self.bounds.origin, CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)));
        CGPathAddArc(backgroundPath, nil, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), parentRatio, 0, -2*M_PI, YES);
        CGContextAddPath(context, backgroundPath);
        CGRect tuoyuanRect = convertedFrame;

        if(convertedFrame.size.width < self.bounds.size.width*0.8){
            tuoyuanRect = CGRectMake(convertedFrame.origin.x - convertedFrame.size.width*0.2, convertedFrame.origin.y - convertedFrame.size.height*0.2, convertedFrame.size.width*1.4, convertedFrame.size.height*1.4);
            CGContextAddEllipseInRect(context, tuoyuanRect);

        } else {
            CGContextAddRect(context, convertedFrame);
        }
        
        // 设置填充背景颜色
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.6);
        if(self.guideViewBackgroundColor){
            [self.guideViewBackgroundColor setFill];
        }
        
        // 填充背景路径
        CGContextEOFillPath(context);
        
        // 绘制介绍文字
        NSString *introduceString = tmpView.introduceString;
        NSMutableParagraphStyle *introduceStringParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        introduceStringParagraphStyle.lineBreakMode = NSLineBreakByClipping;
        CGSize introduceStringSize = [introduceString sizeWithAttributes:@{
                                                                           NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                           NSForegroundColorAttributeName: self.introduceStringColor? self.introduceStringColor : [UIColor whiteColor],
                                                                           NSParagraphStyleAttributeName: introduceStringParagraphStyle
                                                                           }];
        CGRect introduceStringRect = CGRectMake(CGRectGetMidX(tuoyuanRect) - introduceStringSize.width/2, CGRectGetMaxY(tuoyuanRect)+10, introduceStringSize.width, introduceStringSize.height);
        
        // 判断介绍文字绘制的位置
        if(CGRectGetMaxY(introduceStringRect) > self.bounds.size.height){
            introduceStringRect = CGRectMake(CGRectGetMidX(tuoyuanRect) - introduceStringSize.width/2, CGRectGetMinY(tuoyuanRect)-10-introduceStringSize.height, introduceStringSize.width, introduceStringSize.height);
        }
        NSDictionary *attrDic = @{
                                  NSFontAttributeName:[UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName: [UIColor whiteColor],
                                  NSParagraphStyleAttributeName: introduceStringParagraphStyle
                                  };
        

        [introduceString drawInRect:introduceStringRect withAttributes:attrDic];
        
        // 绘制确定按钮
        
        
        _touchArea = CGRectMake(CGRectGetMidX(rect) - 40, CGRectGetMaxY(rect) - 80, 80, 40);
        if(CGRectGetMaxY(convertedFrame) >= _touchArea.origin.y || abs((int)(_touchArea.origin.y-CGRectGetMaxY(convertedFrame))) <= rect.size.height*0.15){
            _touchArea = CGRectMake(CGRectGetMidX(rect) - 40, CGRectGetMidY(rect) - 80, 80, 40);
        }
        if(self.confirmButtonBackgroundImage){
            [self.confirmButtonBackgroundImage drawInRect:_touchArea];
        }
        
        NSString *buttonTitle = @"知道了";
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        
        CGSize buttonTitleSize = [buttonTitle sizeWithAttributes:@{
                                                                   NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                                   NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                   NSParagraphStyleAttributeName:paragraphStyle
                                                                   }];
        [buttonTitle drawInRect:CGRectMake(_touchArea.origin.x, CGRectGetMidY(_touchArea)-buttonTitleSize.height/2, _touchArea.size.width, buttonTitleSize.height) withAttributes:@{
                                                            NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                                            NSParagraphStyleAttributeName:paragraphStyle
                                                            }];
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *oneTouch = [[touches allObjects] lastObject];
    CGPoint touchLocation = [oneTouch locationInView:self];
    if(CGRectContainsPoint(_touchArea, touchLocation)){
        if(_guideIndex < _showGuideViews.count - 1){
            _guideIndex+=1;
        } else {
            [_showGuideViews removeAllObjects];
            [self dismiss];
        }
        [self setNeedsDisplay];
    }
    
    

}


@end
