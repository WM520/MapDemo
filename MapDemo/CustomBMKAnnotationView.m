//
//  CustomBMKAnnotationView.m
//  MapDemo
//
//  Created by David on 16/9/6.
//  Copyright © 2016年 WM. All rights reserved.
//

#import "CustomBMKAnnotationView.h"

@interface CustomBMKAnnotationView ()

@property (nonatomic, strong) UILabel *cityLabel;
@property (nonatomic, strong) UILabel *streetLabel;

@end

@implementation CustomBMKAnnotationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI
{
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    [self addSubview:_cityLabel];
    self.streetLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.frame.size.width, 30)];
    [self addSubview:_streetLabel];
}

- (void)setModel:(CityModel *)model
{
    _model = model;
    self.cityLabel.text = model.cityname;
    self.streetLabel.text = model.street_information;
}

@end
