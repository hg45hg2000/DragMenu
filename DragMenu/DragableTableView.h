//
//  DragableTableView.h
//  poya
//
//  Created by HENRY on 2017/7/20.
//  Copyright © 2017年 Fommii. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DragableTableView;
@protocol DragTableViewDelegate <NSObject>

@optional
- (void)DragTableView:(DragableTableView *)dragTableView selectedRowAtIndexPath:(NSIndexPath*)indexPath;

- (void)DragTableViewWillOpen:(BOOL)Open;

@end

@interface DragableTableView : UITableView
// add edge drag tableview

- (void)setupMenuTableViewFrame:(CGRect)frame;

- (void)addEdgePanGesture:(UIView*)source;

- (void)addTableView:(UIView*)sourceView;


- (void)moveTableView;

- (void)moveMenuTableViewOpen:(BOOL)open;


//- (void)setupMenuList:(NSArray <MenuCellViewModel*>*)menuList;

- (void)setSelectedMenuCell:(BOOL)selected atIndexPath:(NSIndexPath*)indexPath;

@property(weak,nonatomic)id <DragTableViewDelegate> dragTableDelegate;
@property (assign,nonatomic)BOOL didOpenTableView;
@property (nonatomic, readonly) NSIndexPath *lastIndexPathForSelectedRow;
//@property(strong , nonatomic)NSMutableArray <MenuCellViewModel*>*menuList;
@end
