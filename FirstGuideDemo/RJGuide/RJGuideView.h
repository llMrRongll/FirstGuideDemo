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
+ (id)sharedInstance;
- (void)prepareShowGuide;
@end

NS_ASSUME_NONNULL_END
