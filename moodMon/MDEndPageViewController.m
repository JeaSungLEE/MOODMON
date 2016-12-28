//
//  MDEndPageViewController.m
//  moodMon
//
//  Created by 이재성 on 04/12/2016.
//  Copyright © 2016 HUB. All rights reserved.
//

#import "MDEndPageViewController.h"
#import "MDMonthViewController.h"
#import "MDDataManager.h"
#define CURRENT_WINDOW_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface MDEndPageViewController ()

@end
@implementation MDEndPageViewController
CGFloat startYPoint;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDate];
    [self makeMoodFace];
    [self setMoodFace];
    [self setTextToLabel];
//    [self setLabelImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)setTextToLabel{
    CGSize maximumSize = CGSizeMake(193, 60);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
    _rect = [_comment boundingRectWithSize:maximumSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    _commentTextView.translatesAutoresizingMaskIntoConstraints = YES;
    startYPoint = _moodView.frame.origin.y + 145 + 20;
    if(CURRENT_WINDOW_WIDTH>320)
        startYPoint += 55;
    _textRectFrame = CGRectMake((CURRENT_WINDOW_WIDTH-270)/2, startYPoint, 200, _rect.size.height+18);
    [_commentTextView setFrame:_textRectFrame];
    _commentTextView.text = _comment;
    _commentTextView.delegate = self;
    [_commentTextView setBackgroundColor:[UIColor clearColor]];
    _commentTextView.layer.cornerRadius = 4;
    _commentTextView.layer.borderWidth = 1;
    _commentTextView.layer.borderColor = [UIColor colorWithRed:0xf0/255.0 green:0xf0/255.0 blue:0xf0/255.0 alpha:1].CGColor;
    
    _saveButton.layer.cornerRadius = 10;
}

//-(void)setLabelImage{
//    [_backImage setFrame:_textRectFrame];
//    UIImage *Image = [UIImage imageNamed:@"messageBalloon.png"];
//    [_backImage setImage:[Image resizableImageWithCapInsets:UIEdgeInsetsMake(15, 100, 15, 100)]];
//}

-(void)setMoodFace{
    if(CURRENT_WINDOW_WIDTH==320){
        CGAffineTransform transform = CGAffineTransformMakeScale(0.46, 0.46);
        _bigView.transform = transform;
        _bigView.frame = CGRectMake(0, 0, 144, 144);
        [_dateLabelDetail setFont:[UIFont systemFontOfSize:12]];
        [_dateLabel setFont:[UIFont systemFontOfSize:12]];
    }
    else{
        CGAffineTransform transform = CGAffineTransformMakeScale(0.66, 0.66);
        _bigView.transform = transform;
        _bigView.frame = CGRectMake(0, 0, 200, 200);
    }
    [_moodView addSubview:_bigView];
}

-(void)makeMoodFace{
    _bigView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    _bigView.layer.cornerRadius = _bigView.frame.size.width/2;
    _bigView.layer.masksToBounds = YES;
    MDMoodColorView *colorView = [[MDMoodColorView alloc] initWithFrame:_bigView.frame];
    MDSaveMoodFaceView *faceView = [[MDSaveMoodFaceView alloc] initWithFrame:_bigView.frame];
    [_bigView addSubview:colorView];
    [_bigView addSubview:faceView];
    [_bigView setBackgroundColor:[UIColor clearColor]];
    [faceView setBackgroundColor:[UIColor clearColor]];
    [colorView setBackgroundColor:[UIColor clearColor]];
    
    [colorView awakeFromNib];
    colorView.chosenMoods = _moodColorView.chosenMoods;
    [colorView setNeedsDisplay];
    colorView.layer.cornerRadius = colorView.frame.size.width/2;
    colorView.layer.masksToBounds = YES;
    
    [faceView awakeFromNib];
    faceView.chosenMoods = _moodColorView.chosenMoods;
    [faceView setNeedsDisplay];
    faceView.layer.cornerRadius = faceView.frame.size.width/2;
    faceView.layer.masksToBounds = YES;
}

-(void)saveMoodMon{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, 300), _bigView.opaque, 0.0);
    [_bigView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:@"snapshot.png" options:NSDataWritingWithoutOverwriting error:Nil];
    [data writeToFile:@"snapshot.png" atomically:YES];
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:data], nil, nil, nil);
}

-(void)setDate{
    _dateLabelDetail.text = _dateString;
    _dateLabel.text =  _timest;
}

- (IBAction)closeButton:(id)sender {
    [self dissmissView];
}

-(void)dissmissView{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteBlur" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showAlertView:(NSString*)title Message:(NSString*)Message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:Message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if([title isEqualToString:@"DELETE"]) {
            [self dissmissView];
        }
    }];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)saveMoodButton:(id)sender {
    [self saveMoodMon];
    [self showAlertView:@"MoodMon" Message:NSLocalizedString(@"Saved to Camera Roll",nil)];
}

//***************
- (IBAction)commitModify:(id)sender {
    //아래 알림창은 데이터매니져로부터 데이터 수정 확인 응답을 받은 후 띄워야함.
    [self showAlertView:@"Moodmon" Message:NSLocalizedString(@"Edited", nil)];
}

- (IBAction)deleteMood:(id)sender {
    [[MDDataManager sharedDataManager] deleteAtRealmMoodmonIdx: self.idx];
    //아래 알림창은 데이터매니져로부터 데이터 수정 확인 응답을 받은 후 띄워야함.
    [self dissmissView];
    [self showAlertView:@"Moodmon" Message:NSLocalizedString(@"Deleted", nil)];
}
//*****************
//위두개는 렒으로 변경이후 추가.

- (void)textViewDidBeginEditing:(UITextView *)textView {

}
- (void)textViewDidChange:(UITextView *)textView{
    CGSize maximumSize = CGSizeMake(193, 60);
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
    CGRect currentRect = [textView.text boundingRectWithSize:maximumSize
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:attributes
                                              context:nil];
    if (currentRect.size.height != _rect.size.height){
        _rect = currentRect;
        _commentTextView.translatesAutoresizingMaskIntoConstraints = YES;
        _textRectFrame = CGRectMake((CURRENT_WINDOW_WIDTH-270)/2, startYPoint, 200, _rect.size.height+18);
        [_commentTextView setFrame:_textRectFrame];
//        [_backImage setFrame:_textRectFrame];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    //handle text editing finished
}
@end
