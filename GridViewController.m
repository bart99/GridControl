//
//  GridViewController.m
//  gridcontrol
//
//  Created by Sungho Park on 12. 6. 11..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "GridViewController.h"
#import "GridScrollViewController.h"
#import "UIDevice-util.h"
#import "UIView-util.h"
#import "UIWindow-util.h"

@interface GridViewController ()

@end

@implementation GridViewController

@synthesize gridTable;
@synthesize scrollView;
@synthesize delegate = _delegate;
@synthesize colHeaderView = _colHeaderView, rowHeaderView = _rowHeaderView;

- (id)init
{
	self = [super init];
	
	if (self) {
		self.scrollView = [[UIScrollView alloc] init];
		self.scrollView.delegate = self;
		self.colHeaderView = [[UIView alloc] init];
		self.colHeaderView.backgroundColor = [UIColor redColor];
		self.rowHeaderView = [[UIView alloc] init];
		self.rowHeaderView.backgroundColor = [UIColor yellowColor];
	}
	
	return self;
}

- (id)initWithGridRows:(NSUInteger)row andCols:(NSUInteger)col
{
	self = [self init];
	
	if (self) {
		self.gridTable = [[GridScrollViewController alloc] initWithGridRows:row andCols:col];
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

	if ([UIDevice iPad]) {
		self.view.backgroundColor = [UIColor colorWithRed:(200.0/255.0) 
													green:(200.0/255.0)
													 blue:(200.0/255.0) alpha:1.0f];
	} else {
		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	}	

	// navigation setting..
	self.navigationItem.title = @"GridControl";
	UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"	
																			style:UIBarButtonItemStylePlain
																		   target:self
																		   action:@selector(didPressCancelBarButton:)];
	[self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:YES];
	[cancelBarButtonItem autorelease];
	
	UIBarButtonItem *otherBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"OK" 
																		   style:UIBarButtonItemStylePlain 
																		  target:self 
																		  action:@selector(didPressOtherBarButton:)];
	[self.navigationItem setRightBarButtonItem:otherBarButtonItem animated:YES];
	[otherBarButtonItem autorelease];
	
	[self.view addSubview:self.scrollView];
	self.scrollView.frame = CGRectMake(44, 44, self.view.frame.size.width, self.view.frame.size.height);
	self.scrollView.backgroundColor = [UIColor greenColor];
	[self.scrollView addSubview:self.gridTable.view];
	[self addChildViewController:self.gridTable];
	
	self.scrollView.alwaysBounceHorizontal = YES;
	self.scrollView.alwaysBounceVertical = YES;
	
	self.scrollView.contentSize = self.gridTable.view.frame.size;
	
	self.colHeaderView.frame =  CGRectMake(0, 0, self.view.frame.size.width, 44);
	[self.view insertSubview:self.colHeaderView aboveSubview:self.scrollView];

	self.rowHeaderView.frame =  CGRectMake(0, 0, 44, self.view.frame.size.height);
	[self.view insertSubview:self.rowHeaderView aboveSubview:self.scrollView];

//	self.gridTable.tableView.allowsSelection = NO;

}

- (void)viewDidUnload
{
	[self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	self.scrollView.contentSize = self.gridTable.view.frame.size;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void)dealloc {
	[gridTable release];
	[scrollView release];
	[_colHeaderView release];
	[_rowHeaderView release];
	[super dealloc];
}


- (void)setData:(NSArray*)datas
{
	[self.gridTable setData:datas];
}

- (void)addColumn:(NSArray*)data
{
	[self.gridTable addColumn:data];
}

- (void)insertColumn:(NSArray*)data atIndex:(NSUInteger)index
{
	[self.gridTable insertColumn:data atIndex:index];
}

- (void)removeColumnAtIndex:(NSUInteger)index
{
	[self.gridTable removeColumnAtIndex:index];
}

- (void)addRow:(NSArray*)data
{
	[self.gridTable addRow:data];
}

- (void)insertRow:(NSArray*)data atIndex:(NSUInteger)index
{
	[self.gridTable insertRow:data atIndex:index];
}

- (void)removeRowAtIndex:(NSUInteger)index
{
	[self.gridTable removeRowAtIndex:index];
}

- (void)setTitleColumn:(NSArray*)data
{
	[self.gridTable setTitleColumn:data];
}


#pragma mark -
#pragma mark UIBarButtonAction
- (void)didPressCancelBarButton:(id)sender
{
	[self cancelButtonAction];
}

- (void)didPressOtherBarButton:(id)sender
{
	[self otherButtonAction];
}


#pragma mark -
#pragma mark User method
- (void)cancelButtonAction
{
	if ([_delegate respondsToSelector:@selector(cancel)]) {
		[_delegate cancel];
	}
		
	[self dismissModalViewControllerAnimated:YES];
	[UIView setModalViewMode:NO];
}

- (void)otherButtonAction
{
	if ([_delegate respondsToSelector:@selector(setData:)]) {
		[_delegate setData:[gridTable getData]];
	}
	
	[self dismissModalViewControllerAnimated:YES];
	[UIView setModalViewMode:NO];
}

#pragma mark -
#pragma mark InputViewController method


- (UIViewController*)viewControllerInViews:(NSArray*)views {
	for (UIView* view in views) {
		if ([view isKindOfClass:[UIView class]] == YES) {
			UIViewController* vc = (UIViewController*)[view nextResponder];
			if (vc != nil)
				return vc;
		}
	}
	
	return nil;
}

- (void)showWithAnimated:(BOOL)animated {
	UINavigationController *navigationController = [[UINavigationController alloc]
													initWithRootViewController:self];
	
	[navigationController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	
	// iPad에서만 지원되는 code. 
	// 하위버전 iOS(1.3.x)에서는 죽는 현상 있음.
	if ([UIDevice iPad]) {
		[navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
	}
	
	UIWindow* window = [UIWindow mainWindow];
	
	if (window == nil)
		NSLog(@"ERROR: cannot find window");
	else {
		if ([window.subviews count] == 0)
			NSLog(@"ERROR: doesn't have any subview");
		else {
			UIViewController* vc = [self viewControllerInViews:window.subviews];
			
			if (vc != nil && [UIView isModalViewMode] == NO) {
				[UIView setModalViewMode:YES];
				[vc presentModalViewController:navigationController animated:animated];
			}
			else {
				NSLog(@"ERROR: doesn't have any UIViewController object");
			}
		}
	}
	
	[navigationController release];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
//	[RotationLock enabled:NO];
//	
//	[_textField resignFirstResponder];
//	[_exTextField resignFirstResponder];
	
	[self dismissModalViewControllerAnimated:animated];
	[UIView setModalViewMode:NO];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//	[self.scrollView addSubview:self.headerView];
	self.rowHeaderView.frame = CGRectMake(0, -self.scrollView.contentOffset.y, 44, self.scrollView.frame.size.height);
	self.colHeaderView.frame = CGRectMake(-self.scrollView.contentOffset.x, 0, self.scrollView.frame.size.width, 44);
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	
}

// called on finger up if the user dragged. velocity is in points/second. targetContentOffset may be changed to adjust where the scroll view comes to rest. not called when pagingEnabled is YES
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	
}

@end
