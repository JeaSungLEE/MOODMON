//
//  MDEndPageViewController.h
//  moodMon
//
//  Created by 이재성 on 04/12/2016.
//  Copyright © 2016 HUB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDMakeMoodMonView.h"
#import "MDSaveMoodFaceView.h"

@interface MDEndPageViewController : UIViewController

@property (assign, nonatomic) int idx; //for writing data
@property (strong, nonatomic) IBOutlet UIView *moodView;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabelDetail;
@property (strong, nonatomic) IBOutlet MDMoodColorView *moodColorView;
@property (strong, nonatomic) IBOutlet UITextView *commentTextView;
@property (strong, nonatomic) IBOutlet UIImageView *backImage;
@property UIView *bigView;
@property CGRect textRectFrame;
@property NSString* timest;
@property NSString* comment;
@property NSString* dateString;
@property CGRect rect;

- (IBAction)closeButton:(id)sender;
- (IBAction)saveMoodButton:(id)sender;
- (IBAction)commitModify:(id)sender;
- (IBAction)deleteMood:(id)sender;
@end
