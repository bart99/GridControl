//
//  GridTableViewController.m
//  gridcontrol
//
//  Created by Sungho Park on 12. 6. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "GridTableViewController.h"
#import "GridViewController.h"

@interface GridTableViewController ()

@end

@implementation GridTableViewController

@synthesize backgroundColor = _backgroundColor;
@synthesize selectedColor = _selectedColor;
@synthesize headerColor = _headerColor;
@synthesize gridViewController = _gridViewController;

- (id)initWithGridRows:(NSUInteger)row andCols:(NSUInteger)col
{
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		
		self.view.autoresizingMask = UIViewAutoresizingNone;
		self.tableView.showsVerticalScrollIndicator = NO;
		self.tableView.showsHorizontalScrollIndicator = NO;
		[self.tableView setScrollEnabled:NO];
		[self.tableView setPagingEnabled:NO];
		
		_row = row;
		_col = col;
		
		self.backgroundColor = [UIColor whiteColor];
		self.selectedColor = [UIColor blueColor];
		self.headerColor = [UIColor brownColor];
		
		((UITableView*)self.view).separatorStyle = UITableViewCellSeparatorStyleNone;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
	[_data release];
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)setData:(NSArray*)data
{
	_data = [[NSMutableArray arrayWithCapacity:_row] retain];
	
	for (NSUInteger row = 0; row < _row; row++)
	{
		NSMutableArray* rowData = [NSMutableArray arrayWithCapacity:_col];
		for (NSUInteger col = 0; col < _col; col++)
		{
			[rowData addObject:[data objectAtIndex:row * _col + col]];
		}
		
		[_data addObject:rowData];
	}
	
	CGRect rect = CGRectMake(0, 20, HEADER_CELL_WIDTH + (_col + EXTRA_COLUMN_COUNT) * DATA_CELL_WIDTH, HEADER_CELL_HEIGHT + (_row + 1) * DATA_CELL_HEIGHT);
	
	self.tableView.frame = rect;
	self.gridViewController.scrollView.contentSize = self.tableView.frame.size;
}

- (NSArray*)getData
{
	for (NSUInteger row = 0; row < _row; row++)
	{
		GridCell* cell = (GridCell*)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:0]];
		[_data replaceObjectAtIndex:row withObject:[cell getData]];
	}

	return _data;
}

- (void)addColumn:(NSArray*)data
{
	[self insertColumn:data atIndex:_col];
}

- (void)insertColumn:(NSArray*)data atIndex:(NSUInteger)index
{
	NSUInteger columnCount;
	GridCell* cell = nil;
	
	for (NSUInteger row = 0; row < _row; row++)
	{
		NSString* text = @"";
		if (data != nil && data.count > row)
			text = [data objectAtIndex:row];
		
		NSMutableArray* rowData = [_data objectAtIndex:row];
		[rowData insertObject:text atIndex:index];
		
		columnCount = [rowData count];
		
		cell = (GridCell*)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:0]];
		[cell setData:rowData];
		[cell updateLayout];
	}
	
	cell = (GridCell*)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[cell setHeaderColumn:columnCount];
	_col = columnCount;
	
	self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, cell.frame.size.width, self.tableView.contentSize.height);
	self.gridViewController.scrollView.contentSize = self.tableView.frame.size;
	
	[self.tableView reloadData];
	[self.tableView setNeedsDisplay];
}

- (void)removeColumnAtIndex:(NSUInteger)index
{
	NSUInteger columnCount;
	GridCell* cell = nil;
	
	for (NSUInteger row = 0; row < _row; row++)
	{
		NSMutableArray* rowData = [_data objectAtIndex:row];
		[rowData removeObjectAtIndex:index];
		
		columnCount = [rowData count];
		
		cell = (GridCell*)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row + 1 inSection:0]];
		[cell setData:rowData];
		[cell updateLayout];
	}
	
	cell = (GridCell*)[self tableView:self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[cell setHeaderColumn:columnCount];
	_col = columnCount;
	
	self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, cell.frame.size.width, self.tableView.contentSize.height);
	self.gridViewController.scrollView.contentSize = self.tableView.frame.size;
	
	[self.tableView reloadData];
	[self.tableView setNeedsDisplay];
}

- (void)addRow:(NSArray*)data
{
	[self insertRow:data atIndex:_row];
}

- (void)insertRow:(NSArray*)data atIndex:(NSUInteger)index
{
	NSMutableArray* rowData = [NSMutableArray arrayWithCapacity:_col];
	
	for (NSUInteger col = 0; col < _col; col++)
	{
		NSString* text = @"";
		if (data != nil && data.count > col)
			text = [data objectAtIndex:col];
		
		[rowData addObject:text];
	}
	
	[_data insertObject:rowData atIndex:index];
	_row++;
	
	self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.contentSize.width, self.tableView.contentSize.height + DATA_CELL_HEIGHT);
	self.gridViewController.scrollView.contentSize = self.tableView.frame.size;
	
	[self.tableView reloadData];
	[self.tableView setNeedsDisplay];
}

- (void)removeRowAtIndex:(NSUInteger)index
{
	[_data removeObjectAtIndex:index];
	_row--;
	
	self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.contentSize.width, self.tableView.contentSize.height - DATA_CELL_HEIGHT);
	self.gridViewController.scrollView.contentSize = self.tableView.frame.size;
	
	[self.tableView reloadData];
	[self.tableView setNeedsDisplay];
}

- (void)setTitleColumn:(NSArray*)data
{
	if (_col == 0) {
		[self insertColumn:data atIndex:0];
		[self removeColumnAtIndex:1];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _row + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GridCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
	if (cell == nil) {
		if (indexPath.row == 0) {
			cell = [[GridCell alloc] initWithColumns:_col reuseIdentifier:CellIdentifier type:UIGridCellTypeHeader];
			cell.rootController = self;
			cell.delegate = self;
			cell.tag = UIGridCellTypeHeader;
		} else if (indexPath.row <= _row) {
			if (indexPath.row == 1)
				cell = [[GridCell alloc] initWithData:[_data objectAtIndex:indexPath.row - 1] reuseIdentifier:CellIdentifier type:UIGridCellTypeTitle];
			else
				cell = [[GridCell alloc] initWithData:[_data objectAtIndex:indexPath.row - 1] reuseIdentifier:CellIdentifier type:UIGridCellTypeData];
			
			cell.tag = indexPath.row - 1;
			cell.rootController = self;
			cell.delegate = self;
		} else {
			cell = [[GridCell alloc] initWithColumns:_col reuseIdentifier:CellIdentifier type:UIGridCellTypeExtra];
			cell.tag = indexPath.row - 1;
			cell.rootController = self;
			cell.delegate = self;		
		}
		[(GridCell*)cell updateLayout];
	}
    	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0)
		return HEADER_CELL_HEIGHT;
	else
		return DATA_CELL_HEIGHT;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - Grid Cell delegate
- (void)gridCell:(GridCell*)cell insertColumn:(NSUInteger)index
{
	[self insertColumn:nil atIndex:index];
}

- (void)gridCell:(GridCell*)cell insertRow:(NSUInteger)index
{
	[self insertRow:nil atIndex:index];
}

- (void)gridCell:(GridCell*)cell deleteColumn:(NSUInteger)index
{
	[self removeColumnAtIndex:index];
}

- (void)gridCell:(GridCell*)cell deleteRow:(NSUInteger)index
{
	[self removeRowAtIndex:index];
}

@end
