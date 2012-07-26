//
//  UIView-util.h
//  HancomViewer
//
//  Created by 이종규 on 11. 4. 19..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (util)
+ (BOOL)isModalViewMode;
+ (void)setModalViewMode:(BOOL)modalViewMode;

- (void)replaceButtonTitle:(NSString*)oldTitle with:(NSString*)newTitle;
- (UINavigationController*)navigationController;
- (UITabBarController*)tabBarController;
@end
