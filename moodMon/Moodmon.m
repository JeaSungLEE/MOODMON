//
//  Moodmon.m
//  moodMon
//
//  Created by Lee Kyu-Won on 10/31/16.
//  Copyright © 2016 HUB. All rights reserved.
//

#import "Moodmon.h"


@implementation Moodmon

+ (NSString *)primaryKey {
    return @"idx";
}
+ (NSDictionary *)defaultPropertyValues {
    return @{@"isDeleted" : @NO};
    
}

@end
