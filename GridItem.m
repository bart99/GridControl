//
//  GridItem.m
//  GridControlTestApp
//
//  Created by Sungho Park on 12. 7. 29..
//  Copyright (c) 2012년 한글과컴퓨터. All rights reserved.
//

#import "GridItem.h"
#import "QuartzCore/CALayer.h"

@implementation GridItem

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
		self.borderStyle = UITextBorderStyleNone;
		self.textAlignment = UITextAlignmentCenter;
		self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.keyboardType = UIKeyboardTypeNumberPad;
		self.layer.borderWidth = 0.5;

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
