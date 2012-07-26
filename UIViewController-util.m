//
//  UIViewController-util.m
//  HancomViewer
//
//  Created by 이종규 on 11. 4. 19..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import "UIViewController-util.h"
#import "UIDevice-util.h"
#import "Settings.h"

#define TAP_AREA_WIDTH				40.0f

@implementation UIViewController (util)

- (void)didTapAtPoint:(CGPoint)point {
	CGSize frameSize = self.view.frame.size;
	TapArea tapArea = NONE_EDGE;
	
	if (point.y < TAP_AREA_WIDTH) {
		if (point.x < TAP_AREA_WIDTH)
			tapArea = LEFT_TOP_CORNER;
		else if (point.x > TAP_AREA_WIDTH && point.x < (frameSize.width - TAP_AREA_WIDTH))
			tapArea = TOP_EDGE;
		else if (point.x > (frameSize.width - TAP_AREA_WIDTH))
			tapArea = RIGHT_TOP_CORNER;
	} else if (point.y > TAP_AREA_WIDTH && point.y < (frameSize.height - TAP_AREA_WIDTH)) {
		if (point.x < TAP_AREA_WIDTH)
			tapArea = LEFT_EDGE;
		else if (point.x > (frameSize.width) - TAP_AREA_WIDTH)
			tapArea = RIGHT_EDGE;
	} else if (point.y > (frameSize.height - TAP_AREA_WIDTH)) {
		if (point.x < TAP_AREA_WIDTH)
			tapArea = LEFT_BOTTOM_CORNER;
		else if (point.x > TAP_AREA_WIDTH && point.x < (frameSize.width - TAP_AREA_WIDTH))
			tapArea = BOTTOM_EDGE;
		else if (point.x > (frameSize.width - TAP_AREA_WIDTH))
			tapArea = RIGHT_BOTTOM_CORNER;
	}

	Settings* settings = [Settings sharedSettings];
	
	if (settings.usingTapMovement == YES) {
		
		NSMutableDictionary* selectors = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
										  @"forwardPage:",			NSLocalizedString(@"Next page", nil),
										  @"backwardPage:",			NSLocalizedString(@"Previous page", nil),
										  @"scrollDownPage:",			NSLocalizedString(@"Scroll down", nil),
										  @"scrollUpPage:",			NSLocalizedString(@"Scroll up", nil),
										  @"scrollLeftPage:",			NSLocalizedString(@"Scroll left", nil),
										  @"scrollRightPage:",		NSLocalizedString(@"Scroll right", nil),
										  @"scrollLeftUpPage:",		NSLocalizedString(@"Scroll left-up", nil),
										  @"scrollRightUpPage:",		NSLocalizedString(@"Scroll right-up", nil),
										  @"scrollLeftDownPage:",		NSLocalizedString(@"Scroll left-down", nil),
										  @"scrollRightDownPage:",	NSLocalizedString(@"Scroll right-down", nil),
										  @"forwardLeftUpPage:",	NSLocalizedString(@"Left-top of the next page", nil),
										  @"forwardRightUpPage:",	NSLocalizedString(@"Right-top of the next page", nil),
										  nil];
		
		SEL selector = nil;
		switch (tapArea) {
			case LEFT_EDGE:
				selector = NSSelectorFromString([selectors objectForKey:settings.leftEdge]);
				break;
			case RIGHT_EDGE:
				selector = NSSelectorFromString([selectors objectForKey:settings.rightEdge]);
				break;
			case TOP_EDGE:
				selector = NSSelectorFromString([selectors objectForKey:settings.topEdge]);
				break;
			case BOTTOM_EDGE:
				selector = NSSelectorFromString([selectors objectForKey:settings.bottomEdge]);
				break;
			case LEFT_TOP_CORNER:
				selector = NSSelectorFromString([selectors objectForKey:settings.leftTopCorner]);
				break;
			case RIGHT_TOP_CORNER:
				selector = NSSelectorFromString([selectors objectForKey:settings.rightTopCorner]);
				break;
			case LEFT_BOTTOM_CORNER:
				selector = NSSelectorFromString([selectors objectForKey:settings.leftBottomCorner]);
				break;
			case RIGHT_BOTTOM_CORNER:
				selector = NSSelectorFromString([selectors objectForKey:settings.rightBottomCorner]);
				break;
			case NONE_EDGE:
				selector = nil;
				break;
		}
		
		[selectors release];
		
		if (selector != nil) {
			if ([self respondsToSelector:selector] == YES) {
				[self performSelector:selector withObject:self];
				return;
			}
			else
				NSLog(@"Doesn't respond selector:%@", selector);
		}
	}
	
	if (self.navigationController.navigationBar.alpha != 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TOOLBAR" object:nil];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TOOLBAR" object:nil];
	}
}

@end
