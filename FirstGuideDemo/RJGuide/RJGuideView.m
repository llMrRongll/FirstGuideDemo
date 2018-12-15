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
    int guideIndex;
}

+ (id)sharedInstance{
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
    
}

- (void)addLineToBasePathWithCustomView:(UIView *)customView{

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
        UIView *tmpView = tmpArray[guideIndex];
        CGRect convertedFrame = [tmpView.superview convertRect:tmpView.frame toView:self];
        CGRect topRect = CGRectMake(self.bounds.origin.x, self.frame.origin.y, self.bounds.size.width, convertedFrame.origin.y);
        CGRect middleLeft = CGRectMake(self.bounds.origin.x, convertedFrame.origin.y, convertedFrame.origin.x, CGRectGetHeight(convertedFrame));
        CGRect middleRight = CGRectMake(CGRectGetMaxX(convertedFrame), convertedFrame.origin.y, CGRectGetMaxX(self.bounds) - CGRectGetMaxX(convertedFrame), CGRectGetHeight(convertedFrame));
        CGRect bottomRect = CGRectMake(self.bounds.origin.x, CGRectGetMaxY(convertedFrame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(convertedFrame));
        
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextClearRect(context, rect);
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.6);
        CGContextFillRect(context, topRect);
        CGContextFillRect(context, middleLeft);
        CGContextFillRect(context, middleRight);
        CGContextFillRect(context, bottomRect);
        
        NSString *introduceString = tmpView.introduceString;
        
        CGSize introduceStringSize = [introduceString sizeWithAttributes:@{
                                                                           NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                           }];
        CGRect introduceStringRect = CGRectMake(CGRectGetMidX(convertedFrame) - introduceStringSize.width/2, CGRectGetMaxY(convertedFrame)+10, introduceStringSize.width, introduceStringSize.height);
        [introduceString drawInRect:introduceStringRect withAttributes:@{
                                                                         NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                                         NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                         }]	;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self dismiss];
    if(guideIndex < _showGuideViews.count - 1){
        guideIndex+=1;
    } else {
        guideIndex = 0;
        [self dismiss];
    }
    [self initPath];
    [self setNeedsDisplay];

}


@end
