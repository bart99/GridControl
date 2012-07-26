//
//  UIViewController-util.h
//  HancomViewer
//
//  Created by 이종규 on 11. 4. 19..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	SEARCHBAR_TEXT_BUTTON = 0,
	SEARCHBAR_GOTO_BUTTON
} SearchBarButtonStyle;

@interface UIViewController (util)
- (void)didTapAtPoint:(CGPoint)point;
@end
