//
//  UIView+Capture.m
//  moodMon
//
//  Created by 이재성 on 09/11/2016.
//  Copyright © 2016 HUB. All rights reserved.
//

#import "UIView+Capture.h"

@implementation UIView (Capture)
+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(300, 300), NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
