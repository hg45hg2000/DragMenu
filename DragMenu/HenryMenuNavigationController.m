//
//  HenryMenuNavigationController.m
//  poya
//
//  Created by HENRY on 2017/7/18.
//  Copyright © 2017年 Fommii. All rights reserved.
//

#import "HenryMenuNavigationController.h"
#import "ViewControllerMannger.h"

#import "DragableTableView.h"
//#import "MainViewController.h"
#import "PoyaTabarView.h"

#import "ProductAPI.h"
#import "AppSettinConfigure.h"

#import "PoyaMainViewController.h"
#import "LanguageHelper.h"
#import "SocialHelper.h"
#import "CBStoreHouseTransition.h"
#import "MemberDataManager.h"
#import "SearchViewController.h"
@interface HenryMenuNavigationController ()<
UITableViewDataSource,
DragTableViewDelegate
//,PoyaMainViewControllerDelegate
,MenuPersonalCellDelegate
,PoyaTabarViewDelegate
>

@property (strong, nonatomic)DragableTableView *tableView;
@property (strong, nonatomic)MenuCellViewModel *selectedMenuData;
@property (strong, nonatomic)UIMaskView *maskView;
@property (strong, nonatomic)PoyaTabarView *tabBarView;

@property (strong, nonatomic)UIViewController *currentViewController;
@property (strong, nonatomic)UIView *containView;
@property(strong , nonatomic)NSMutableArray <MenuCellViewModel*>*menuList;
@property (nonatomic)NSIndexPath *userTapIndexPathForSelectedRow;

@property (nonatomic)NSIndexPath *currentIndexPathForSelectedRow;


@end
@implementation HenryMenuNavigationController

+ (instancetype)sharedInstance{
    static HenryMenuNavigationController *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HenryMenuNavigationController alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupCommponent];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupCommponent];
    }
    return self;
}

//- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
//    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
////        [self setupCommponent];
//    }
//    return self;
//}


- (instancetype)initWithRootViewController:(UIViewController *)rootViewController{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setupCommponent];
        [self setupMenuRootViewController:rootViewController];
    }
    return self;
}

- (CGFloat)hideTabbarViewAtNavigationStack{
    self.tabBarView.hidden = self.viewControllers.count > 1;
    return self.tabBarView.hidden ? 0 : customTabbarViewHeight;
}

- (void)hideTabbarView:(BOOL)hide{
    self.tabBarView.hidden = hide;
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGSize viewSize = self.view.bounds.size;
    self.tabBarView.frame = CGRectMake(0, viewSize.height - customTabbarViewHeight, viewSize.width , customTabbarViewHeight);
    self.maskView.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
    [self.tableView setupMenuTableViewFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupCommponent{
    [self initUI];;
    [self updatePersonalData];
    [self registerNoficationEvent];
    _currentMenuControllerType = PoyaHomeViewControllerType;
    self.currentIndexPathForSelectedRow = [self selectedMenuIndexPath:self.currentMenuControllerType];
    [self.tabBarView setSelectedTabbarItem:self.currentMenuControllerType];
    [self selectedMenu:true];
    [self setupMenuRootViewController:[ViewControllerMannger getViewMenuController:PoyaHomeViewControllerType fromViewController:self]];
    self.menuList = [MenuCellViewModel menuList];
    [AppSettinConfigure requestShowCheckMeSuccess:^(BOOL isShow) {
        if (isShow) {
            [self.menuList addObject:[[MenuCellViewModel alloc]initMenuType:PoyaCheckMeViewControllerType]];
            [self.tableView reloadData];
        }
    } failure:nil];

}

- (void)registerNoficationEvent{
    [PoyaNotificationCenter registerUserLoginEventWithObject:self performSelector:@selector(updateNeedMenuData)];
    
    [PoyaNotificationCenter registerUserLoginOutEventWithObject:self performSelector:@selector(updateNeedMenuData)];
    
    [PoyaNotificationCenter registerUserDataUpdateWithObject:self performSelector:@selector(updatePersonalData)];
}

- (void)setupMenuRootViewController:(UIViewController*)rootViewController{
    [self addMenuButton:rootViewController];
    self.viewControllers = @[rootViewController];
}

//- (void)addViewController:(UIViewController*)viewController{
//    _currentViewController = viewController;
//    [self addChildViewController:viewController];
//    [self.containView addSubview:viewController.view];
//    _currentViewController.view.frame = self.containView.bounds;
//    _currentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [_currentViewController didMoveToParentViewController:self];
//}
//
//
//- (void)remoeLastViewController{
//    [self.currentViewController willMoveToParentViewController:nil];
//    [self.currentViewController.view removeFromSuperview];
//    [self.currentViewController removeFromParentViewController];
//}

- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self initTabbarView];
    [self initMenuTableView];
//    [self initWatingView];
}


- (void)initTabbarView{
    self.tabBarView = [[PoyaTabarView alloc] PoyaCodeXibConntect];
    self.tabBarView.menuDelegate = self;
    [self.view addSubview:self.tabBarView];
}

- (void)hideTabbarView{
    self.tabBarView.hidden = true;
}



- (void)moveTableView{
    [self.tableView moveTableView];
}

- (void)initMenuTableView{
    self.tableView = [[DragableTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dragTableDelegate = self;
    self.tableView.dataSource = self;
    UIView *view =  self.view;
    [self.tableView addEdgePanGesture:view];
    [self.tableView addTableView:view];
    [self.tableView registerMenuPersonalCellDelegate:self];
}

- (void)updateNeedMenuData{
    if (self.menuList.count > 1) {
//        [self.tableView.personalHeadView  configurePersonalData:[MemberDataManager sharedInstance].userData];
        MenuCellViewModel *memberCellData = [[MenuCellViewModel alloc] initMenuType:PoyaMemberCenterViewControllerType];
        [self.menuList replaceObjectAtIndex:1 withObject:memberCellData];
        [self.tableView reloadData];
    }
}

- (void)updatePersonalData{
    [self.tableView.personalHeadView configurePersonalData: [MemberDataManager sharedInstance].userData];
    [MessageAPI requestUserUnReadListSuccess:^(UnreadMessageData *responseData) {
        [self.menuList enumerateObjectsUsingBlock:^(MenuCellViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            switch (obj.menuViewControllerType) {
                case PoyaDiscountListViewContollerType:
                    obj.unreadCount = responseData.discount;
                    break;
                case PoyaPointExchangeViewControllerType:
                    obj.unreadCount = responseData.gift;
                    break;
                case PoyaNewViewControllerType:
                    obj.unreadCount = responseData.project;
                    break;
                default:
                    break;
            }
        }];
         [self.tableView reloadData];
    } failure:nil];
}

- (void)updateReadCount:(ReadListType)type count:(NSInteger)count{
    [self.menuList enumerateObjectsUsingBlock:^(MenuCellViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.menuViewControllerType) {
            case PoyaDiscountListViewContollerType:
                if (type == DiscountListType) {
                    obj.unreadCount = count;
                }
                break;
            case PoyaPointExchangeViewControllerType:
                if (type == GiftListType) {
                    obj.unreadCount = count;
                }
                break;
            case PoyaNewViewControllerType:
                if (type == NewsListType) {
                    obj.unreadCount = count;
                }
                break;
            default:
                break;
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.tableView reloadData];
    });
}


#pragma mark PoyaTabarViewDelegate

- (void)PoyaTabarView:(PoyaTabarView*)poyaTabarView SelectedMenuType:(PoyaMenuControllerType)menuType{
    [self changeMenuControllerSelectedType:menuType openMenu:false complete:^(UIViewController *currentViewController) {
        if (currentViewController) {
            [poyaTabarView setSelectedTabbarItem:menuType];
        }else{
            [poyaTabarView setSelectedTabbarItem:self.currentMenuControllerType];
        }
    }];
}


#pragma mark MenuPersonalCellDelegate

- (void)MenuPersonalCellSharedButtonSelected:(PoyaLinkType)LinkType{
    [self moveTableView];
    [ViewControllerMannger FromViewController:self.topViewController pushToViewController:[SocialHelper PoyaSharedPushControllerType:LinkType] passContent:[SocialHelper PoyaSharedLinkWebUrl:LinkType] withDelegate:self.topViewController];
    
}
- (void)MenuPersonalCellMemberLoginButtonSelected{
    [self changeMenuControllerSelectedType:PoyaMemberCenterViewControllerType openMenu:false complete:nil];
}


- (void)addMenuButton:(UIViewController*)viewController{
    
    viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem MenuButtonTarget:self selector:@selector(moveTableView)];
    
    __weak typeof(self)weakSelf = self;
    viewController.navigationItem.rightBarButtonItem = [UIBarButtonItem SearchPriceAndSerchProductButtonTarget:self SelectedBlock:^(PoyaNavigationBarButtonType buttonType) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        switch (buttonType) {
            case SearchProductOnOnlineShop:{
                [ViewControllerMannger popSearchViewController:self resultBlcok:^(NSString *result) {
                        ProductAPIParameter *resultParameter =   [[ProductAPIParameter alloc] init];
                        resultParameter.searchContent = result;
                        [ViewControllerMannger FromViewController:strongSelf.topViewController pushToViewController:PoyaSearchProdcutViewControllerType passContent:resultParameter withDelegate:strongSelf.topViewController];
                }];
            }
                break;
            case ScanProductBarcode:
                [self changeMenuControllerSelectedType:PoyaIquireMerchantViewControllerType openMenu:false complete:nil];
                break;
            default:
                break;
        }
    }];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menuList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MenuCell *menu = [tableView dequeueReusableCellWithIdentifier:[MenuCell identifyer] forIndexPath:indexPath];
    [menu configureCell:self.menuList[indexPath.row]];
    return menu;
}

#pragma mark DragTableViewDelegate
- (void)DragTableView:(DragableTableView *)dragTableView selectedRowAtIndexPath:(NSIndexPath*)indexPath{
    self.selectedMenuData = self.menuList[indexPath.row];
    [self changeMenuControllerSelectedType:self.selectedMenuData.menuViewControllerType openMenu:false complete:^(UIViewController *currentViewController) {
//        if (currentViewController) {
//            [self.tabBarView setSelectedTabbarItem:self.selectedMenuData.menuViewControllerType];
//        }
    }];
}


- (void)changeMenuControllerSelectedType:(PoyaMenuControllerType)menuType openMenu:(BOOL)open complete:(void(^)(UIViewController *currentViewController))complete{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self changeUserSelectedMenuType:menuType];
        [self.maskView showInView:self.view];
        [AnalyzeEventHelper sendAnalyzeEventDict:[[AnalyzeEventParameter alloc] initMenuEvent:menuType]];
        
        [ViewControllerMannger getViewControllerType:menuType PassContent:nil sendViewController:^(UIViewController *viewController, PoyaMenuControllerType controllerType) {
            // selected  animation
            if (viewController) {
                // clear  last selected
                [self selectedMenu:false];
                self.currentIndexPathForSelectedRow = self.userTapIndexPathForSelectedRow  ? : self.currentIndexPathForSelectedRow;
                [self setupMenuRootViewController:viewController];
                [self.tabBarView setSelectedTabbarItem:controllerType];
            }
            
            [self selectedMenu:true];
            [self.maskView removeFromSuperview];
            if (complete) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete(viewController);
                });
            }
        } fromViewController:self menuCloseBlcok:^{
            [self.tableView moveMenuTableViewOpen:open];
        }];
    });
}

- (void)changeUserSelectedMenuType:(PoyaMenuControllerType)menuType{
    self.userTapIndexPathForSelectedRow = [self selectedMenuIndexPath:menuType];
}

- (void)selectedMenu:(BOOL)selected {
    [self.tableView setSelectedMenuCell:selected atIndexPath:self.currentIndexPathForSelectedRow];
}

- (NSIndexPath*)selectedMenuIndexPath:(PoyaMenuControllerType)menuType{
    NSInteger selectedRow = 0;
    for (NSInteger i = 0; i < self.menuList.count; i ++) {
        MenuCellViewModel *menuViewModel = self.menuList[i];
        if (menuViewModel.menuViewControllerType == menuType) {
            selectedRow = i;
            _currentMenuControllerType = menuType;
            break;
        }
    }
    return [NSIndexPath indexPathForRow:selectedRow inSection:0];
}
//#pragma mark
//-(BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//-(UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskAll;
//}
//
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
//}

@end
