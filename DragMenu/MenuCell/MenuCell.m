//
//  MenuCell.m
//  poya
//
//  Created by Jerry on 2014/6/30.
//  Copyright (c) 2014年 Fommii. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (void)configureCell:(MenuCellViewModel*)model{
    self.imgIcon.image = model.image;
    self.titleLabel.text = model.title;
    [self setCellSelected:model.isCellSelected];
    self.redPointImageView.hidden = model.unreadCount == 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellSelected:(BOOL)selected{
    self.backgroundColor = selected ? [UIColor colorWithWhite:0.8 alpha:1.0] : [UIColor whiteColor];
}

@end
