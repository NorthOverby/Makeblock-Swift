//
//  UIBorderedButton.m
//  AlertView
//
//  Created by North Overby on 4/23/16.
//  Copyright © 2016 North Overby. All rights reserved.
//

#import "UIBorderedButton.h"

@implementation UIBorderedButton

- (void)configureButton {
    self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    self.layer.borderWidth = 1.0;
    UIColor *defaultBlue = [UIColor colorWithRed:0.0f
                                           green:122.0f/255.0f
                                            blue:1.0f
                                           alpha:1.0f];
    self.layer.borderColor = [defaultBlue CGColor];
    self.layer.cornerRadius = self.cornerRadius;
}

- (void)setDefaults {
    self.cornerRadius = 5.0f;
}

- (void)setup {
    [self setDefaults];
    [self configureButton];
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    // super calls initWithFrame:, so setup button there
    UIBorderedButton *btn = [super buttonWithType:buttonType];
    return btn;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    UIBorderedButton *btn = [super initWithCoder:aDecoder];
    [btn setup];
    return btn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    UIBorderedButton *btn = [super initWithFrame:frame];
    [btn setup];
    return btn;
}

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    [self configureButton];
}


@end
