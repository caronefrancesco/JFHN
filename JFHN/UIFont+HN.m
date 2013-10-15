//
//  UIFont+HN.m
//  JFHN
//
//  Created by Jack Flintermann on 10/14/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "UIFont+HN.h"

@implementation UIFont (HN)

+ (UIFont *)primaryAppFont {
    return [self primaryAppFontWithSize:16];
}
+ (UIFont *)primaryAppFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Medium" size:size];
}

+ (UIFont *)secondaryAppFont {
    return [self secondaryAppFontWithSize:14];
}

+ (UIFont *)secondaryAppFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"AvenirNext-Regular" size:size];
}

@end
