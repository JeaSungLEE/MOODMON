//
//  Moodmon.h
//  moodMon
//
//  Created by Lee Kyu-Won on 10/31/16.
//  Copyright © 2016 HUB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Realm.h"

@interface Moodmon : RLMObject

@property int idx;
@property NSString *moodComment;
@property NSInteger moodYear;
@property NSInteger moodMonth;
@property NSInteger moodDay;
@property NSString *moodTime;
@property int moodChosen1;
@property int moodChosen2;
@property int moodChosen3;
@property BOOL isDeleted;

@end
