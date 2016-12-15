//
//  MDMonthViewTutorialController.m
//  moodMon
//
//  Created by 김기범 on 2016. 12. 15..
//  Copyright © 2016년 HUB. All rights reserved.
//

#import "MDMonthViewTutorialController.h"

@interface MDMonthViewTutorialController ()

@end

@implementation MDMonthViewTutorialController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)exitTutorial:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"DidShowMonthTutorial"];
    [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
