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

- (void)awakeFromNib {
    [super awakeFromNib];
    _touchAreaTop = 30 + [UIScreen mainScreen].bounds.size.height * 160/667;
    _touchAreaBottom = [UIScreen mainScreen].bounds.size.height;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeTouchArea:)
                                                 name:@"changeTouchArea"
                                               object:nil];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // UIView will be "transparent" for touch events if we return NO
    NSLog(@"tutorial touched %@", (point.y > _touchAreaBottom || point.y < _touchAreaTop) ? @"inside" : @"outside");
    return (point.y > _touchAreaBottom || point.y < _touchAreaTop);
}

- (void)changeTouchArea:(NSNotification *)noti {
    _touchAreaTop = 0;
    _touchAreaBottom = [noti.userInfo[@"touchAreaBottom"] floatValue];
}

@end
