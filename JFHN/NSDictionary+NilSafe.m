//
//  NSDictionary+NilSafe.m
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "NSDictionary+NilSafe.h"

@implementation NSDictionary(NilSafe)
- (id) nilSafeForKey:(id)key {
    id val = [self objectForKey:key];
    if (val == [NSNull null]) {
        return nil;
    }
    return val;
}

@end
