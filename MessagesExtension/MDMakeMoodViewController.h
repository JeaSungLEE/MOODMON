//
//  MDNewMoodViewController.h
//  MoodMon
//
//  Created by Kibeom Kim on 2016. 3. 27..
//  Copyright © 2016년 Kibeom Kim. All rights reserved.
//

#import "UIView+Capture.h"
#import <Messages/Messages.h>
#import <UIKit/UIKit.h>
#import "MDDataManager.h"
#import "MDWheelView.h"
#import "MDMoodFaceView.h"
#import "MDMoodColorView.h"
#import "MDMoodButtonView.h"
#import "MDRecentMoodView.h"
#import "MDProgressWheelView.h"
#import "MDWheelGestureRecognizer.h"
#import "MDTouchDownGestureRecognizer.h"
#import "MDTouchUpGestureRecognizer.h"
#import "MDSmallMoodFaceView.h"

@protocol MDMessageDelegate <NSObject>

@required
-(void)setLayout:(MSMessageTemplateLayout *)layout;

@end

@interface MDMakeMoodViewController : UIViewController <MDMessageDelegate,MDWheelGestureRecognizerDelegate, UITextFieldDelegate>

/* Model */
@property MDMoodmon *mood;

/* DataManager */
@property MDDataManager *dataManager;

/* Timer */
@property CFTimeInterval startTime; // store time when mood button view clicked

/* Tool Tip */
@property UIMenuController *menuController;
@property UIDynamicAnimator *animator;

/* Mood Buttons */
@property (strong, nonatomic) IBOutlet MDMoodButtonView *angry;
@property (strong, nonatomic) IBOutlet MDMoodButtonView *joy;
@property (strong, nonatomic) IBOutlet MDMoodButtonView *sad;
@property (strong, nonatomic) IBOutlet MDMoodButtonView *excited;
@property (strong, nonatomic) IBOutlet MDMoodButtonView *tired;

/* Wheel */
@property (strong, nonatomic) IBOutlet UIView *container;
@property (strong, nonatomic) IBOutlet MDWheelView *wheel;
@property (strong, nonatomic) IBOutlet MDProgressWheelView *progressWheel;
@property (strong, nonatomic) IBOutlet MDMoodColorView *moodColor;
@property (strong, nonatomic) IBOutlet MDMoodFaceView *mixedMoodFace;
@property (strong, nonatomic) IBOutlet UIImageView *moodIntensityView;
@property BOOL didWheel;

/* Recent Mood */
@property (strong, nonatomic) IBOutlet MDRecentMoodView *recentMoodView;

/* Comment */
@property NSString *comment;

/* Skip & Save */
@property (strong, nonatomic) IBOutlet MDMoodColorView *saveButtonBackground;


@property (weak, nonatomic) id<MDMessageDelegate> delegate;
//@property (weak, nonatomic) MSConversation *Conversation;


- (void) showAlert:(NSNotification*)notification;
+ (UIImage *) imageWithView:(UIView *)view;
//-(void) presentCalendar;

@end

