//
//  GridScrollViewController.m
//  GridControlTestApp
//
//  Created by Sungho Park on 12. 7. 29..
//  Copyright (c) 2012년 한글과컴퓨터. All rights reserved.
//

#import "GridScrollViewController.h"
#import "GridItem.h"

#define GRIDWIDTH 100
#define GRIDHEIGHT 44

@interface GridScrollViewController ()
- (void)syncData:(BOOL)viewToData;
- (void)addColumn;
- (void)addRow;
- (void)removeColumn;
- (void)removeRow;
@end

@implementation GridScrollViewController

- (id)initWithGridRows:(NSUInteger)row andCols:(NSUInteger)col
{
	self = [super init];
	
	if (self) {
		_row = row;
		_col = col;
		
		_gridViews = [[NSMutableArray alloc] init];;
		_data = [[NSMutableArray alloc] init];;
		
		for (NSUInteger index = 0; index < _row * _col; index++)
		{
			GridItem* gridView = [[[GridItem alloc] init] autorelease];
			gridView.tag = index;
			
			[_gridViews addObject:gridView];
		}
		
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self setSubViews];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
	[_gridViews release];
	[_data release];
	
	[super dealloc];
}

- (void)setSubViews
{
	for (int row = 0; row < _row; row++)
	{
		for (int col = 0; col < _col; col++)
		{
			CGRect frame = CGRectMake(col * GRIDWIDTH, row * GRIDHEIGHT, GRIDWIDTH, GRIDHEIGHT);
			
			GridItem* gridView = [_gridViews objectAtIndex:(row * _col + col)];
			gridView.frame = frame;
			gridView.tag = row * _col + col;
			
			[self.view addSubview:gridView];
		}
	}
	
	self.view.frame = CGRectMake(0, 0, _col * GRIDWIDTH, _row * GRIDHEIGHT);
}

- (void)syncData:(BOOL)viewToData
{
	for (GridItem* view in _gridViews)
	{
		if (viewToData) {
			[_data replaceObjectAtIndex:view.tag withObject:view.text];
		} else {
			NSString* data = [_data objectAtIndex:view.tag];
			view.text = data;
		}
	}
}

- (void)addColumn
{
	NSUInteger count = _row;
	
	while (count--)
	{
		GridItem* gridView = [[[GridItem alloc] init] autorelease];
		[_gridViews addObject:gridView];
	}
	
	_col++;
	[self setSubViews];
}


- (void)addRow
{
	NSUInteger count = _col;
	
	while (count--)
	{
		GridItem* gridView = [[[GridItem alloc] init] autorelease];
		[_gridViews addObject:gridView];
	}
	
	_row++;
	[self setSubViews];
}

- (void)removeColumn
{
	NSUInteger count = _row;
	
	while (count--)
	{
		[_gridViews removeObjectAtIndex:count];
	}
	
	_col--;
	[self setSubViews];
}

- (void)removeRow
{
	NSUInteger count = _col;
	
	while (count--)
	{
		[_gridViews removeObjectAtIndex:count];
	}
	
	_row--;
	[self setSubViews];
}

- (void)setData:(NSArray*)data
{
	[_data removeAllObjects];
	[_data addObjectsFromArray:data];
	
	[self syncData:NO];
}

- (NSArray*)getData
{
	[self syncData:YES];
	return _data;
}

- (void)addColumn:(NSArray*)data
{
	[self insertColumn:data atIndex:_col];
}

- (void)insertColumn:(NSArray*)data atIndex:(NSUInteger)index
{
	for (int row = _row - 1; row >= 0; row--)
	{
		NSString* item = [data objectAtIndex:row];
		
		[_data insertObject:item atIndex:(row * _col + index)];
	}
	
	[self addColumn];
	[self syncData:NO];
}

- (void)removeColumnAtIndex:(NSUInteger)index
{
	for (int row = _row - 1; row >= 0; row--)
	{
		[_data removeObjectAtIndex:(row * _col + index)];
	}
	
	[self removeColumn];
	[self syncData:NO];
}

- (void)addRow:(NSArray*)data
{
	[self insertRow:data atIndex:_row];
}

- (void)insertRow:(NSArray*)data atIndex:(NSUInteger)index
{
	for (int col = 0; col < _col; col++)
	{
		NSString* item = [data objectAtIndex:col];
		
		[_data insertObject:item atIndex:(index * _col +col)];
	}
	
	[self addRow];
	[self syncData:NO];
}

- (void)removeRowAtIndex:(NSUInteger)index
{
	for (int col = 0; col < _col; col++)
	{
		[_data removeObjectAtIndex:(index * _col +col)];
	}
	
	[self removeRow];
	[self syncData:NO];
}

@end
