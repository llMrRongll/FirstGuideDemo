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
    UIBezierPath *_basePath;
    int guideIndex;
}

+ (id)sharedInstance{
    static RJGuideView *guideView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        guideView = [[self alloc] init];
    });
    return guideView;
}

- (instancetype)init{
    if(self = [super init]){
        self.frame = [UIScreen mainScreen].bounds;
        [self initPath];
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
        if([self getControllerFromView:notification.object]){
            [_showGuideViews addObject:notification.object];
        }
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
    UIDevice *device = notification.object;
    self.frame = [UIScreen mainScreen].bounds;
    [self initPath];
    [self setNeedsDisplay];
}

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

- (void)prepareShowGuide{
    //prepare
}

- (void)show{
    if(_presented){
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
    [self removeFromSuperview];
    _presented = NO;
}


- (void)initPath{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(0, self.bounds.size.height)];
    [path addLineToPoint:CGPointZero];
    _basePath = path;
}

- (void)addLineToBasePathWithCustomView:(UIView *)customView{
    CGRect convertedFrame = [customView.superview convertRect:customView.frame toView:self];
    [_basePath moveToPoint:CGPointMake(convertedFrame.origin.x, convertedFrame.origin.y)];
    [_basePath addLineToPoint:CGPointMake(CGRectGetMaxX(convertedFrame), convertedFrame.origin.y)];
    [_basePath addLineToPoint:CGPointMake(CGRectGetMaxX(convertedFrame), CGRectGetMaxY(convertedFrame))];
    [_basePath addLineToPoint:CGPointMake(convertedFrame.origin.x, CGRectGetMaxY(convertedFrame))];
    [_basePath addLineToPoint:CGPointMake(convertedFrame.origin.x, convertedFrame.origin.y)];
}

/*
 * 判断view处于当前引导view中的的位置
 */
- (ViewPosition)getViewPositionWithView:(UIView *)view{
    CGRect convertedFrame = [view.superview convertRect:view.frame toView:self];
    CGPoint viewCenter = CGPointMake(CGRectGetMidX(convertedFrame), CGRectGetMidY(convertedFrame));
    if(viewCenter.y < CGRectGetMidY(self.frame)){
        return ViewPosition_Top;
    } else{
        return ViewPosition_Bottom;
    }
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSArray *tmpArray = _showGuideViews;
    if(tmpArray.count > 0){
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = rect;
        UIView *tmpView = tmpArray[guideIndex];
        [self addLineToBasePathWithCustomView:tmpView];
        
        shapeLayer.path = _basePath.CGPath;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        self.layer.mask = shapeLayer;
        
        NSString *testString = @"testString";
        CGRect convertedFrame = [tmpView.superview convertRect:tmpView.frame toView:self];
        [testString drawAtPoint:CGPointMake(CGRectGetMidX(convertedFrame), CGRectGetMaxY(convertedFrame)) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor whiteColor]}];
        _presented = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self dismiss];
    if(guideIndex < _showGuideViews.count - 1){
        guideIndex+=1;
        [self initPath];
        [self setNeedsDisplay];
    } else {
        [self dismiss];
    }
}


@end
