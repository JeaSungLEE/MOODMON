//
//  MDMonthViewController.m
//  moodMon
//
//  Created by 이재성 on 2016. 4. 9..
//  Copyright © 2016년 Lee Kyu-Won. All rights reserved.
//

#import "MDMonthViewController.h"


@interface MDMonthViewController (){
    BOOL toolbarIsOpen;
    BOOL toolbarIsAnimating;
    int myDay;
    int lastClickedDay;
    int dayBtnBoundsSize;
    
    NSDate *now;
    NSDateComponents *nowComponents;
}
@property (strong, nonatomic) IBOutlet UIButton *tutorialView;
@property (strong, nonatomic)RLMArray *createdAt;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *yearBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dataBtn;
@property (weak, nonatomic) IBOutlet UIButton *filterDoneBtn;


@end

extern NSUInteger numDays;
extern NSInteger thisYear;
NSUInteger thisMonth;
extern NSInteger weekday;
extern int tag;

int count;
NSMutableArray<Moodmon*> *moodmonConf;
UITableViewHeaderFooterView *headerView;
NSMutableArray <NSIndexPath *> *indexPathsToDelete;
UIFont *quicksand;
UIFont *boldQuicksand;
NSString *currentDate;

@implementation MDMonthViewController
@synthesize thisYear;
@synthesize thisMonth;

-(void)awakeFromNib{
    [super awakeFromNib];
    //image loading
    _angryChecked = [UIImage imageNamed:@"angry_filter@2x"];
    _angryUnchecked = [UIImage imageNamed:@"angry_unfilter@2x"];
    _happyChecked = [UIImage imageNamed:@"joy_filter@2x"];
    _happyUnchecked = [UIImage imageNamed:@"joy_unfilter@2x"];
    _sadChecked = [UIImage imageNamed:@"sad_filter@2x"];
    _sadUnchecked = [UIImage imageNamed:@"sad_unfilter@2x"];
    _exciteChecked = [UIImage imageNamed:@"excited_filter@2x"];
    _exciteUnchecked = [UIImage imageNamed:@"excited_unfilter@2x"];
    _exhaustChecked = [UIImage imageNamed:@"tired_filter@2x"];
    _exhaustUnchecked = [UIImage imageNamed:@"tired_unfilter@2x"];
    
}


- (void)viewDidLoad {
    count=0;
    [super viewDidLoad];
    
    [self setFilterUI];
    [self addGesture];
    
    _mddm = [MDDataManager sharedDataManager];
    
    now = [NSDate date];
    toolbarIsOpen = YES;
    toolbarIsAnimating = NO;
    self.tableViews.bounces = NO;
    self.tableViews.alwaysBounceVertical = NO;
    self.toolbarContainer.translatesAutoresizingMaskIntoConstraints = YES;
    [self.toolbarContainer setFrame:CGRectMake(0, (self.view.frame.size.height - 49), self.view.frame.size.width, 49.0)];
    [self collapseToolbarWithoutBounce];
    [self setNotificationAddObserver];
    
    quicksand = [UIFont fontWithName:@"Quicksand" size:16];
    boldQuicksand = [UIFont fontWithDescriptor:[[quicksand fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:quicksand.pointSize];
    
    _createdAt=[_mddm moodArray];
    thisYear =[[[NSCalendar currentCalendar]components:NSCalendarUnitYear fromDate:[NSDate date]]year];
    thisMonth =[[[NSCalendar currentCalendar]components:NSCalendarUnitMonth fromDate:[NSDate date]]month];
    
    //[self moreDateInfo];
    indexPathsToDelete = [[NSMutableArray alloc] init];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    [_visualEffectView setEffect:blurEffect];
    _visualEffectView.layer.opacity = 0;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteBlur:) name:@"deleteBlur" object:nil];
    
    self.yearBtn.title = NSLocalizedString(@"Year", nil);
    self.searchBtn.title = NSLocalizedString(@"Search", nil);
    self.dataBtn.title = NSLocalizedString(@"Data", nil);
    self.filterButton.titleLabel.text = NSLocalizedString(@"Filter", nil);
    self.filterDoneBtn.titleLabel.text  = NSLocalizedString(@"Done", nil);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteBlur" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    BOOL didShowMonthTutorial = [[[NSUserDefaults standardUserDefaults] objectForKey:@"DidShowMonthTutorial"] boolValue];
    if(didShowMonthTutorial == NO) {
        [self showTutorial];
    }
    [self removeTags];
    myDay = 0;
    
    [_filterButton setFont:quicksand];
    //    [_dataButton setTitleTextAttributes:@{NSFontAttributeName:quicksand} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIColor colorWithRed:91/255.0 green:88/255.0 blue:85/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                         quicksand, NSFontAttributeName, nil]
                                               forState:UIControlStateNormal];
    UILabel *topItem = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.width)];
    topItem.backgroundColor = [UIColor clearColor];
    topItem.font = boldQuicksand;
    topItem.textAlignment = NSTextAlignmentCenter;
    topItem.text = [NSString stringWithFormat: NSLocalizedString(@"Title Date Format", nil), (long)thisYear, (long)thisMonth];
    self.navigationItem.titleView = topItem;
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:boldQuicksand} forState:UIControlStateNormal];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSFontAttributeName:boldQuicksand} forState:UIControlStateNormal];
    
    [self resetTimeTable];
    [self moreDateInfo];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)reloadData{
    [self removeTags];
    [self moreDateInfo];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)showTutorial {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *tutorialViewController = [storyboard instantiateViewControllerWithIdentifier:@"MonthTutorial"];
    [tutorialViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:tutorialViewController animated:YES completion:nil];
}


/***************** filter tool bar animation **************/

- (IBAction)expandButtonTouched{
    if (!toolbarIsAnimating) {
        toolbarIsAnimating = YES;
        [self expandToolbarWithoutBounce];
        
    }
}

-(IBAction)collapseButtontouched{
    if (!toolbarIsAnimating) {
        toolbarIsAnimating = YES;
        [self collapseToolbarWithoutBounce];
    }
    
    [_mddm getFilteredMoodmons];
    // NSLog(@" %d", _mddm.chosenMoodCount);
}

- (void)collapseToolbarWithoutBounce{
    [UIView animateWithDuration:0.25 animations:^{
        [self.toolbarContainer setFrame:CGRectMake(0, (self.view.frame.size.height ), self.view.frame.size.width, 49.0)];
    } completion:^(BOOL finished) {
        toolbarIsOpen = NO;
        toolbarIsAnimating = NO;
        //[self.collapseButton setTitle:@"\u2B06" forState:UIControlStateNormal];
    }];
}

- (void)expandToolbarWithoutBounce{
    [UIView animateWithDuration:0.25 animations:^{
        [self.toolbarContainer setFrame:CGRectMake(0, (self.view.frame.size.height - 49), self.view.frame.size.width, 49.0)];
    } completion:^(BOOL finished) {
        toolbarIsOpen = YES;
        toolbarIsAnimating = NO;
        // [self.collapseButton setTitle:@"\u2B07" forState:UIControlStateNormal];
    }];
}
//filtering
- (IBAction)filterButtonClicked:(id)sender{
    if(sender == self.angryFilterBtn){
        
        if([_mddm.isChecked[0]  isEqual: @NO]){
            _mddm.isChecked[0] = @YES;
            _mddm.chosenMoodCount++;
            [self.angryFilterBtn setImage: _angryChecked forState:UIControlStateNormal];
            
        } else {
            _mddm.isChecked[0] = @NO;
            _mddm.chosenMoodCount--;
            [self.angryFilterBtn setImage: _angryUnchecked forState:UIControlStateNormal];
        }
        
        
    } else if (sender == self.happyFilterBtn){
        
        if([_mddm.isChecked[1]  isEqual: @NO]){
            _mddm.isChecked[1] = @YES;
            _mddm.chosenMoodCount++;
            [self.happyFilterBtn setImage: _happyChecked forState:UIControlStateNormal];
        } else {
            _mddm.isChecked[1] = @NO;
            _mddm.chosenMoodCount--;
            [self.happyFilterBtn setImage: _happyUnchecked forState:UIControlStateNormal];
        }
        
        
    } else if (sender == self.sadFilterBtn){
        
        if([_mddm.isChecked[2]  isEqual: @NO]){
            _mddm.isChecked[2] = @YES;
            _mddm.chosenMoodCount++;
            [self.sadFilterBtn setImage:_sadChecked forState:UIControlStateNormal];
            //            [self.sadFilterBtn setBackgroundImage: _sadChecked forState:UIControlStateNormal];
        } else {
            _mddm.isChecked[2] = @NO;
            _mddm.chosenMoodCount--;
            [self.sadFilterBtn setImage: _sadUnchecked forState:UIControlStateNormal];
        }
        
    } else if (sender == self.exciteFilterBtn){
        
        if([_mddm.isChecked[3]  isEqual: @NO]){
            _mddm.isChecked[3] = @YES;
            _mddm.chosenMoodCount++;
            [self.exciteFilterBtn setImage: _exciteChecked forState:UIControlStateNormal];
            
        } else {
            _mddm.isChecked[3] = @NO;
            _mddm.chosenMoodCount--;
            [self.exciteFilterBtn setImage: _exciteUnchecked forState:UIControlStateNormal];
        }
        
    } else if (sender == self.exhaustFilterBtn){
        
        if([_mddm.isChecked[4]  isEqual: @NO]){
            _mddm.isChecked[4] = @YES;
            _mddm.chosenMoodCount++;
            [self.exhaustFilterBtn setImage: _exhaustChecked forState:UIControlStateNormal];
        } else {
            _mddm.isChecked[4] = @NO;
            _mddm.chosenMoodCount--;
            [self.exhaustFilterBtn setImage: _exhaustUnchecked forState:UIControlStateNormal];
        }
        
    } else {
        NSLog(@"wrong filter btn clicked");
    }
    [self removeTags];
    [self moreDateInfo];
    [indexPathsToDelete removeAllObjects];
    [self resetTableCellConstants];
    [self.tableViews reloadData];
}


/**************************************************/


//#noti selector
-(void)timeTableReload{
    unsigned units = NSCalendarUnitMonth | NSCalendarUnitDay| NSCalendarUnitYear| NSCalendarUnitHour| NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDate *now = [NSDate date];
    NSCalendar *myCal = [[NSCalendar alloc]
                         initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [myCal components:units fromDate:now];
    NSInteger day = [comp day];
    
    if(day == myDay){
        [self showClickedDateMoodmonAtDay:myDay];
    }
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqual: @"goToYearView"]){
        MDYearViewController *yvc = [segue destinationViewController];
        yvc.thisYear = thisYear;
    }
}

-(void)goToYearView{
    MDYearViewController *yvc = [[MDYearViewController alloc]initWithNibName:@"yearVC" bundle:nil];
    yvc.thisYear = thisYear;
    [yvc setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentViewController:yvc animated:YES completion:nil];
}

- (IBAction)handleSwipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        thisMonth++;
        [self removeTags];
        [self moreDateInfo];
        NSLog(@"down Swipe");
        
    }
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        thisMonth--;
        [self removeTags];
        [self moreDateInfo];
        NSLog(@"up Swipe");
    }
    UILabel *topItem = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.width)];
    topItem.backgroundColor = [UIColor clearColor];
    topItem.font = boldQuicksand;
    topItem.textAlignment = NSTextAlignmentCenter;
    topItem.text = [NSString stringWithFormat:NSLocalizedString(@"Title Date Format" , nil), thisYear, thisMonth];
    self.navigationItem.titleView = topItem;
    [self resetTimeTable];
}

-(void)resetTimeTable{
    moodmonConf = NULL;
    myDay = 0;
    [self resetTableCellConstants];
    [_tableViews reloadData];
    
}



- (IBAction)goToNewMoodViewController:(id)sender {
    int height = [UIScreen mainScreen].bounds.size.height;
    NSString *identifier = (height<=568)?@"newMoodmonVC_4inch":@"newMoodmonVC";
    UIViewController *newMoodVC = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    //    MDCustomStoryboardSegue *segue = [[MDCustomStoryboardSegue alloc] initWithIdentifier:@"toNewMoodVC" source:self destination:newMoodVC];
    //    [segue perform];
    [self presentViewController:newMoodVC animated:YES completion:nil];
}

-(void)removeTags{
    int x=1;
    while(x<=90){
        [[self.view viewWithTag:x]removeFromSuperview];
        x++;
    }
}
-(void)removeTagsMon{
    int x=32;
    while(x<=200){
        [[self.view viewWithTag:x]removeFromSuperview];
        x++;
    }
}

-(NSUInteger)getCurrDateInfo:(NSDate *)myDate{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSRange rng = [cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:myDate];
    NSUInteger numberOfDaysInMonth = rng.length;
    
    return numberOfDaysInMonth;
}

-(void)moreDateInfo{
    tag=32;
    if(thisMonth>12){
        thisMonth=1;
        thisYear++;
    }
    if(thisMonth<1){
        thisMonth=12;
        thisYear--;
    }
    int xVal=CGRectGetWidth(self.view.bounds)/7,yVal=CGRectGetHeight(self.view.bounds)/12;
    if([UIScreen mainScreen].bounds.size.height <= 568 ){
        yVal -= 0.8;
    }
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc]init];
    [components setDay:1];
    [components setMonth:thisMonth];
    [components setYear:thisYear];
    NSDate * newDate = [calendar dateFromComponents:components];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:newDate];
    weekday=[comps weekday];
    numDays=[self getCurrDateInfo:newDate];
    NSInteger newWeekDay=weekday-1;
    // NSLog(@"Day week %d",newWeekDay);
    
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    nowComponents = [calendar components:units fromDate:now];
    
    NSInteger yCount=1;
    NSInteger xCoord=0;
    NSInteger yCoord=self.navigationController.navigationBar.frame.size.height+ 20;
    UILabel *backgroundLabel = [[UILabel alloc] initWithFrame:CGRectMake(xCoord, yCoord, CGRectGetWidth(self.view.bounds),yVal*2/3)];
    [backgroundLabel setBackgroundColor:[UIColor colorWithRed:222.0f/255.0f green:212.0f/255.0f blue:198.0f/255.0f alpha:1.0f]];
    [self.view addSubview:backgroundLabel];
    for(int i=0;i<7;i++){
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(xCoord+(xVal*i)+xVal/3, yCoord-10, xVal, yVal)];
        switch (i) {
            case 1:
                [monthLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Monday", nil)]];
                break;
            case 2:
                [monthLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Tuesday", nil)]];
                break;
            case 3:
                [monthLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Wednesday", nil)]];
                break;
            case 4:
                [monthLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Thursday", nil)]];
                break;
            case 5:
                [monthLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Friday", nil)]];
                break;
            case 6:
                [monthLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Saturday", nil)]];
                break;
            case 0:
                [monthLabel setText:[NSString stringWithFormat:NSLocalizedString(@"Sunday", nil)]];
                break;
            default:
                break;
        }
        [monthLabel setFont:[UIFont fontWithName:@"Quicksand" size:13]];
        monthLabel.tag = tag++;
        [monthLabel setTextColor:[UIColor blackColor]];
        [self.view addSubview:monthLabel];
    }
    //
    yCount++;
    //    _yearLabel.text=[NSString stringWithFormat:@"%d",thisYear];
    //    [_monthLabel setText:[NSString stringWithFormat:@"%d",thisMonth]];
    for(int startDay=1; startDay<=numDays;startDay++){
        UIButton *dayButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        xCoord=(newWeekDay*xVal);
        yCoord=(yCount*yVal) ;
        
        newWeekDay++;
        if(newWeekDay>6){
            newWeekDay=0;
            yCount++;
        }
        [dayButton setFont:[UIFont fontWithName:@"Quicksand" size:14]];
        dayBtnBoundsSize = xVal;
        dayButton.bounds = CGRectMake(xCoord, yCoord, xVal, yVal);
        dayButton.frame = CGRectMake(xCoord, yCoord, xVal, yVal);
        [dayButton setTitle:[NSString stringWithFormat:@"%d",startDay]forState:UIControlStateNormal];
        [dayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [dayButton addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
        dayButton.tag=startDay;
        
        if( ([nowComponents year] == thisYear) && ([nowComponents month] == thisMonth) && ([nowComponents day] == startDay)){
            dayButton.layer.bounds = CGRectMake(dayButton.bounds.origin.x, dayButton.bounds.origin.y , dayBtnBoundsSize - 5, dayBtnBoundsSize -5 );
            dayButton.layer.borderColor = [UIColor colorWithRed:0.87 green:0.83 blue:0.78 alpha:1.00].CGColor;
            dayButton.layer.borderWidth = 3;
            dayButton.layer.cornerRadius = dayButton.frame.size.width / 2;
            dayButton.layer.masksToBounds = YES;
        }
        
        
        int checkFalg =0;
        for(int parseNum=0; parseNum<_createdAt.count; parseNum++){
            Moodmon *parseDate = [_createdAt  objectAtIndex:parseNum];
            int parseMonth = (int)parseDate.moodMonth;
            int parseYear = (int)parseDate.moodYear;
            int parseDay = (int)parseDate.moodDay;
            if((parseYear==thisYear)&&(parseMonth==thisMonth)&&(parseDay==startDay)&&(checkFalg==0)){
                
                //                    [self.moodColor.chosenMoods addObject:[createdAt[parseNum] valueForKey:@"_moodChosen1"]];
                //                    if([createdAt[parseNum] valueForKey:@"_moodChosen2"]!=0){
                //                        [self.moodColor.chosenMoods addObject:[createdAt[parseNum] valueForKey:@"_moodChosen2"]];
                //                    }
                //                    if([createdAt[parseNum] valueForKey:@"_moodChosen3"]!=0){
                //                        [self.moodColor.chosenMoods addObject:[createdAt[parseNum] valueForKey:@"_moodChosen3"]];
                //                }
                
                
                
                NSInteger yCoordCenter = yVal/2+yCoord-xVal*4/10;
                NSInteger xCoordCenter = xVal/2+xCoord-xVal*4/10;
                MDSmallMoodFaceView *mfv = [[MDSmallMoodFaceView alloc]initWithFrame:CGRectMake(0,0, xVal*4/5, xVal*4/5)];
                
                [mfv awakeFromNib];
                MDMoodColorView *mcv = [[MDMoodColorView alloc]initWithFrame:CGRectMake(xCoordCenter,yCoordCenter, CGRectGetWidth(mfv.bounds)-2 , CGRectGetWidth(mfv.bounds)-2)];
                
                [mcv awakeFromNib];
                
                //                mcv.backgroundColor = [UIColor clearColor];
                NSArray *dayRepresenatationColors = [_mddm representationOfRealmMoodMonAtYear:(NSInteger)parseYear Month:(NSInteger)parseMonth andDay:parseDay];
                // NSLog(@"DAY : %@ %@ %@", dayRepresenatationColors[0],dayRepresenatationColors[1],dayRepresenatationColors[2]);
                NSNumber *tempMoodChosen = dayRepresenatationColors[0];
                if(tempMoodChosen.intValue > 0){
                    [mfv.chosenMoods insertObject: tempMoodChosen atIndex:1 ];
                    [mcv.chosenMoods insertObject: tempMoodChosen atIndex:1 ];
                }
                tempMoodChosen = dayRepresenatationColors[1];
                if(tempMoodChosen.intValue > 0){
                    [mfv.chosenMoods insertObject: tempMoodChosen atIndex:2 ];
                    [mcv.chosenMoods insertObject: tempMoodChosen atIndex:2 ];
                }
                tempMoodChosen = dayRepresenatationColors[2];
                if(tempMoodChosen.intValue > 0){
                    [mfv.chosenMoods insertObject: tempMoodChosen atIndex:3 ];
                    [mcv.chosenMoods insertObject: tempMoodChosen atIndex:3 ];
                }
                mfv.backgroundColor =[UIColor clearColor];
                
                //                    mmm = [[MDMakeMoodMonView alloc]init];
                //                    mcv = [self.view viewWithTag:7];
                //                    [dayButton setImage:[mmm makeMoodMon:createdAt[parseNum] view:mcv] forState:UIControlStateNormal];
                BOOL isVisible = [self checkVisibility:mfv.chosenMoods];
                if(isVisible ==YES){
                    [dayButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                    checkFalg=1;
                    mcv.tag=tag++;
                    mfv.tag=tag++;
                    mcv.layer.cornerRadius = mcv.frame.size.width/2;
                    [mcv setNeedsDisplay];
                    [mfv setNeedsDisplay];
                    
                    [mcv addSubview:mfv];
                    mcv.layer.masksToBounds=YES;
                    mcv.center = dayButton.center;
                    [self.view addSubview:mcv];
                }
            }
        }
        [self.view addSubview:dayButton];
    }
    
    NSLog(@"%d", yCoord+ yVal);
    if((yCoord + yVal > 350) && ([UIScreen mainScreen].bounds.size.height <= 568)){ //under 5
        _tableviewHeight.constant = 132 + 28; //(tableCellHeight) * 2  + (tableHeaderHeight)
        [self.view layoutIfNeeded];
    } else if((yCoord + yVal > 400) && ([UIScreen mainScreen].bounds.size.height <= 667)){ //under 6
        _tableviewHeight.constant = 132 + 28; //(tableCellHeight) * 2  + (tableHeaderHeight)
        [self.view layoutIfNeeded];
    } else {
        _tableviewHeight.constant = 176 + 28; //(tableCellHeight) * 2 + (tableHeaderHeight)
        [self.view layoutIfNeeded];
    }
    
}


- (BOOL)checkVisibility:(NSArray *)chosenMoods {
    if([_mddm.isChecked[0] isEqual:@NO]&&[_mddm.isChecked[1] isEqual:@NO]&&[_mddm.isChecked[2] isEqual:@NO]&&[_mddm.isChecked[3] isEqual:@NO]&&[_mddm.isChecked[4] isEqual:@NO]){
        return YES;
    }
    else{
        if([_mddm.isChecked[0] isEqual:@YES]){
            for (NSString *checked in chosenMoods) {
                if(checked.intValue /10 ==1)
                    return YES;
            }
        }if([_mddm.isChecked[1] isEqual:@YES]){
            for (NSString *checked in chosenMoods) {
                if(checked.intValue /10 ==2)
                    return YES;
            }
        }if([_mddm.isChecked[2] isEqual:@YES]){
            for (NSString *checked in chosenMoods) {
                if(checked.intValue /10 ==3)
                    return YES;
            }
        }if([_mddm.isChecked[3] isEqual:@YES]){
            for (NSString *checked in chosenMoods) {
                if(checked.intValue /10 ==4)
                    return YES;
            }
        }if([_mddm.isChecked[4] isEqual:@YES]){
            for (NSString *checked in chosenMoods) {
                if(checked.intValue /10 ==5)
                    return YES;
            }
        }
        return NO;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY >0) {
        headerView.transform = CGAffineTransformMakeTranslation(0, offsetY);
    } else {
        headerView.transform = CGAffineTransformMakeTranslation(0, MAX(offsetY, 0));
    }
}
//이건 왜 있는건가여???

#pragma tableviewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return moodmonConf.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(myDay == 0) {
        return nil;
    }
    NSString *date =[NSString stringWithFormat:NSLocalizedString(@"Table Title Date Format", nil), (long)thisYear, thisMonth, myDay];
    currentDate = date;
    return date;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont fontWithName:@"Quicksand" size:14];
    header.textLabel.frame = header.frame;
    header.textLabel.textAlignment = NSTextAlignmentCenter;
    headerView = (UITableViewHeaderFooterView *)view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDMonthTimeLineCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MDMonthTimeLineCellTableViewCell" forIndexPath:indexPath];
    cell.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor clearColor]);
    Moodmon *selected = moodmonConf[indexPath.row];
    cell.tag = selected.idx;
    cell.commentLabel.text = selected.moodComment;
  
    [cell drawWithMoodmon:selected];
    NSString *selectedTime = selected.moodTime;
    NSArray *timeComponents = [selectedTime componentsSeparatedByString:@":"];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *hour = [numberFormatter numberFromString:timeComponents[0]];
    NSString *tt = @"";
    if([hour compare:@12] != NSOrderedAscending){
        tt = NSLocalizedString(@"After12", nil);
        int hourSubtracted = [hour intValue] - 12;
        hour = [NSNumber numberWithInt:hourSubtracted];
    } else {
        tt = NSLocalizedString(@"Before12", nil);
    }
    
    cell.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Full Time Format+", nil), tt, hour, timeComponents[1], timeComponents[2]];
    cell.itemText = [moodmonConf[indexPath.row] valueForKey:@"_moodComment"];
    cell.delegate = self;
   
    
    BOOL isVisible = [self checkVisibility:cell.moodColorView.chosenMoods] && [self checkVisibility:cell.moodFaceView.chosenMoods];
    
    if(isVisible == NO) {
        cell.isFiltered = YES;
        [indexPathsToDelete addObject:indexPath];
    }
    
    return cell;
}



-(void)buttonTouch:(id)sender{
    UIButton* btn = (UIButton *)sender;
    [self setBtnsBorderWithClickedBtn:btn];
    [self showClickedDateMoodmonAtDay:btn.tag];
}

/*************************/ // 버튼 클릭시 버튼 보더를 바꿔주는 매소드들
-(void)setBtnsBorderWithClickedBtn:(UIButton*)btn{
    [self removeLastClickedBtnBorder];
    if( ([nowComponents year] == thisYear) && ([nowComponents month] == thisMonth) && ([nowComponents day] == btn.tag)){
        btn.layer.borderWidth = 3;
        lastClickedDay = 0; //today
        return;
    }
    btn.layer.bounds = CGRectMake(btn.bounds.origin.x, btn.bounds.origin.y , dayBtnBoundsSize - 10, dayBtnBoundsSize - 10);
    btn.layer.borderColor = [UIColor colorWithRed:0.93 green:0.90 blue:0.87 alpha:1.00].CGColor;
    btn.layer.borderWidth = 3;
    btn.layer.cornerRadius = btn.frame.size.width / 2;
    btn.layer.masksToBounds = YES;
    [btn layoutIfNeeded];
    lastClickedDay = btn.tag;
}
-(void)removeLastClickedBtnBorder{
    if((lastClickedDay == 0) && ([nowComponents month] == thisMonth) && ([nowComponents year] == thisYear)){ //today
        UIButton *todayBtn = [self.view viewWithTag:[nowComponents day]];
        todayBtn.layer.borderWidth = 1.3;
        [todayBtn layoutIfNeeded];
        return;
    }
    
    UIButton *lastClickedBtn = [self.view viewWithTag:lastClickedDay];
    lastClickedBtn.layer.borderWidth = 0;
    lastClickedBtn.layer.opaque = YES;
    [lastClickedBtn layoutIfNeeded];
}
/***********************************/

-(void)showClickedDateMoodmonAtDay:(int)day{
    NSMutableArray* moodmonConfig = [[NSMutableArray alloc]init];
    count=0;
    //NSString *clickedDateString =[NSString stringWithFormat:@"%d년 %ld월 %d일", thisYear, (long)thisMonth, day];
    myDay = day;
    
    for(int parseNum=0; parseNum<_createdAt.count; parseNum++){
        Moodmon *parseDate = [_createdAt objectAtIndex:parseNum];
        int parseMonth = (int)parseDate.moodMonth;
        int parseYear = (int)parseDate.moodYear;
        int parseDay = (int)parseDate.moodDay;
        
        if((parseYear==thisYear)&&(parseMonth==thisMonth)&&(parseDay==day)){
            moodmonConfig[count] = parseDate;
            count++;
        }
    }
    moodmonConf=moodmonConfig;
    [self resetTableCellConstants];
    [_tableViews reloadData];
    
}

-(void)resetTableCellConstants{
    int cellCount = (int)[_tableViews numberOfRowsInSection:0];
    for(int i = 0; i < cellCount; i++){
        MDMonthTimeLineCellTableViewCell *tempCell = [_tableViews cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        tempCell.startingRightLayoutConstraintConstant = 0;
        tempCell.contentViewRightConstraint.constant = 0;
    }
    [_tableViews setNeedsLayout];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPathsToDelete containsObject:indexPath]) {
        return 0;
    }
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MDEndPageViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"MDEndPageViewController"];
    
    MDMonthTimeLineCellTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    VC.moodColorView = cell.moodColorView;
    VC.timest = cell.timeLabel.text;
    VC.dateString = currentDate;
    VC.comment = cell.commentLabel.text;
    VC.idx = (NSInteger)cell.tag;
    
    [self.view bringSubviewToFront:_visualEffectView];
    self.navigationController.navigationBar.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _visualEffectView.layer.opacity = 1;
    }];
    
    VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:VC animated:YES completion:nil];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // [_objects removeObjectAtIndex:indexPath.row];
        [self.tableViews deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %ld",(long)editingStyle);
    }
}


#pragma mark - MDSwipeableCellDelegate
- (void)buttonOneActionForItemText:(NSString *)itemText {
}

- (void)buttonTwoActionForItemText:(MDMoodColorView *)itemText {
    //뷰를 넘겨주면 그대로 저장
}
- (IBAction) exitFromSecondViewController:(UIStoryboardSegue *)segue
{
    //NSLog(@"back from : %@", [segue.sourceViewController class]);
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier
{
    
    //how to set identifier for an unwind segue:
    
    //1. in storyboard -> documento outline -> select your unwind segue
    //2. then choose attribute inspector and insert the identifier name
    if ([@"JSUnwindView" isEqualToString:identifier]) {
        return [[MDCustomStoryboardUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    }else {
        //if you want to use simple unwind segue on the same or on other ViewController this code is very important to mix custom and not custom segue
        return [super segueForUnwindingToViewController:toViewController fromViewController:fromViewController identifier:identifier];
    }
}


-(void) showAlert:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:[userInfo objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)setFilterUI{
    [self.angryFilterBtn setImage: _angryUnchecked forState:UIControlStateNormal];
    [self.happyFilterBtn setImage: _happyUnchecked forState:UIControlStateNormal];
    [self.sadFilterBtn setImage: _sadUnchecked forState:UIControlStateNormal];
    [self.exciteFilterBtn setImage: _exciteUnchecked forState:UIControlStateNormal];
    [self.exhaustFilterBtn setImage: _exhaustUnchecked forState:UIControlStateNormal];
    [_angryFilterBtn.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [_happyFilterBtn.imageView setContentMode:UIViewContentModeScaleToFill];
    [_sadFilterBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_exciteFilterBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_exhaustFilterBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

-(void)deleteBlur:(NSNotification*)notification{
    [UIView animateWithDuration:0.3
                     animations:^{
                         _visualEffectView.layer.opacity = 0;
                         self.navigationController.navigationBar.hidden = NO;
                     } completion:^(BOOL finished) {
                         [self.view sendSubviewToBack:_visualEffectView];
                     }];
}

-(void)addGesture{
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
}

-(void)setNotificationAddObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert:) name:@"failTosaveIntoSql" object:_mddm ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert:) name:@"moodNotChosen" object:_mddm ];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(timeTableReload) name:@"newDatxaAdded" object:_mddm];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAlert:) name:@"iCloudSyncFinished" object:_mddm];
}

@end
