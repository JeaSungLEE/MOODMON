//
//  MDNewMoodViewController.m
//  MoodMon
//
//  Created by Kibeom Kim on 2016. 3. 27..
//  Copyright © 2016년 Kibeom Kim. All rights reserved.
//

#define CURRENT_WINDOW_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define CURRENT_WINDOW_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#import "MDMakeMoodViewController.h"

@interface MDMakeMoodViewController ()
@property CGFloat wheelDegree;
@property NSInteger moodCount;
@property NSArray *moodButtons;
@property NSArray *choosingMoodImages;
@property NSMutableArray *chosenMoods;
@property int previousIntensity;
@end



@implementation MDMakeMoodViewController
@synthesize delegate;
@synthesize wheelDegree;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chosenMoods = [[NSMutableArray alloc] init];
    [self moodViewInit];
    [self addTapGestureRecognizer];
    [self addWheelGestureRecognizer];
    [self drawRecentMoodView];
    [self menuControllerInit];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self roundedViewsInit];
}

- (void)drawRecentMoodView {
    NSUInteger recentMood = [self.dataManager recentMood];
    NSLog(@"recent mood : %lu", (unsigned long)recentMood);
    self.recentMoodView.recentMood = recentMood;
    [self.recentMoodView setNeedsDisplay];
}


- (void)moodViewInit {
    self.moodCount = 0;
    
    /* moodDegree init */
    self.moodIntensityView.hidden = YES;
    NSArray *angryMoodImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"angry_degree1"],[UIImage imageNamed:@"angry_degree2"],[UIImage imageNamed:@"angry_degree3"],[UIImage imageNamed:@"angry_degree4"],[UIImage imageNamed:@"angry_degree5"], nil];
    NSArray *joyMoodImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"joy_degree1"],[UIImage imageNamed:@"joy_degree2"],[UIImage imageNamed:@"joy_degree3"],[UIImage imageNamed:@"joy_degree4"],[UIImage imageNamed:@"joy_degree5"], nil];
    NSArray *sadMoodImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"sad_degree1"],[UIImage imageNamed:@"sad_degree2"],[UIImage imageNamed:@"sad_degree3"],[UIImage imageNamed:@"sad_degree4"],[UIImage imageNamed:@"sad_degree5"], nil];
    NSArray *excitedMoodImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"excited_degree1"],[UIImage imageNamed:@"excited_degree2"],[UIImage imageNamed:@"excited_degree3"],[UIImage imageNamed:@"excited_degree4"],[UIImage imageNamed:@"excited_degree5"], nil];
    NSArray *tiredMoodImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"tired_degree1"],[UIImage imageNamed:@"tired_degree2"],[UIImage imageNamed:@"tired_degree3"],[UIImage imageNamed:@"tired_degree4"],[UIImage imageNamed:@"tired_degree5"], nil];
    self.choosingMoodImages = [NSArray arrayWithObjects:angryMoodImages, joyMoodImages, sadMoodImages, excitedMoodImages, tiredMoodImages, nil];
    
    /* moodButton init */
    self.angry.num = @10;
    self.joy.num = @20;
    self.sad.num = @30;
    self.excited.num = @40;
    self.tired.num = @50;
    self.angry.name = @"angry";
    self.joy.name = @"joy";
    self.sad.name = @"sad";
    self.excited.name = @"excited";
    self.tired.name = @"tired";
    self.angry.startAngle = 0;
    self.joy.startAngle = 1.2;
    self.sad.startAngle = 2.47;
    self.excited.startAngle = 3.8;
    self.tired.startAngle = 5.1;
    self.moodButtons = @[self.angry, self.joy, self.sad, self.excited, self.tired];
    
}


- (void)roundedViewsInit {
    /* moodColor & mixedMoodFace init */
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    self.moodColor.layer.cornerRadius = self.moodColor.frame.size.width/2;
    self.moodColor.layer.masksToBounds = YES;
    self.moodColor.hidden = NO;
    self.mixedMoodFace.layer.cornerRadius = self.mixedMoodFace.frame.size.width/2;
    self.mixedMoodFace.layer.masksToBounds = YES;
    
    /* save & reset button background */
    self.saveButtonBackground.hidden = YES;
    self.saveButtonBackground.layer.cornerRadius = self.saveButtonBackground.frame.size.width/2;
    self.saveButtonBackground.layer.masksToBounds = YES;
    self.saveButtonBackground.layer.opacity = 0.9;
}




- (void)menuControllerInit {
    _menuController = [UIMenuController sharedMenuController];
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}


- (void)showAlert:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:[userInfo objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)addTapGestureRecognizer {
    for(UIImageView *mood in self.moodButtons){
        mood.userInteractionEnabled = YES;
        MDTouchDownGestureRecognizer *touchDownRecognizer = [[MDTouchDownGestureRecognizer alloc] initWithTarget:self action:@selector(moodButtonTouchedDown:)];
        MDTouchUpGestureRecognizer *touchUpRecognizer = [[MDTouchUpGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(moodButtonTouchedUp:)];
        [mood addGestureRecognizer:touchDownRecognizer];
        [mood addGestureRecognizer:touchUpRecognizer];
    }
}



- (void)moodButtonTouchedDown:(UIGestureRecognizer *)recognizer {

    MDMoodButtonView *moodButton = (MDMoodButtonView *)recognizer.view;
    if(self.moodCount<3 || moodButton.isSelected) {     // 이미 감정을 세 개 이상 골랐으면 더 선택할 수 없음. 단 기존에 선택한 것을 해제하는건 됨.
        [self changeMoodButtonImage:moodButton];
    }
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if(self.moodCount<1) {
                            self.mixedMoodFace.hidden = YES;
                            [self.mixedMoodFace setNeedsDisplay];
                        } else {
                            self.mixedMoodFace.hidden = NO;
                        }
                        [self setChoosingMoodImageByNum:moodButton.num];
                        [_menuController setMenuVisible:NO animated:YES];
                    }
                    completion:nil];
    if(moodButton.isSelected) {     // 감정을 선택하기 위해 버튼을 누른 경우 휠을 띄워줌.
        _didWheel = NO;
        _startTime = CACurrentMediaTime();
        [self showWheelView:moodButton];
        [self addNewChosenMood:moodButton.num];
        return;
    }
    if(moodButton.isSelected==NO && [self isChosen:moodButton]) {      // 감정선택을 해제하기 위해 버튼을 누른 경우, 해당 감정을 chosenMoods 배열에서 제거함.
        [self deleteFromChosenMoods:moodButton.num];
    }
}


- (void)menuControllerDisappear {
    [_menuController setMenuVisible:NO animated:YES];
}


- (void)menuControllerAppear:(MDMoodButtonView *)moodButton {
//    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:moodButton.superview];
//    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[moodButton]];
//    gravityBehavior.magnitude = 0.2;
//    [self.animator addBehavior:gravityBehavior];
//    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[moodButton]];
//    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
//    [self.animator addBehavior:collisionBehavior];
//    UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[moodButton]];
//    elasticityBehavior.elasticity = 0.7f;
//    [self.animator addBehavior:elasticityBehavior];
//
//    
//    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Press and wheel to choose your mood" action:@selector(menuControllerDisappear)];
//    _menuController.menuItems = [NSArray arrayWithObjects:menuItem, nil];
//    [_menuController setTargetRect:moodButton.frame inView:moodButton.superview];
//    [_menuController setMenuVisible:YES animated:YES];
    
    
    __block CGRect movingFrame = moodButton.frame;
    CGFloat movingDistance = 5;
    CGFloat growingSize = 4;
    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                            movingFrame.origin.y -= movingDistance;
                            movingFrame.size.height += growingSize;
                            movingFrame.size.width += growingSize;
                            moodButton.frame = movingFrame;
                        }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1
                                               delay:0
                              usingSpringWithDamping:0.2
                               initialSpringVelocity:0.2
                                             options:0
                                          animations:^{
                                                movingFrame.origin.y += movingDistance;
                                                movingFrame.size.height -= growingSize;
                                                movingFrame.size.width -= growingSize;
                                                moodButton.frame = movingFrame;
                                             }
                                          completion:nil];
                         
                         UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Press and wheel to choose your mood" action:@selector(menuControllerDisappear)];
                         _menuController.menuItems = [NSArray arrayWithObjects:menuItem, nil];
                         [_menuController setTargetRect:moodButton.frame inView:moodButton.superview];
                         [_menuController setMenuVisible:YES animated:YES];
                         
                         // hide menu controller after 1 second
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                             [self menuControllerDisappear];
                         });
                     }];
}


- (void)moodButtonTouchedUp:(UIGestureRecognizer *)recognizer {
    CFTimeInterval elapsedTime = CACurrentMediaTime() - _startTime;
    NSLog(@"%f", elapsedTime);
    MDMoodButtonView *moodButton = (MDMoodButtonView *)recognizer.view;
    
    // 0.35초보다 빨리 TouchUp하면 menuController가 나옴.
    if(elapsedTime < 0.35 && [moodButton becomeFirstResponder] && _didWheel==NO) {
        [self menuControllerAppear:moodButton];
    }
    
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.saveButtonBackground.hidden = (self.moodCount<1) ? YES : NO;
                    }
                    completion:nil];
}



- (void)setChoosingMoodImageByNum:(NSNumber *)num {
    int moodClass = num.intValue/10 - 1;
    int moodIntensity = num.intValue%10;
    self.moodIntensityView.image = self.choosingMoodImages[moodClass][moodIntensity];
}



- (void)changeMoodButtonImage:(MDMoodButtonView *)moodButton {
    moodButton.isSelected = !moodButton.isSelected;
    moodButton.isSelected ? self.moodCount++ : self.moodCount--;
    NSString *surfix = (moodButton.isSelected) ? @"selected" : @"unselect";
    NSString *imageName = [[NSString alloc]initWithFormat:@"%@_%@", moodButton.name, surfix];
    moodButton.image = [UIImage imageNamed:imageName];
}


// 선택한 moodButton에 해당하는 wheel 색깔로 바꿔서 보여줌
- (void)showWheelView:(MDMoodButtonView *)moodButton {
//    [UIView transitionWithView:self.wheel
//                      duration:0.2
//                       options:UIViewAnimationOptionTransitionCrossDissolve
//                    animations:^{
//                    }
//                    completion:nil];
    self.wheel.image = [UIImage imageNamed:[[NSString alloc] initWithFormat:@"%@_wheel", moodButton.name]];
    self.wheel.transform = CGAffineTransformMakeRotation(moodButton.startAngle);
    self.progressWheel.currentMoodNum = moodButton.num.intValue/10;
    self.progressWheel.startAngle = moodButton.startAngle;
    
    self.moodIntensityView.hidden = (self.moodCount<1 || self.moodCount>3) ? YES:NO;
    self.wheelDegree = 0;
    self.previousIntensity = -1;
    for(MDMoodButtonView *moodButton in self.moodButtons) {
        moodButton.hidden = YES;
    }
}



- (void)addNewChosenMood:(NSNumber *)moodNum {
    // 새로 선택한 감정을 chosenMoods에 추가.
    // chosenMoods의 역할 : 선택한 mood들의 정보와 순서를 임시로 저장해둠. 나중에 chosenMoods를 바탕으로 디비에 입력할 거임.
    NSMutableDictionary *chosenMood = [@{@"moodClass" : moodNum, @"moodIntensity" : @0} mutableCopy];
    
    [self.moodColor.chosenMoods addObject:moodNum];
    [self.moodColor setNeedsDisplay];
    
    [self.saveButtonBackground.chosenMoods addObject:moodNum];
    [self.saveButtonBackground setNeedsDisplay];
    
    [self.chosenMoods addObject:chosenMood];
//    NSLog(@"%@", self.chosenMoods);
}


- (BOOL)isChosen:(MDMoodButtonView *)moodButtonView {
    NSMutableDictionary *mood = [@{@"moodClass" : moodButtonView.num, @"moodIntensity" : @0} mutableCopy];
    
    for (NSDictionary *chosenMood in self.chosenMoods) {
        if (chosenMood[@"moodClass"] == mood[@"moodClass"]) {
            return YES;
        }
    }
    return NO;
}



- (void)deleteFromChosenMoods:(NSNumber *)moodClass {
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"moodClass != %@", moodClass];
    self.chosenMoods = [[self.chosenMoods filteredArrayUsingPredicate:predicate1] mutableCopy];
    for(int i=0 ; i<[self.moodColor.chosenMoods count] ; i++) {
        if(self.moodColor.chosenMoods[i] == moodClass) {
            [self.moodColor.chosenMoods removeObjectAtIndex:i];
        }
    }
    for(int i=0 ; i<[self.saveButtonBackground.chosenMoods count] ; i++) {
        if(self.saveButtonBackground.chosenMoods[i] == moodClass) {
            [self.saveButtonBackground.chosenMoods removeObjectAtIndex:i];
        }
    }
    for(int i=0 ; i<[self.mixedMoodFace.chosenMoods count] ; i++) {
        if(self.mixedMoodFace.chosenMoods[i].intValue/10 == moodClass.intValue/10) {
            [self.mixedMoodFace.chosenMoods removeObjectAtIndex:i];
        }
    }
    [self.moodColor setNeedsDisplay];
    [self.saveButtonBackground setNeedsDisplay];
    [self.mixedMoodFace setNeedsDisplay];
}



- (void)addWheelGestureRecognizer {
    MDWheelGestureRecognizer *recognizer = [[MDWheelGestureRecognizer alloc] initWithTarget:self
                                                                                wheelAction:@selector(rotateWheel:)
                                                                              touchUpAction:@selector(returnToStartView)];
    [recognizer setDelegate:self];
    [self.container addGestureRecognizer:recognizer];
}



- (void)rotateWheel:(id)sender {
    if(self.moodIntensityView.hidden) {     // wheelGesture와 tapGesture가 동시에 동작하는 거 방지
        return;
    }
    MDWheelGestureRecognizer *recognizer = (MDWheelGestureRecognizer *)sender;
    
    _didWheel = YES;
    
    //wheel 회전
    CGFloat angle = recognizer.currentAngle - recognizer.previousAngle;
    [self transformWheelWithAngle:angle];
    [self setWheelDegreeWithAngle:angle];
    
    //wheel progress bar
    self.progressWheel.endAngle = recognizer.currentAngle;
    [self.progressWheel setNeedsDisplay];
    
    //돌린 정도에 따라 휠 가운데 이미지 변화
    [self setMoodIntensity];
    
    //휠 돌리는 동안은 save & skip 버튼 감추기
    self.saveButtonBackground.hidden = YES;
}


- (void)setWheelDegreeWithAngle:(CGFloat)angle {
    self.wheelDegree += angle * 180 / M_PI;
    if(self.wheelDegree < -0.5) {
        self.wheelDegree += 360;
    }
    else if (self.wheelDegree > 359.5) {
        self.wheelDegree -= 360;
    }
}



- (void)transformWheelWithAngle:(CGFloat)angle {
    CGAffineTransform wheelTransform = self.wheel.transform;
    CGAffineTransform newWheelTransform = CGAffineTransformRotate(wheelTransform, angle);
    [self.wheel setTransform:newWheelTransform];
}



- (void)setMoodIntensity {
    NSNumber *moodIntensity = [NSNumber numberWithInt:self.wheelDegree/72];
    
    if(_previousIntensity != moodIntensity.intValue) {
        _previousIntensity = moodIntensity.intValue;
        [[self.chosenMoods lastObject] setValue:moodIntensity forKey:@"moodIntensity"];
        int moodClass = [[[self.chosenMoods lastObject] objectForKey:@"moodClass"] intValue]/10 - 1;
        [UIView transitionWithView:self.moodIntensityView
                          duration:0.1
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.moodIntensityView.image = self.choosingMoodImages[moodClass][moodIntensity.intValue];
                        }
                        completion:nil];
    }
}


- (void)setMixedMoodFaceWithNum:(NSNumber *)moodNum {
    [self.mixedMoodFace.chosenMoods addObject:moodNum];
    [self.mixedMoodFace setNeedsDisplay];
}


- (void)returnToStartView {
    if(self.moodIntensityView.hidden) {     // wheelGesture와 tapGesture가 동시에 동작하는 거 방지
        return;
    }
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if(self.moodCount<3) {
                            self.mixedMoodFace.hidden = NO;
                        }
                        self.moodIntensityView.hidden = YES;
                        self.wheel.image = [UIImage imageNamed:@"circle"];
                        for(MDMoodButtonView *moodButton in self.moodButtons) {
                            moodButton.hidden = NO;
                        }
                        self.mixedMoodFace.hidden = NO;
                        self.saveButtonBackground.hidden = (self.moodCount<1) ? YES : NO;
                    }
                    completion:nil];
    int moodNum = [[self.chosenMoods lastObject][@"moodClass"] intValue] + [[self.chosenMoods lastObject][@"moodIntensity"] intValue];
    [self setMixedMoodFaceWithNum:[NSNumber numberWithInt:moodNum]];
    
    [self.progressWheel erasePath];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)moveEntireViewWithDuration:(CGFloat)duration distance:(CGFloat)distance {
    [UIView transitionWithView:self.view
                      duration:duration
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+distance, self.view.frame.size.width, self.view.frame.size.height)];
                    }
                    completion:nil];
}

- (void) presentCalendar{
    
}


//위는 기범's 그대로 가져왔어
-(UIView*)mixedView{
    UIView *mixedView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    mixedView.backgroundColor = [UIColor whiteColor];
    mixedView.contentMode = UIViewContentModeCenter;
    mixedView.contentMode = UIViewContentModeScaleAspectFit;
    [mixedView addSubview:self.moodIntensityView];
    [mixedView addSubview:self.moodColor];
    [mixedView addSubview:self.mixedMoodFace];
    mixedView.clipsToBounds = YES;
    return mixedView;
}

//확인버튼 눌렀을때
- (IBAction)confirmMoodMon:(id)sender {
    MSMessageTemplateLayout *layout = [[MSMessageTemplateLayout alloc] init];
    UIImage *largeImage = [UIView imageWithView:[self mixedView]];
    layout.image = [self cropImage:largeImage];
    [delegate setLayout:layout];
}

//이미지 테두리 자르기
-(UIImage*)cropImage:(UIImage*)largeImage{
    CGRect cropRect = CGRectMake(CURRENT_WINDOW_WIDTH/2,CURRENT_WINDOW_WIDTH/2, CURRENT_WINDOW_HEIGHT/2+140, CURRENT_WINDOW_HEIGHT/2+120);
    //자르는 기준을 모르겠어 그냥 계속 빌드한면서 맞춘 값인데 왜 이런 값이 나올지
    CGImageRef imageRef = CGImageCreateWithImageInRect([largeImage CGImage], cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image;
}


@end
