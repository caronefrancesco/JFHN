//
//  UIColor+HN.m
//  JFHN
//
//  Created by Jack Flintermann on 10/14/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "UIColor+HN.h"

@implementation UIColor (HN)

+ (UIColor *)appTintColor {
    return [UIColor orangeColor];
}

- (UIColor *) adjustedColorForRefreshControl {
    CGFloat h, s, b;
    [[UIColor appTintColor] getHue:&h saturation:&s brightness:&b alpha:nil];
    return [UIColor colorWithHue:h saturation:s/2 brightness:b alpha:1.0];
}

@end
