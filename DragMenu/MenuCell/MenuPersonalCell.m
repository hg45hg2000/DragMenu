//
//  MenuPersonalCell.m
//  poya
//
//  Created by HENRY on 2017/7/19.
//  Copyright © 2017年 Fommii. All rights reserved.
//

#import "MenuPersonalCell.h"

@interface MenuPersonalCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *memberButton;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointCurrencyLabel;

@property (weak, nonatomic) IBOutlet UIButton *faceBookButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
@property (weak, nonatomic) IBOutlet UIButton *youtubeButton;
@property (weak, nonatomic) IBOutlet UIButton *fourButton;

@end


@implementation MenuPersonalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.faceBookButton setupPoyaLinkEnumToTage:FacebookType];
    [self.instagramButton setupPoyaLinkEnumToTage:InstagramType];
    [self.youtubeButton setupPoyaLinkEnumToTage:YoutubeType];
    [self.fourButton setupPoyaLinkEnumToTage:LineType];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configurePersonalData:(UserPersonalData*)personalData{
    if (personalData) {
        self.titleLabel.text = [NSString stringWithFormat:@"Hi, %@",personalData.Name];
        if (personalData.Point) {
            NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:personalData.descriptionLabel];
            [attributedTitle  addAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} range:NSMakeRange(0, attributedTitle.length)];
            [self.memberButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
            self.memberButton.enabled = false;
            self.pointLabel.text = [personalData.Point stringValue];
            self.pointCurrencyLabel.hidden = false;
            self.pointLabel.hidden = false;
        }
        else{
            NSMutableAttributedString *attributedTitle = [NSString addUnderLind:personalData.descriptionLabel];
            [attributedTitle  addAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} range:NSMakeRange(0, attributedTitle.length)];
            [self.memberButton setAttributedTitle:attributedTitle  forState:UIControlStateNormal];
            self.memberButton.enabled = true;
            self.pointCurrencyLabel.hidden = true;
            self.pointLabel.hidden = true;
        }
    }
    else{
        self.pointCurrencyLabel.hidden = true;
        self.pointLabel.hidden = true;
    }
}
- (IBAction)sharedButtonSelected:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(MenuPersonalCellSharedButtonSelected:)]) {
        [self.delegate MenuPersonalCellSharedButtonSelected:sender.tag];
    }
}
- (IBAction)memberButtonPress:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(MenuPersonalCellMemberLoginButtonSelected)]) {
        [self.delegate MenuPersonalCellMemberLoginButtonSelected];
    }
}

@end
