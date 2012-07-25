//
//  UIDevice-util.h
//  HancomViewer
//
//  Created by 이종규 on 11. 4. 18..
//  Copyright 2011 Hancom Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (util)
+ (NSString *)platform;
+ (BOOL)iPad;
+ (BOOL)iPad1;
+ (CGFloat)version;
+ (UIInterfaceOrientation)oldOrientation;
+ (void)setOldOrientation:(UIInterfaceOrientation)orientation;
@end
