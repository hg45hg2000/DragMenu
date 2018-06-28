//
//  MenuCell.h
//  poya
//
//  Created by Jerry on 2014/6/30.
//  Copyright (c) 2014年 Fommii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewControllerEnum.h"
#import "MenuCellViewModel.h"

@interface MenuCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imgIcon;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redPointImageView;

- (void)configureCell:(MenuCellViewModel*)model;

- (void)setCellSelected:(BOOL)selected;

@end
