//
//  NSDictionary+NilSafe.h
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NilSafe)

- (id) nilSafeForKey:(id)key;

@end
