//
//  GridScrollViewController.h
//  GridControlTestApp
//
//  Created by Sungho Park on 12. 7. 29..
//  Copyright (c) 2012년 한글과컴퓨터. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GridScrollViewController : UIViewController
{
	NSUInteger _row;
	NSUInteger _col;
	
	NSMutableArray* _data;
	NSMutableArray* _gridViews;
}

- (id)initWithGridRows:(NSUInteger)row andCols:(NSUInteger)col;
- (void)setData:(NSArray*)data;
- (NSArray*)getData;

- (void)addColumn:(NSArray*)data;
- (void)insertColumn:(NSArray*)data atIndex:(NSUInteger)index;
- (void)removeColumnAtIndex:(NSUInteger)index;

- (void)addRow:(NSArray*)data;
- (void)insertRow:(NSArray*)data atIndex:(NSUInteger)index;
- (void)removeRowAtIndex:(NSUInteger)index;

@end
