//
//  MDSearchTableViewCell.h
//  moodMon
//
//  Created by Lee Kyu-Won on 5/8/16.
//  Copyright © 2016 HUB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMoodColorView.h"

@interface MDSearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet MDMoodColorView *moodColorView;
@property NSString *timest;
@property NSString *date;
@end
