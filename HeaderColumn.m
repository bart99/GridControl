//
//  HeaderColumn.m
//  gridcontrol
//
//  Created by Sungho Park on 12. 6. 8..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "HeaderColumn.h"
#import <QuartzCore/CALayer.h>

@implementation HeaderColumn

@synthesize index = _index;

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
	
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return image;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
		self.layer.borderColor = [UIColor blackColor].CGColor;
		self.layer.borderWidth = 0.5;
		self.clipsToBounds = YES;
		[self setBackgroundImage:[self imageWithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
		[self setBackgroundImage:[self imageWithColor:[UIColor orangeColor]] forState:UIControlStateNormal];
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
