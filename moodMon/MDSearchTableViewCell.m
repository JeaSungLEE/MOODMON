//
//  MDSearchTableViewCell.m
//  moodMon
//
//  Created by Lee Kyu-Won on 5/8/16.
//  Copyright © 2016 HUB. All rights reserved.
//

#import "MDSearchTableViewCell.h"

@implementation MDSearchTableViewCell

- (void)drawWithMoodmon:(Moodmon*)moodmon{
    self.moodColorView.layer.cornerRadius = self.moodColorView.frame.size.width/2;
    self.moodColorView.layer.masksToBounds = YES;
    for(int i = 1 ; i < self.moodColorView.chosenMoods.count ; i++){
        [self.moodColorView.chosenMoods replaceObjectAtIndex:i withObject:@0];
        [self.moodFaceView.chosenMoods replaceObjectAtIndex:i withObject:@0];
    }
    
    NSMutableArray *chosenMoods = [[NSMutableArray alloc] initWithObjects:@0, nil];
    NSNumber *moodChosen = [NSNumber numberWithInteger: moodmon.moodChosen1];
    if(moodChosen.intValue != 0){
        [chosenMoods insertObject:moodChosen atIndex:1];
    }
    moodChosen = [NSNumber numberWithInteger: moodmon.moodChosen2];
    if(moodChosen.intValue != 0){
        [chosenMoods insertObject:moodChosen atIndex:2];
    }
    moodChosen = [NSNumber numberWithInteger: moodmon.moodChosen3];
    if(moodChosen.intValue != 0){
        [chosenMoods insertObject:moodChosen atIndex:3];
    }
    self.moodColorView.chosenMoods = chosenMoods;
    self.moodFaceView.chosenMoods = chosenMoods;
    
    [self.moodFaceView setNeedsDisplay];
    [self.moodColorView setNeedsDisplay];
}


@end
