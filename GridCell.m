//
//  GridCell.m
//  gridcontrol
//
//  Created by Sungho Park on 12. 6. 4..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "GridCell.h"
#import "GridTableViewController.h"
#import "HeaderColumn.h"
#import "QuartzCore/CALayer.h"

@implementation GridCell

@synthesize rootController, delegate = _delegate;

- (id)initWithColumns:(NSUInteger)cols reuseIdentifier:(NSString *)reuseIdentifier type:(UIGridCellType)type
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		_columnCount = cols;
		_columns = [[NSMutableArray alloc] init];

		_type = type;
		
		if (_type == UIGridCellTypeData || _type == UIGridCellTypeTitle) {
			HeaderColumn* btn = [[HeaderColumn alloc] init];
			btn.index = UIGridCellTypeHeader;
			[btn addTarget:self action:@selector(headerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
			[_columns addObject:btn];
			[self addSubview:btn];
			[btn release];
			
			UITextField* field = nil;
			for (NSUInteger index = 1; index <= _columnCount; index++)
			{
				field = [[[UITextField alloc] init] autorelease];
				field.borderStyle = UITextBorderStyleNone;
				field.textAlignment = UITextAlignmentCenter;
				field.keyboardType = UIKeyboardTypeNumberPad;
				field.delegate = self;
				field.layer.borderWidth = 0.5;
				
				if (_type == UIGridCellTypeTitle || index == 1)
					field.keyboardType = UIKeyboardTypeDefault;
				
				[_columns addObject:field];
				
				[self addSubview:field];
			}
			
			for (NSUInteger index = 0; index < EXTRA_COLUMN_COUNT; index++)
			{
				UIView* view = [[[UIView alloc] init] autorelease];
				view.backgroundColor = [UIColor lightGrayColor];
				view.layer.borderWidth = 0.5;
				view.layer.borderColor = [UIColor blackColor].CGColor;
				[_columns addObject:view];
				[self addSubview:view];
			}
		
		} else if (_type == UIGridCellTypeHeader) {
			HeaderColumn* btn = [[HeaderColumn alloc] init];
			btn.index = UIGridCellTypeHeader;
			[_columns addObject:btn];
			[self addSubview:btn];
			[btn release];

			for (NSUInteger index = 0; index < _columnCount; index++)
			{
				HeaderColumn* btn = [[HeaderColumn alloc] init];
				btn.tag = UIGridCellTypeHeader;
				btn.index = index;
				[btn addTarget:self action:@selector(headerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
				[_columns addObject:btn];
				[self addSubview:btn];
				[btn release];
			}
			
			for (NSUInteger index = 0; index < EXTRA_COLUMN_COUNT; index++)
			{
				HeaderColumn* btn = [[HeaderColumn alloc] init];
				btn.tag = UIGridCellTypeExtra;
				btn.index = _columnCount + index;
				[btn addTarget:self action:@selector(headerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
				[_columns addObject:btn];
				[self addSubview:btn];
				[btn release];
			}
		} else if (_type == UIGridCellTypeExtra) {
			HeaderColumn* btn = [[HeaderColumn alloc] init];
			btn.tag = UIGridCellTypeExtra;
			[btn addTarget:self action:@selector(headerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
			[_columns addObject:btn];
			[self addSubview:btn];
			[btn release];
			
			for (NSUInteger index = 0; index < _columnCount + EXTRA_COLUMN_COUNT; index++)
			{
				UIView* view = [[[UIView alloc] init] autorelease];
				view.backgroundColor = [UIColor lightGrayColor];
				view.layer.borderWidth = 0.5;
				view.layer.borderColor = [UIColor blackColor].CGColor;
				[_columns addObject:view];
				[self addSubview:view];
			}
		}
		
		[self updateLayout];
    }
    return self;	
}

- (id)initWithData:(NSArray*)data reuseIdentifier:(NSString *)reuseIdentifier type:(UIGridCellType)type
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		_columns = [[NSMutableArray alloc] init];
		_type = type;
		
		[self setData:data];
		[self updateLayout];
    }
	
    return self;	
}

- (void)dealloc
{
	[_columns release];
	[_data release];
	
	[super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	[self updateLayout];
}

- (void)updateLayout
{
	if (_columnCount == 0)
		return;
	
	NSUInteger x = 0;

	if (_type == UIGridCellTypeData || _type == UIGridCellTypeTitle) {
		CGRect rect = CGRectMake(x, 0, HEADER_CELL_WIDTH, self.frame.size.height);
		UIButton* btn = [_columns objectAtIndex:0];
		btn.frame = rect;
		
		x += btn.frame.size.width;
		
		UITextField* field = nil;
		for (NSUInteger index = 0; index < _columnCount; index++)
		{
			rect = CGRectMake(x, 0, DATA_CELL_WIDTH, self.frame.size.height);
			field = [_columns objectAtIndex:(index + 1)];
			field.frame = rect;
			field.text = (NSString*)[_data objectAtIndex:index];
			field.backgroundColor = self.rootController.backgroundColor;

			x += field.frame.size.width;
		}
		
		for (NSUInteger index = 1; index <= EXTRA_COLUMN_COUNT; index++)
		{
			UIView* view = [_columns objectAtIndex:_columnCount + index];
			rect = CGRectMake(x, 0, DATA_CELL_WIDTH, self.frame.size.height);
			view.frame = rect;
			
			x += view.frame.size.width;
		}

	} else if (_type == UIGridCellTypeHeader) {		
		CGRect rect = CGRectMake(x, 0, HEADER_CELL_WIDTH, self.frame.size.height);
		UIButton* btn = [_columns objectAtIndex:0];
		btn.frame = rect;

		x  = btn.frame.size.width;
		
		for (NSUInteger index = 1; index <= _columnCount; index++)
		{
			CGRect rect = CGRectMake(x, 0, DATA_CELL_WIDTH, HEADER_CELL_HEIGHT);
			UIButton* btn = [_columns objectAtIndex:index];
			btn.frame = rect;
			
			x += btn.frame.size.width;
		}
		
		for (NSUInteger index = 1; index <= EXTRA_COLUMN_COUNT; index++)
		{
			btn = [_columns objectAtIndex:_columnCount + index];
			rect = CGRectMake(x, 0, DATA_CELL_WIDTH, HEADER_CELL_HEIGHT);
			btn.frame = rect;

			x += btn.frame.size.width;
		}
	} else if (_type == UIGridCellTypeExtra) {
		CGRect rect = CGRectMake(x, 0, HEADER_CELL_WIDTH, self.frame.size.height);
		UIButton* btn = [_columns objectAtIndex:0];
		btn.frame = rect;
		
		x += btn.frame.size.width;
		
		for (NSUInteger index = 1; index <= _columnCount + EXTRA_COLUMN_COUNT; index++)
		{
			UIView* view = [_columns objectAtIndex:index];
			rect = CGRectMake(x, 0, DATA_CELL_WIDTH, self.frame.size.height);
			view.frame = rect;
			
			x += view.frame.size.width;
		}
	}
}

- (void)resetData
{
	if (_columnCount == 0)
		return;
	
	for (NSUInteger index = 0; index <= _columnCount; index++)
	{		
		UIView* view = [_columns objectAtIndex:index];
		[view removeFromSuperview];
	}

	if (_columns)
		[_columns removeAllObjects];
	
	if (_data)
		[_data release];
	
	_columnCount = 0;
}

- (NSArray*)getData
{
	[self resignFirstResponder];
	
	return _data;
}

- (void)setData:(NSArray*)data
{
	[self resetData];
	
	_columnCount = [data count];
		
	HeaderColumn* btn = [[HeaderColumn alloc] init];
	btn.index = UIGridCellTypeHeader;
	[btn addTarget:self action:@selector(headerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	[_columns addObject:btn];
	[self addSubview:btn];
	[btn release];
	
	UITextField* field = nil;
	for (NSUInteger index = 1; index <= _columnCount; index++)
	{
		field = [[[UITextField alloc] init] autorelease];
		field.borderStyle = UITextBorderStyleNone;
		field.textAlignment = UITextAlignmentCenter;
		field.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		field.keyboardType = UIKeyboardTypeNumberPad;
		field.delegate = self;
		field.layer.borderWidth = 0.5;
		field.tag = index - 1;
		
		if (_type == UIGridCellTypeTitle || index == 1)
			field.keyboardType = UIKeyboardTypeDefault;

		[_columns addObject:field];
		
		[self addSubview:field];
	}
	
	for (NSUInteger index = 0; index < EXTRA_COLUMN_COUNT; index++)
	{
		UIView* view = [[[UIView alloc] init] autorelease];
		view.backgroundColor = [UIColor lightGrayColor];
		view.layer.borderColor = [UIColor blackColor].CGColor;
		view.layer.borderWidth = 0.5;
		[_columns addObject:view];
		[self addSubview:view];
	}

	_data = [[NSMutableArray arrayWithArray:data] retain];
	
	self.frame = CGRectMake(0, 0, HEADER_CELL_WIDTH + (_columnCount + EXTRA_COLUMN_COUNT) * DATA_CELL_WIDTH, self.frame.size.height);
}

- (void)setHeaderColumn:(NSUInteger)col
{
	[self resetData];
	
	_columnCount = col;
	
	HeaderColumn* btn = [[HeaderColumn alloc] init];
	[_columns addObject:btn];
	[self addSubview:btn];
	[btn release];
	
	for (NSUInteger index = 0; index < _columnCount; index++)
	{
		HeaderColumn* btn = [[HeaderColumn alloc] init];
		btn.tag = UIGridCellTypeHeader;
		btn.index = index;
		[btn addTarget:self action:@selector(headerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[_columns addObject:btn];
		[self addSubview:btn];
		[btn release];
	}			

	for (NSUInteger index = 0; index < EXTRA_COLUMN_COUNT; index++)
	{
		HeaderColumn* btn = [[HeaderColumn alloc] init];
		btn.tag = UIGridCellTypeExtra;
		btn.index = _columnCount + index;
		[btn addTarget:self action:@selector(headerTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
		[_columns addObject:btn];
		[self addSubview:btn];
		[btn release];
	}
	
	self.frame = CGRectMake(0, 0, HEADER_CELL_WIDTH + (_columnCount + EXTRA_COLUMN_COUNT) * DATA_CELL_WIDTH, self.frame.size.height);
}

- (void)headerTouchUpInside:(id)sender
{
	HeaderColumn* btn = (HeaderColumn*)sender;
	[btn becomeFirstResponder];
	
	UIMenuController* menu = [UIMenuController sharedMenuController];
	[menu setTargetRect:btn.bounds inView:btn];

	menu.arrowDirection = UIMenuControllerArrowDown;
	
	NSAssert([self becomeFirstResponder], @"Sorry, UIMenuController will not work with %@ since it cannot become first responder", self);

	_selectedHeader = sender;
	
	if (btn.tag == UIGridCellTypeExtra) {
		UIMenuItem *insertMenu = [[UIMenuItem alloc] initWithTitle:@"Insert" action:@selector(insertItem:)];
		menu.menuItems = [NSArray arrayWithObjects:insertMenu, nil];		
		[menu setMenuVisible:YES animated:YES];
	} else if (self.tag > 0 && btn.index > 0) {
		UIMenuItem *insertMenu = [[UIMenuItem alloc] initWithTitle:@"Insert" action:@selector(insertItem:)];
		UIMenuItem *deleteMenu = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteItem:)];
		menu.menuItems = [NSArray arrayWithObjects:insertMenu, deleteMenu, nil];
		[menu setMenuVisible:YES animated:YES];
	}
	
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[_data replaceObjectAtIndex:textField.tag withObject:textField.text];	
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}

- (BOOL) canPerformAction:(SEL)selector withSender:(id) sender {
    if (/*selector == @selector(copy:) || selector == @selector(paste:) || */selector == @selector(insertItem:) || selector == @selector(deleteItem:)) {
        return YES;
    }
    return NO;
}

- (void) copy:(id) sender {
    // called when copy clicked in menu
}

- (void) paste:(id) sender {
    // called when copy clicked in menu
}

- (void) insertItem:(id) sender {
	if (_type == UIGridCellTypeHeader) {
		if (_delegate && [_delegate respondsToSelector:@selector(gridCell:insertColumn:)])
			[_delegate performSelector:@selector(gridCell:insertColumn:) withObject:self withObject:(id)_selectedHeader.index];
	} else {
		if (_delegate && [_delegate respondsToSelector:@selector(gridCell:insertRow:)])
			[_delegate performSelector:@selector(gridCell:insertRow:) withObject:self withObject:(id)self.tag];
	}
}

- (void) deleteItem:(id) sender {
	if (_type == UIGridCellTypeHeader) {
		if (_delegate && [_delegate respondsToSelector:@selector(gridCell:deleteColumn:)])
			[_delegate performSelector:@selector(gridCell:deleteColumn:) withObject:self withObject:(id)_selectedHeader.index];
	} else {
		if (_delegate && [_delegate respondsToSelector:@selector(gridCell:deleteRow:)])
			[_delegate performSelector:@selector(gridCell:deleteRow:) withObject:self withObject:(id)self.tag];
	}
}

@end
