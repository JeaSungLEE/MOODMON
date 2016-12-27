//
//  MDDataManger.h
//  moodMon
//
//  Created by Lee Kyu-Won on 3/30/16.
//  Copyright © 2016 Lee Kyu-Won. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MDDocument.h"
#import "Moodmon.h"

@interface MDDataManager : NSObject{
    BOOL hasICloud;
}

@property RLMArray<Moodmon *> *moodArray;
//index는 한번 만들면 지워지지 않는다.
//sql디비와 콜렉션 id 일치
//인덱스 당 데이터는 대부분 시간순서로 되어있을 것이라 예상

/******* for iCloud ***************/
@property MDDocument *document;
@property NSURL *documentURL;

@property NSURL *ubiquityURL;
@property NSMetadataQuery *metadataQuery;

-(void)makeICloud;
- (void)startICloudSync;
- (void)metadataQueryDidFinishGathering:(NSNotification*)notification;
/**********************************end*/


/******** for filter ***************/
@property NSMutableArray *isChecked; //chosen in filter
@property int chosenMoodCount;
-(NSArray<Moodmon*>*)getFilteredMoodmons;
/*********************************end*/

+(MDDataManager*)sharedDataManager; //DataManager is a singleton.

- (void)deleteAllData;
- (void)deleteAtRealmMoodmonIdx:(NSInteger)idx;

- (void)saveNewMoodmonAtRealmOfComment:(NSString*)comment asFirstChosen:(int)first SecondChosen:(int)second andThirdChosen:(int)third; //for Realm
- (void)setCollectionFromRealm;

/*
 * representationOfRealmMoodMonAtDate -
 * 해당 날짜의 대표 감정을 숫자배열로 알려준다
 * count가 가장 큰 감정(정도 정보 포함)을 알려준다.
 * count가 동일한 갯수일 경우에만 최대 3개. 기본은 한개.
 * count동일한 감정이 4개 이상일 때는, 정도기준 3개.
 * 정도기준에서도 4개 이상의 동점이 나올 경우에는 십의 자리가 큰 감정들 먼저 나온다. //이건 그냥 알고리즘구현으로 인해...
 */
- (NSMutableArray<NSNumber*>*)representationOfRealmMoodMonAtYear:(NSInteger)year Month:(NSInteger)month andDay:(NSInteger)day;
- (NSUInteger)recentRealmMood;

@end
