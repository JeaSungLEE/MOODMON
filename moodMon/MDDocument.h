//
//  MDDocument.h
//  moodMon
//
//  Created by Lee Kyu-Won on 5/29/16.
//  Copyright © 2016 HUB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moodmon.h"

@interface MDDocument : UIDocument

@property (strong, nonatomic) NSMutableArray<Moodmon*>* moodmonCollection;

@end
