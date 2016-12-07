//
//  MDRoundRectView.m
//  moodMon
//
//  Created by 이재성 on 07/12/2016.
//  Copyright © 2016 HUB. All rights reserved.
//

#import "MDRoundRectView.h"

@implementation MDRoundRectView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.layer.cornerRadius = 20;
}
@end
