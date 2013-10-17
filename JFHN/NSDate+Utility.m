//
//  NSDate+Utility.m
//  JFHN
//
//  Created by Jack Flintermann on 10/17/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "NSDate+Utility.h"

@implementation NSDate (Utility)


- (BOOL) isToday {
    NSDate *beginningOfDate = [self beginningOfDay];
    NSDate *beginningOfToday = [[NSDate date] beginningOfDay];
    return [beginningOfDate timeIntervalSinceDate:beginningOfToday] < 1;
}

- (NSDate *)beginningOfDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:self];
    [components setHour:-components.hour];
    [components setMinute:-components.minute];
    [components setSecond:-components.second];
    return [calendar dateByAddingComponents:components toDate:self options:0];
}


@end
