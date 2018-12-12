//
//  UIView+Guide.m
//  FirstGuideDemo
//
//  Created by RongJun on 2018/12/11.
//  Copyright © 2018 RJ. All rights reserved.
//

#import "UIView+Guide.h"
#import "Const.h"
#import <objc/runtime.h>
static char*ShowInGuideViewKey = "showInGuideViewKey";
static char*IntroduceStringKey = "introduceStringKey";

@implementation UIView (Guide)

- (void)setShowInGuideView:(BOOL)showInGuideView{
    objc_setAssociatedObject(self, ShowInGuideViewKey, @(showInGuideView), OBJC_ASSOCIATION_ASSIGN);

    if(showInGuideView){
        //
        [[NSNotificationCenter defaultCenter] postNotificationName:RJGUIDE_NOTIFICATION_TYPE_ADD_VIEW object:self];
    } else{
        [[NSNotificationCenter defaultCenter] postNotificationName:RJGUIDE_NOTIFICATION_TYPE_REMOVE_VIEW object:self];

    }
    
}

- (BOOL)showInGuideView{
    NSNumber *t = objc_getAssociatedObject(self, ShowInGuideViewKey);
    return t.boolValue;
}

@end
