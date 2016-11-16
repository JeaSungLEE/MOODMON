//
//  MDNewMoodTutorialViewController.m
//  moodMon
//
//  Created by 김기범 on 2016. 11. 7..
//  Copyright © 2016년 HUB. All rights reserved.
//

#import "MDNewMoodTutorialViewController.h"

@interface MDNewMoodTutorialViewController ()
@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;
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
    self.contents = @[@{@"text" : @"Welcome to MoodMon!\n\nBeneath is five MoodMons\nthat express your feelings.",
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : @"Tap one of the MoodMons\nwhich represents your feeling now!",
                        @"missionName" : @"TapMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : @"Good job!\nNow in the middle of the circle,\nyou can see the MoodMon\nyou've just chosen.",
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : @"Now tap the same MoodMon\njust you've chosen.",
                        @"missionName" : @"TapSameMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : @"Excellent!\nIf you tap same MoodMon again,\nyou can deselect it.",
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : @"Now press the MoodMon and\ndon't take your finger off.",
                        @"missionName" : @"PressMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : @"Great!\nNow wheel it to express\nhow much do you feel this emotion!",
                        @"missionName" : @"WheelMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : @"Wonderful!\n wheel to select how much do you feel,\nand take your finger off.",
                        @"missionName" : @"TakeFingerOffFromWheel",
                        @"hasNextButton" : @NO},
                      @{@"text" : @"Great!\nNow choose other MoodMons\nas the same way.",
                        @"missionName" : @"TapOtherMoodMon",
                        @"hasNextButton" : @NO},
                      @{@"text" : @"Very nice!\n You can choose and mix\ndifferent MoodMons.",
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : @"But remember,\nyou can mix 3 MoodMons at most!",
                        @"missionName" : @"none",
                        @"hasNextButton" : @YES},
                      @{@"text" : @"Now comment on your feelings\nbeneath the MoodMons!",
                        @"missionName" : @"Comment",
                        @"hasNextButton" : @NO},
                      @{@"text" : @"Great job!\n Now press button\nto save your feelings!\nOr button to exit.",
                        @"missionName" : @"none",
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
    [UIView animateWithDuration:0.2 animations:^{
        _textLabel.text = _contents[_currentIndex][@"text"];
        _nextButton.layer.opacity = ([_contents[_currentIndex][@"hasNextButton"] isEqual:@YES]) ? 1 : 0;
    }];
}

@end
