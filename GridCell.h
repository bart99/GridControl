//
//  GridCell.h
//  gridcontrol
//
//  Created by Sungho Park on 12. 6. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
	UIGridCellTypeHeader = 100,
	UIGridCellTypeTitle,
	UIGridCellTypeData,
	UIGridCellTypeExtra,
} UIGridCellType;

#define DATA_CELL_HEIGHT	44.f
#define DATA_CELL_WIDTH		80.f
#define HEADER_CELL_HEIGHT	30.f
#define HEADER_CELL_WIDTH	30.f

#define EXTRA_COLUMN_COUNT	1

@class GridTableViewController;
@class GridCell;
@class HeaderColumn;

@protocol GridCellDelegate <NSObject>
@optional
- (void)gridCell:(GridCell*)cell insertColumn:(NSUInteger)index;
- (void)gridCell:(GridCell*)cell insertRow:(NSUInteger)index;

- (void)gridCell:(GridCell*)cell deleteColumn:(NSUInteger)index;
- (void)gridCell:(GridCell*)cell deleteRow:(NSUInteger)index;
@end

@interface GridCell : UITableViewCell <UITextFieldDelegate>
{
	NSUInteger _columnCount;
	NSMutableArray* _columns;
	NSMutableArray* _data;
	HeaderColumn* _selectedHeader;
	
	UIGridCellType _type;
}

@property(nonatomic, assign) GridTableViewController* rootController;
@property(nonatomic, assign) id<GridCellDelegate> delegate;

- (id)initWithColumns:(NSUInteger)cols reuseIdentifier:(NSString *)reuseIdentifier type:(UIGridCellType)type;
- (id)initWithData:(NSArray*)data reuseIdentifier:(NSString *)reuseIdentifier type:(UIGridCellType)type;

- (void)updateLayout;
- (void)setHeaderColumn:(NSUInteger)col;
- (void)setData:(NSArray*)data;
- (NSArray*)getData;
- (void)resetData;
- (void)headerTouchUpInside:(id)sender;

@end


