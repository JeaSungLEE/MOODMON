//
//  MDNewMoodTutorialView.m
//  moodMon
//
//  Created by 김기범 on 2016. 11. 7..
//  Copyright © 2016년 HUB. All rights reserved.
//

#import "MDNewMoodTutorialView.h"

@implementation MDNewMoodTutorialView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    return (point.y > self.frame.size.height || point.y < 30+(self.frame.size.height*160/667));
}

@end
