//
//  UIDevice-util.m
//  HancomViewer
//
//  Created by 이종규 on 11. 4. 18..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import "UIDevice-util.h"
#include <sys/types.h>
#include <sys/sysctl.h>

static UIInterfaceOrientation s_oldOrientation = UIInterfaceOrientationPortrait;

// hspwindow-ios.mm GetClientRect 에서 사용
UIInterfaceOrientation deviceOrientation()
{
        return s_oldOrientation;
}

CGFloat systemVersion()
{
	return [UIDevice version];
}

@implementation UIDevice (util)

+ (NSString *)platform
{
	size_t size;
	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
	char *machine = malloc(size);
	sysctlbyname("hw.machine", machine, &size, NULL, 0);
	NSString *platform = [NSString stringWithUTF8String:machine];
	free(machine);
	
	return platform;
}

+ (BOOL)iPad {
	static BOOL initialized = NO;
	static BOOL iPad;
	
	if (initialized == NO) {
		initialized = YES;
		NSString *deviceModel = [[UIDevice currentDevice] model];
		iPad  = ([deviceModel hasPrefix:@"iPad"]) ? YES : NO;
	}
	
	return iPad;
}

+ (BOOL)iPad1 {
	static BOOL initialized = NO;
	static BOOL iPad1;
	
	if (initialized == NO) {
		initialized = YES;
		
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char *machine = malloc(size);
		sysctlbyname("hw.machine", machine, &size, NULL, 0);
		NSString *platform = [NSString stringWithCString:machine encoding: NSUTF8StringEncoding];
		free(machine);
		
		iPad1  = ([platform hasPrefix:@"iPad1"]) ? YES : NO;
	}
	
	return iPad1;
}

+ (CGFloat)version {
	static CGFloat version = 0;
	
	if (version == 0) {
		NSString *deviceVersion = [[UIDevice currentDevice] systemVersion];
		version = [deviceVersion floatValue];
	}
	
	return version;
}

+ (UIInterfaceOrientation)oldOrientation {
	return s_oldOrientation;
}

+ (void)setOldOrientation:(UIInterfaceOrientation)orientation {
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			s_oldOrientation = orientation;
			break;
	}
}

@end
