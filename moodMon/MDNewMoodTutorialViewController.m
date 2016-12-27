//
//  MDNewMoodTutorialViewController.m
//  moodMon
//
//  Created by 김기범 on 2016. 11. 7..
//  Copyright © 2016년 HUB. All rights reserved.
//

#import "MDNewMoodTutorialViewController.h"
#import "MDNewMoodTutorialView.h"

@interface MDNewMoodTutorialViewController ()
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) IBOutlet UIImageView *tutorialBox;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tutorialBoxTopConstraint;
@property NSArray *contents;
@property NSInteger currentIndex;
@end

@implementation MDNewMoodTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareContents];
    _currentIndex = -1;
    [self showNextContents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFinishMission:) name:@"DidFinishTutorialMission"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareContents {
    self.contents = @[@{@"text" : NSLocalizedString(@"Welcome to MoodMon!\n\nBeneath is five MoodMons\nthat express your feelings.", nil),
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : NSLocalizedString(@"Tap one of the MoodMons\nwhich represents your feeling now!", nil),
                        @"missionName" : @"TapMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : NSLocalizedString(@"Good job!\nNow in the middle of the circle,\nyou can see the MoodMon\nyou've just chosen.", nil),
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : NSLocalizedString(@"Now tap the same MoodMon\njust you've chosen.",nil),
                        @"missionName" : @"TapSameMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : NSLocalizedString(@"Excellent!\nIf you tap same MoodMon again,\nyou can deselect it.", nil),
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : NSLocalizedString(@"Now press the MoodMon and\ndon't take your finger off.",nil),
                        @"missionName" : @"PressMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : NSLocalizedString(@"Great!\nNow wheel it to express\nhow much do you feel this emotion!", nil),
                        @"missionName" : @"WheelMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : NSLocalizedString(@"Wonderful!\n wheel to select how much do you feel,\nand take your finger off.",nil),
                        @"missionName" : @"TakeFingerOffFromWheel",
                        @"hasNextButton" : @NO},
                      @{@"text" : NSLocalizedString(@"Great!\nNow choose other MoodMons\nas the same way.",nil),
                        @"missionName" : @"TapOtherMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : NSLocalizedString(@"Very nice!\n You can choose and mix\ndifferent MoodMons.", nil),
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : NSLocalizedString(@"But remember,\nyou can mix 3 MoodMons at most!",nil),
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : NSLocalizedString(@"Now comment on your feelings\nbeneath the MoodMons!", nil),
                        @"missionName" : @"Comment",
                        @"hasNextButton" : @NO},
                      @{@"text" : NSLocalizedString(@"Great job!\n Now press top left button\nto save your feelings!\nOr top right button to exit.",nil),
                        @"missionName" : @"Exit",
                        @"hasNextButton" : @NO}];
}

- (void)didFinishMission:(NSNotification *)noti {
    NSString *receivedMissionName = noti.userInfo[@"missionName"];
    NSString *currentMissionName = _contents[_currentIndex][@"missionName"];
    if([receivedMissionName isEqualToString:currentMissionName]) {
        [self showNextContents];
    }
}

- (IBAction)next:(id)sender {
    [self showNextContents];
}


- (void)showNextContents {
    _currentIndex++;
    
    if([_contents[_currentIndex][@"missionName"] isEqual:@"Exit"]) {
        _tutorialBoxTopConstraint.constant = self.view.frame.size.height/2 - 150;
        
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.4 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTouchArea"
                                                                object:nil
                                                              userInfo:@{@"touchAreaBottom":[NSNumber numberWithFloat:_tutorialBox.frame.origin.y]}];
        }];
    }
    
    [UIView transitionWithView:_textLabel
                      duration:0.2
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations:^{
                        _textLabel.text = _contents[_currentIndex][@"text"];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.2 animations:^{
                            _nextButton.layer.opacity = ([_contents[_currentIndex][@"hasNextButton"] isEqual:@YES]) ? 1 : 0;
                        }];
                        if([_contents[_currentIndex][@"missionName"] isEqual:@"Comment"]) {
                            [self drawCircleAroundCommentField];
                        }
                    }];
}


- (void)drawCircleAroundCommentField {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:_textFieldFrame];
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    pathLayer.path = path.CGPath;
    pathLayer.fillColor = [UIColor clearColor].CGColor;
    pathLayer.strokeColor = [UIColor colorWithRed:1.00 green:0.42 blue:0.42 alpha:1.00].CGColor;
    pathLayer.lineWidth = 9;
    pathLayer.lineCap = kCALineCapRound;
    [self.view.layer addSublayer:pathLayer];
    
    
    [CATransaction begin];
    // draw circle
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [CATransaction setCompletionBlock:^{
        // fade out circle
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeAnimation.duration = 0.3;
        fadeAnimation.beginTime = CACurrentMediaTime() + 0.5;
        fadeAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
        fadeAnimation.toValue = [NSNumber numberWithFloat:0.0f];
        fadeAnimation.removedOnCompletion = NO;
        fadeAnimation.fillMode = kCAFillModeBoth;
        [pathLayer addAnimation:fadeAnimation forKey:@"opacity"];
    }];
    [pathLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    [CATransaction commit];
}

@end
