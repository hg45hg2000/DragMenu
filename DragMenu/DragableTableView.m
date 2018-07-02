//
//  DragableTableView.m
//  poya
//
//  Created by HENRY on 2017/7/20.
//  Copyright © 2017年 Fommii. All rights reserved.
//

#import "DragableTableView.h"

CGFloat const MenuWidthRadio = 0.6666;

CGFloat const MenuCellHeight = 48;

CGFloat const SiderAnimationDuration = 0.2;

CGFloat const PanGestureMove = -50;

CGFloat const EdgePanGestureMove = -100;

CGFloat const advoidOverMoveDistance = -8;

CGFloat const loadingViewDefaultBlockAphla  = 0.8;


@interface DragableTableView()<UIGestureRecognizerDelegate,UITableViewDelegate>

@property(strong , nonatomic)UIPanGestureRecognizer *panDrag;
@property(assign , nonatomic)BOOL didPanDragStart;
@property(assign , nonatomic)BOOL didScroll;
@property(strong , nonatomic)UIView *loadingView;


@end

@implementation DragableTableView


- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initMenuTableViewFrame:frame];
//        [self initMenuArray];
        [self initLoadingViewFrame:frame];
    }
    return self;
}



//- (void)updateNeedMenuData{
//    if (self.menuList.count > 1) {
//        [self.personalHeadView  configurePersonalData:[MemberDataManager sharedInstance].userData];
//        MenuCellViewModel *memberCellData = [[MenuCellViewModel alloc] initMenuType:PoyaMemberCenterViewControllerType];
//        [self.menuList replaceObjectAtIndex:1 withObject:memberCellData];
//        [self reloadData];
//    }
//}

//- (void)initMenuArray{
////    self.menuList = [MenuCellViewModel menuList];
////    [self updatePersonalData];
////    [self setupMenuList:self.menuList];
//
//    [self reloadData];
//}

- (void)initMenuTableViewFrame:(CGRect)frame{
    [self setupMenuTableViewFrame:frame];
    
    UIView *footerView = [[UIView alloc] initWithFrame:frame];
    footerView.backgroundColor = [UIColor whiteColor];
    self.tableFooterView = footerView;
    self.contentInset = UIEdgeInsetsMake(0.0, 0.0, -frame.size.height, 0.0);
    
    [self initComponent];
}


- (void)setupMenuTableViewFrame:(CGRect)frame{
    
    CGSize screenSize = frame.size;
    CGFloat tableViewWidth = screenSize.width * MenuWidthRadio;
    
    CGFloat positionX = self.didOpenTableView ? 0 : -tableViewWidth;
    
    self.frame = CGRectMake( positionX, 0, tableViewWidth, screenSize.height);
    [self setupLoadingViewFrame:frame];
}

- (void)initComponent{
    [self addPangGesture:self];
    self.delegate = self;

    self.showsHorizontalScrollIndicator = false;
}


- (void)initLoadingViewFrame:(CGRect)frame{
    
    self.loadingView = [[UIView alloc] init];
    [self setupLoadingViewFrame:frame];
    [self.loadingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveTableView)]];
    self.loadingView.alpha = 0;
    self.loadingView.backgroundColor = [UIColor blackColor];
}

- (void)setupLoadingViewFrame:(CGRect)frame{
    self.loadingView.frame = CGRectMake(0, 0, frame.size.width , frame.size.height);
}

#pragma mark publice method
- (void)addTableView:(UIView*)sourceView{
    [sourceView addSubview:self];
    [sourceView insertSubview:self.loadingView belowSubview:self];
}

//- (void)updatePersonalData{
//    [self.personalHeadView configurePersonalData: [MemberDataManager sharedInstance].userData];
//}
//- (void)setupMenuList:(NSArray <MenuCellViewModel*>*)menuList{
//    self.menuList = menuList.mutableCopy;
//}

- (void)addPangGesture:(UIView*)view{
    self.panDrag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTableViewPan:)];
    self.panDrag.delegate = self;
    [view addGestureRecognizer:self.panDrag];
}

- (void)addEdgePanGesture:(UIView*)source{
    UIScreenEdgePanGestureRecognizer *edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftEdgePanGesture:)];
    edgePan.edges = UIRectEdgeLeft;
    [source addGestureRecognizer:edgePan];
}

- (void)moveTableView{
    [self moveMenuTableViewOpen:!self.didOpenTableView];
}

- (void)moveMenuTableViewOpen:(BOOL)open{
    self.didOpenTableView = open;
    if (self.dragTableDelegate && [self.dragTableDelegate respondsToSelector:@selector(DragTableViewWillOpen:)]) {
        [self.dragTableDelegate DragTableViewWillOpen:open];
    }
    
    [UIView animateWithDuration:SiderAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.frame;
        frame.origin.x = self.didOpenTableView ?  0 : -self.frame.size.width;
        self.frame = frame;
        self.loadingView.alpha = self.didOpenTableView ? loadingViewDefaultBlockAphla: 0;
    } completion:nil];

}

- (void)setSelectedMenuCell:(BOOL)selected atIndexPath:(NSIndexPath*)indexPath{
//    self.menuList[indexPath.row].isCellSelected = selected;
}

#pragma  mark IScreenEdgePanGestureRecognizer
- (void)handleLeftEdgePanGesture:(UIScreenEdgePanGestureRecognizer*)edgePan{
    
    if (self.didOpenTableView || self.didPanDragStart) {
        return;
    }
    
    CGPoint translation = [edgePan translationInView:edgePan.view];
    switch (edgePan.state) {
        case UIGestureRecognizerStateChanged:{
            if (self.frame.origin.x > advoidOverMoveDistance) {
                break;
            }
            CGRect frame = self.frame;
            frame.origin.x += translation.x;
            self.frame = frame;
            [edgePan setTranslation:CGPointZero inView:edgePan.view];
        }
            break;
        case UIGestureRecognizerStateEnded:
            [self moveMenuTableViewOpen:(self.frame.origin.x) > EdgePanGestureMove];
            break;
        default:
            break;
    }
}

#pragma mark UIPanGestureRecognizer

- (void)handleTableViewPan:(UIPanGestureRecognizer*)panGesture{
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            self.didPanDragStart = true;
        }
            break;
        case UIGestureRecognizerStateChanged:{


            CGPoint translation = [panGesture translationInView:panGesture.view];
            
            if ((translation.x > 0 && self.frame.origin.x > advoidOverMoveDistance) || self.didScroll  ) {
                break;
            }
            CGRect frame = self.frame;
            if (frame.origin.x + translation.x <= 0) {
                frame.origin.x += translation.x;
                self.frame = frame;
            }
            [panGesture setTranslation:CGPointZero inView:panGesture.view];
        }
            break;
        case UIGestureRecognizerStateEnded:
            [self moveMenuTableViewOpen:!(self.frame.origin.x < PanGestureMove)];
            self.didPanDragStart = false;
            break;
        default:
            break;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.didScroll = true;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    self.didScroll = false;
}
#pragma mark UITableViewDelegate UITableViewDataSource

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.menuList.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    MenuCell *menu = [tableView dequeueReusableCellWithIdentifier:[MenuCell identifyer] forIndexPath:indexPath];
//    [menu configureCell:self.menuList[indexPath.row]];
//    return menu;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return MenuCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dragTableDelegate && [self.dragTableDelegate respondsToSelector:@selector(DragTableView:selectedRowAtIndexPath:)]) {
        [self.dragTableDelegate DragTableView:self selectedRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{;
    [self setSelectedMenuCell:false atIndexPath:indexPath];
    _lastIndexPathForSelectedRow = indexPath;
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    // only deal one gesture at one time 
    if (self.didScroll || self.didPanDragStart ) {
        return false;
    }
    return true;
}

@end
