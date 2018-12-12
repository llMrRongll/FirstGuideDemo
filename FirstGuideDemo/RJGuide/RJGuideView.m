//
//  RJGuideView.m
//  FirstGuideDemo
//
//  Created by RongJun on 2018/12/11.
//  Copyright © 2018 RJ. All rights reserved.
//

#import "RJGuideView.h"
#import "Const.h"

@implementation RJGuideView
{
    BOOL _presented;
    NSMutableArray * _showGuideViews;
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
        self.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        _showGuideViews = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addView:) name:RJGUIDE_NOTIFICATION_TYPE_ADD_VIEW object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeView:) name:RJGUIDE_NOTIFICATION_TYPE_REMOVE_VIEW object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RJGUIDE_NOTIFICATION_TYPE_REMOVE_VIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RJGUIDE_NOTIFICATION_TYPE_ADD_VIEW object:nil];
}

- (void)addView:(NSNotification *)noti{
    if(![_showGuideViews containsObject:noti.object]){
        if([self getControllerFromView:noti.object]){
            [_showGuideViews addObject:noti.object];
        }
    }
    NSLog(@"views count %ld", _showGuideViews.count);
}

- (void)removeView:(NSNotification *)noti{
    if([_showGuideViews containsObject:noti.object]){
        [_showGuideViews removeObject:noti.object];
    }
    NSLog(@"views count %ld", _showGuideViews.count);
    
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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    NSArray *tmpArray = _showGuideViews;
    
    if(tmpArray.count > 0){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.frame = rect;
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointZero];
        [path addLineToPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
        [path addLineToPoint:CGPointMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [path addLineToPoint:CGPointMake(0, [UIScreen mainScreen].bounds.size.height)];
        [path addLineToPoint:CGPointZero];
        for (int i = 0; i < tmpArray.count; i++) {
            UIView *tmpView = tmpArray[i];
            CGRect convertedFrame = [tmpView.superview convertRect:tmpView.frame toView:self];
//            CGMutablePathRef path = CGPathCreateMutable();
//            CGPathMoveToPoint(path, nil, convertedFrame.origin.x, convertedFrame.origin.y);
//            CGPathAddLineToPoint(path, nil, CGRectGetMaxX(convertedFrame), convertedFrame.origin.y);
//            CGPathAddLineToPoint(path, nil, CGRectGetMaxX(convertedFrame), CGRectGetMaxY(convertedFrame));
//            CGPathAddLineToPoint(path, nil, convertedFrame.origin.x, CGRectGetMaxY(convertedFrame));
//            CGPathAddLineToPoint(path, nil, convertedFrame.origin.x, convertedFrame.origin.y);
//            CGContextAddPath(context, path);
//            CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
//            CGContextSetLineWidth(context, 1);
//            CGContextSetLineCap(context, kCGLineCapRound);
//            CGContextDrawPath(context, kCGPathStroke);
//            CGPathRelease(path);
            
            [path moveToPoint:CGPointMake(convertedFrame.origin.x, convertedFrame.origin.y)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(convertedFrame), convertedFrame.origin.y)];
            [path addLineToPoint:CGPointMake(CGRectGetMaxX(convertedFrame), CGRectGetMaxY(convertedFrame))];
            [path addLineToPoint:CGPointMake(convertedFrame.origin.x, CGRectGetMaxY(convertedFrame))];
            [path addLineToPoint:CGPointMake(convertedFrame.origin.x, convertedFrame.origin.y)];
        }
        shapeLayer.path = path.CGPath;
        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        self.layer.mask = shapeLayer;
        
        _presented = YES;

    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self dismiss];
}


@end
