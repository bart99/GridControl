//
//  UIWindow-util.m
//  HancomViewer
//
//  Created by 이종규 on 11. 6. 29..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import "UIWindow-util.h"


@implementation UIWindow (util)

+ (UIWindow*)mainWindow {
	UIWindow* window = [[UIApplication sharedApplication] keyWindow];
	// keyWindow가 nil이거나 UIAlertView가 화면에 있는 경우 ApplicationDelegate에서 window를 가져옮
	if (window == nil || [window isKindOfClass:NSClassFromString(@"_UIAlertOverlayWindow")] == YES) {
		id<UIApplicationDelegate> applicationDelegate = [UIApplication sharedApplication].delegate;
		if ([applicationDelegate respondsToSelector:@selector(window)] == YES)
			window = [applicationDelegate performSelector:@selector(window)];
	}

	return window;
}

@end
