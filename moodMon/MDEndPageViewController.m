//
//  MDEndPageViewController.m
//  moodMon
//
//  Created by 이재성 on 04/12/2016.
//  Copyright © 2016 HUB. All rights reserved.
//

#import "MDEndPageViewController.h"
#define CURRENT_WINDOW_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface MDEndPageViewController ()

@end

@implementation MDEndPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDate];
    [self makeMoodFace];
    [self setTextToLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)setTextToLabel{
    CGSize maximumSize = CGSizeMake(200, 60);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
    CGRect rect = [_comment boundingRectWithSize:maximumSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    _commentTextView.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat startYPoint = _moodView.frame.origin.y + _moodView.frame.size.height + 20;
    [_commentTextView setFrame:CGRectMake((CURRENT_WINDOW_WIDTH-240)/2, startYPoint, 200, rect.size.height+10)];
    _commentTextView.text = _comment;
}

-(void)makeMoodFace{
    UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    bigView.layer.cornerRadius = bigView.frame.size.width/2;
    bigView.layer.masksToBounds = YES;
    MDMoodColorView *colorView = [[MDMoodColorView alloc] initWithFrame:bigView.frame];
    MDSaveMoodFaceView *faceView = [[MDSaveMoodFaceView alloc] initWithFrame:bigView.frame];
    [bigView addSubview:colorView];
    [bigView addSubview:faceView];
    
    [colorView awakeFromNib];
    colorView.chosenMoods = _moodColorView.chosenMoods;
    [colorView setNeedsDisplay];
    colorView.layer.cornerRadius = colorView.frame.size.width/2;
    colorView.layer.masksToBounds = YES;
    
    
    [faceView awakeFromNib];
    faceView.chosenMoods = _moodColorView.chosenMoods;
    [faceView setNeedsDisplay];
    faceView.backgroundColor = [UIColor clearColor];
    faceView.layer.cornerRadius = faceView.frame.size.width/2;
    faceView.layer.masksToBounds = YES;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(0.66, 0.66);
    bigView.transform = transform;
    bigView.frame = CGRectMake(0, 0, 200, 200);
    [_moodView addSubview:bigView];
}

-(void)setDate{
    _dateLabel.text =  _timest;
}
- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
