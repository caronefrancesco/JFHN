//
//  JRFEntry.m
//  JFHN
//
//  Created by Jack Flintermann on 10/11/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "JRFEntry.h"
#import "JRFComment.h"

@interface JRFDummyValueTransformer : NSValueTransformer {
    id _value;
}

- (instancetype) initWithValue:(id)value;

@end

@implementation JRFDummyValueTransformer

- (instancetype) initWithValue:(id)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}

- (id)transformedValue:(id)value {
    return _value;
}
@end

@implementation JRFEntry

+ (NSString *)managedObjectEntityName {
    return @"Entry";
}

+ (NSDictionary *)managedObjectKeysByPropertyKey {
    return @{
             @"authorName": @"authorName",
             @"comments": [NSNull null],
             @"commentCount": @"commentCount",
             @"domain": @"domain",
             @"frontpagePosition": @"frontpagePosition",
             @"interestingProbability": @"interestingProbability",
             @"uninterestingProbability": @"uninterestingProbability",
             @"readAt": @"readAt",
             @"markedAsUninterestingAt": @"markedAsUninterestingAt",
             @"score": @"score",
             @"storyId": @"storyId",
             @"submittedAt": @"submittedAt",
             @"title": @"title",
             @"type": @"type",
             @"urlString": @"urlString",
             };
}

- (void)mergeValueForKey:(NSString *)key fromModel:(MTLModel *)model {
    if ([key isEqualToString:@"readAt"] || [key isEqualToString:@"markedAsUninterestingAt"]) {
        if (![self valueForKey:key] && [model valueForKey:key]) {
            id value = [model valueForKey:key];
            [self setValue:value forKey:key];
        }

    }
}

+ (NSSet *)propertyKeysForManagedObjectUniquing {
    return [NSSet setWithObject:@"storyId"];
}

- (NSURL *) url {
    return [NSURL URLWithString:self.urlString];
}

- (JRFComment *)commentAtIndex:(NSInteger)index {
    return [self.comments objectAtIndex:index];
}


- (NSInteger) commentCount {
    if (self.comments) {
        return self.comments.count;
    }
    return _commentCount;
}

@end
