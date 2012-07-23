//
//  GridTableViewController.h
//  gridcontrol
//
//  Created by Sungho Park on 12. 6. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridCell.h"

@class GridViewController;

@interface GridTableViewController : UITableViewController <GridCellDelegate>
{
	NSUInteger _row;
	NSUInteger _col;
	
	NSMutableArray* _data;	
}

@property(nonatomic, retain) UIColor* backgroundColor;
@property(nonatomic, retain) UIColor* selectedColor;
@property(nonatomic, retain) UIColor* headerColor;
@property(nonatomic, retain) GridViewController* gridViewController;

- (id)initWithGridRows:(NSUInteger)row andCols:(NSUInteger)col;
- (void)setData:(NSArray*)data;
- (NSArray*)getData;

- (void)addColumn:(NSArray*)data;
- (void)insertColumn:(NSArray*)data atIndex:(NSUInteger)index;
- (void)removeColumnAtIndex:(NSUInteger)index;

- (void)addRow:(NSArray*)data;
- (void)insertRow:(NSArray*)data atIndex:(NSUInteger)index;
- (void)removeRowAtIndex:(NSUInteger)index;

- (void)setTitleColumn:(NSArray*)data;

@end
