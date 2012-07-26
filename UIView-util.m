//
//  UIView-util.m
//  HancomViewer
//
//  Created by 이종규 on 11. 4. 19..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import "UIView-util.h"

static BOOL s_modalViewMode = NO;

@implementation UIView (util)
+ (BOOL)isModalViewMode {
	return s_modalViewMode;
}

+ (void)setModalViewMode:(BOOL)modalViewMode {
	s_modalViewMode = modalViewMode;
}

- (void) replaceButtonTitle:(NSString*)oldTitle with:(NSString*)newTitle {
	for (UIView* subView in self.subviews)
		[subView replaceButtonTitle:oldTitle with:newTitle];
	
	if ([self isKindOfClass:UIButton.class]) {
		UIButton *button = (UIButton*)self;
		if ([button respondsToSelector:@selector(titleForState:)]) {
			if ([[button titleForState:UIControlStateNormal] isEqualToString:oldTitle]) {
				[button setTitle:newTitle forState:UIControlStateNormal];
			}
		}
	}
}

- (UINavigationController *)navigationController {
	UIViewController* vc = (UIViewController *)[self nextResponder];

	if (vc == nil)
		return nil;

	return vc.navigationController;
}

- (UITabBarController*)tabBarController {
	UIViewController* vc = (UIViewController*)[self nextResponder];

	if (vc == nil)
		return nil;

	return vc.tabBarController;
}

@end
