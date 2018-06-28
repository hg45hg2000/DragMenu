//
//  HenryMenuNavigationController.h
//  poya
//
//  Created by HENRY on 2017/7/18.
//  Copyright © 2017年 Fommii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PoyaBaseNavigationViewController.h"
#import "MessageAPI.h"

@interface HenryMenuNavigationController : PoyaBaseNavigationViewController

+ (instancetype)sharedInstance;

- (void)setupMenuRootViewController:(UIViewController*)rootViewController;

- (CGFloat)hideTabbarViewAtNavigationStack;

- (void)changeMenuControllerSelectedType:(PoyaMenuControllerType)menuType openMenu:(BOOL)open complete:(void(^)(UIViewController *currentViewController))complete;

// OverWrite UserSelected
- (void)changeUserSelectedMenuType:(PoyaMenuControllerType)menuType;

- (void)updateReadCount:(ReadListType)type count:(NSInteger)count;

- (void)hideTabbarView:(BOOL)hide;

@property (assign , readonly)PoyaMenuControllerType currentMenuControllerType;
@end
