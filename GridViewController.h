//
//  GridViewController.h
//  gridcontrol
//
//  Created by Sungho Park on 12. 6. 11..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridViewDelegate <NSObject>
- (void)setData:(NSArray*)data;
@optional
- (void)cancel;
@end

@class GridTableViewController;
@class GridScrollViewController;

@interface GridViewController : UIViewController <UIScrollViewDelegate>
{
}

//@property(nonatomic, retain) GridTableViewController* gridTable;
@property(nonatomic, retain) GridScrollViewController* gridTable;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic, assign) id<GridViewDelegate> delegate;
@property(nonatomic, retain) UIView* colHeaderView;
@property(nonatomic, retain) UIView* rowHeaderView;

- (id)initWithGridRows:(NSUInteger)row andCols:(NSUInteger)col;
- (void)setData:(NSArray*)datas;

- (void)showWithAnimated:(BOOL)animated;
- (void)cancelButtonAction;
- (void)otherButtonAction;

- (void)addColumn:(NSArray*)data;
- (void)insertColumn:(NSArray*)data atIndex:(NSUInteger)index;
- (void)removeColumnAtIndex:(NSUInteger)index;

- (void)addRow:(NSArray*)data;
- (void)insertRow:(NSArray*)data atIndex:(NSUInteger)index;
- (void)removeRowAtIndex:(NSUInteger)index;

- (void)setTitleColumn:(NSArray*)data;
//- (void)setTitleRow:(NSArray*)data;

@end
