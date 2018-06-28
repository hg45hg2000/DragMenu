//
//  MenuPersonalCell.h
//  poya
//
//  Created by HENRY on 2017/7/19.
//  Copyright © 2017年 Fommii. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UserDataAPI.h"
#import "PoyaLinkEnum.h"

@protocol MenuPersonalCellDelegate <NSObject>

- (void)MenuPersonalCellSharedButtonSelected:(PoyaLinkType)LinkType;

- (void)MenuPersonalCellMemberLoginButtonSelected;

@end

@interface MenuPersonalCell : UITableViewCell

- (void)configurePersonalData:(UserPersonalData*)personalData;

@property(weak , nonatomic)id <MenuPersonalCellDelegate> delegate;

@end
