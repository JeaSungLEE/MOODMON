//
//  MDDataManger.m
//  moodMon
//
//  Created by Lee Kyu-Won on 3/30/16.
//  Copyright © 2016 Lee Kyu-Won. All rights reserved.
//

#import "MDDataManager.h"
#import "Moodmon.h"

@implementation MDDataManager{
    unsigned units;
}

+(MDDataManager*)sharedDataManager{
    static MDDataManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    self = [super init];
    if(self){
        
        self.isChecked = [@[ @NO, @NO,@NO,@NO,@NO ] mutableCopy];
        self.chosenMoodCount = 0;
        NSString *docsDir;
        NSArray *dirPath;
        
        dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = dirPath[0];
        
        hasICloud = NO;
        NSString *documentFile = [docsDir stringByAppendingPathComponent:@"moodmonDoc.doc"];
        self.documentURL = [NSURL fileURLWithPath:documentFile];
        self.document = [[MDDocument alloc]initWithFileURL:_documentURL];
        units = NSCalendarUnitMonth | NSCalendarUnitDay| NSCalendarUnitYear| NSCalendarUnitHour| NSCalendarUnitMinute | NSCalendarUnitSecond;
    }
    return self;
}

- (void)setCollectionFromRealm{
    self.moodArray = (RLMArray*)[Moodmon allObjects];
}

- (void)saveNewMoodmonAtRealmOfComment:(NSString*)comment asFirstChosen:(int)first SecondChosen:(int)second andThirdChosen:(int)third{
    NSDate *now = [NSDate date];
    NSCalendar *myCal = [[NSCalendar alloc]
                         initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [myCal components:units fromDate:now];
    NSInteger year = [comp year];
    NSInteger month = [comp month];
    NSInteger day = [comp day];
    NSInteger hour = [comp hour];
    NSInteger minute = [comp minute];
    NSInteger secondTime = [comp second];
    
    NSString *timeString = [NSString stringWithFormat:@"%ld:%ld:%ld", (long)hour, (long)minute, (long)secondTime];
    
    Moodmon *newM = [[Moodmon alloc]init];
    newM.moodComment = comment;
    newM.moodChosen1 = first;
    newM.moodChosen2 = second;
    newM.moodChosen3 = third;
    newM.moodYear = year;
    newM.moodMonth = month;
    newM.moodDay = day;
    newM.moodTime = timeString;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *all = [[Moodmon allObjects] sortedResultsUsingKeyPath:@"idx" ascending:YES];
    Moodmon *last = [all lastObject];
    newM.idx = last.idx + 1;
    [realm beginWriteTransaction];
    [realm addObject:newM];
    [realm commitWriteTransaction];
    
    //for iCloud
    [self saveDocument: newM];
    
}
-(void)saveDocument:(Moodmon*)moodmon{
    [_document.moodmonCollection addObject:moodmon];
}
- (void)startICloudSync{
    if(hasICloud == NO){
        [self makeICloud];
    } else {
        [_document saveToURL:_ubiquityURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if(success){
                NSLog(@"Saved to iCloud for overwriting");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudSyncFinished" object:self userInfo:@{@"message" : @"Finish saving into iCloud "}];
            } else {
                NSLog(@"Not saved to Cloud for overwriting");
            }
        }];
    }
}

-(void)makeICloud{
    NSFileManager *filemgr = [NSFileManager defaultManager];
    [filemgr removeItemAtPath:(NSString*)_documentURL error:NULL];
    
    _ubiquityURL = [[filemgr URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
    
    if([filemgr fileExistsAtPath:[_ubiquityURL path]] == NO ){
        [filemgr createDirectoryAtPath:(NSString*) _ubiquityURL withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    _ubiquityURL = [_ubiquityURL URLByAppendingPathComponent:@"moodmon.doc"];
    
    // iCloud에서 문서 검색
    
    _metadataQuery = [[NSMetadataQuery alloc] init];
    [_metadataQuery setPredicate:[NSPredicate predicateWithFormat:@"%K like 'moodmon.doc'", NSMetadataItemFSNameKey]];
    [_metadataQuery setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope,nil]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryDidFinishGathering:) name:NSMetadataQueryDidFinishGatheringNotification object:_metadataQuery];
    
    [_metadataQuery startQuery];
}
- (void)metadataQueryDidFinishGathering:(NSNotification*)notification{
    NSMetadataQuery *query = [notification object];
    [query disableUpdates];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
    
    [query stopQuery];
    NSArray *result = [[NSArray alloc] initWithArray:[query results]];
    
    if([result count] == 1){
        _ubiquityURL = [result[0] valueForAttribute:NSMetadataItemURLKey];
        
        
        _document = [[MDDocument alloc] initWithFileURL: _ubiquityURL];
        
        [_document openWithCompletionHandler:^(BOOL success) {
            if(success){
                NSLog(@"Opened iCloud doc");
                _moodArray = (RLMArray*)_document.moodmonCollection;
            } else {
                NSLog(@"Failed to open iCloud doc");
            }
        }];
    } else {
        _document = [[MDDocument alloc] initWithFileURL:_ubiquityURL];
        
        [_document saveToURL:_ubiquityURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success){
                NSLog(@"Saved to iCloud");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudSyncFinished" object:self userInfo: @{@"message" : @"Finish saving into iCloud "}];
                
            } else {
                NSLog(@"Failed to save cloud");
            }
        }];
    }
}

-(void)deleteAllData{
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm deleteAllObjects];
    [realm commitWriteTransaction];
}

- (void)deleteAtRealmMoodmonIdx:(NSInteger)idx{
    NSString *query = [NSString stringWithFormat:@"idx = %ld",(long)idx];
    NSArray<Moodmon *> *result = (NSArray*)[Moodmon objectsWhere:query];
    Moodmon *willBeDeleted = [result firstObject];
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    if(willBeDeleted){
        [realm deleteObject:willBeDeleted];
    }
    [realm commitWriteTransaction];
}

-(NSUInteger)recentRealmMood{
    /* 감정별 숫자 매칭
     angry - 11~15
     happy - 21~25
     sad - 31~35
     excited - 41~45
     exhausted - 51~55
     */
    int count = (int)[self.moodArray count];
    NSLog(@"count : %d",count);
    if(count <= 0) return 0;
    int chosenCount = 0;
    int intenseSum[5] = {0,0,0,0,0};
    
    if(count < 6){
        for(int i = count -1 ; i >= 0 ; i--){
            int moodKind = 0;
            int moodIntense = 0;
            // NSLog(@"count : %d",count);
            Moodmon *temp = [self.moodArray objectAtIndex:i];
            if((int)temp.moodChosen1 ) {
                chosenCount++;
                moodKind = ((int)temp.moodChosen1/10);
                moodIntense = (int)temp.moodChosen1 % 10;
                intenseSum[moodKind-1] += moodIntense;
            }
            
            if((int)temp.moodChosen2 ){
                chosenCount++;
                moodKind = ((int)temp.moodChosen2/10);
                moodIntense = (int)temp.moodChosen2 % 10;
                intenseSum[moodKind-1] += moodIntense;
            }
            if((int)temp.moodChosen3 ) {
                chosenCount++;
                moodKind = ((int)temp.moodChosen3/10);
                moodIntense = (int)temp.moodChosen3 % 10;
                intenseSum[moodKind-1] += moodIntense;
            }
        }
    } else {
        for(int i = count-1 ; i >= (count-1)-5 ; i--){
            Moodmon *temp = [self.moodArray objectAtIndex:i];
            if((int)temp.moodChosen1 ) {
                
                chosenCount++;
                intenseSum[((int)temp.moodChosen1/10)-1] += (int)temp.moodChosen1 % 10;
            }
            
            if((int)temp.moodChosen2 ){
                chosenCount++;
                intenseSum[((int)temp.moodChosen2/10)-1] += (int)temp.moodChosen2 % 10;
            }
            if((int)temp.moodChosen3 ) {
                chosenCount++;
                intenseSum[((int)temp.moodChosen3/10)-1] += (int)temp.moodChosen3 % 10;
            }
        }
    }
    
    
    int bigIndex = 0;
    for(int i = 0 ; i < 5 ; i++){
        if(intenseSum[i] >= intenseSum[bigIndex]) bigIndex = i;
    }
    // NSLog(@"count : %d",bigIndex);
    //NSLog(@"%d %d %d %d %d ", intenseSum[0], intenseSum[2])
    
    return 10 *(bigIndex + 1) + ((int)intenseSum[bigIndex]/(int)chosenCount);
}

-(NSMutableArray<NSNumber*>*)representationOfRealmMoodMonAtYear:(NSInteger)year Month:(NSInteger)month andDay:(NSInteger)day{
    NSMutableArray *resultRepresentationArray = [[NSMutableArray alloc]initWithCapacity:3];
    RLMResults<Moodmon*> *result = [Moodmon objectsWhere: [NSString stringWithFormat:@"moodYear = %ld AND moodMonth = %ld AND moodDay = %ld", (long)year, (long)month, (long)day]];
    
    bool hasMoodMon;
    int chosenCount[5] = {0,0,0,0,0};
    int intenseSum[5] = {0,0,0,0,0};
    if(result.count > 0){
        hasMoodMon = YES;
    } else {
        hasMoodMon = NO;
    }
    for(int i = 0 ; i < result.count ; i++){
        int moodKind = 0;
        int moodIntense = 0;
        if((int)result[i].moodChosen1 ) {
            moodKind = (int)result[i].moodChosen1 / 10;
            moodIntense = (int)result[i].moodChosen1 % 10;
            chosenCount[moodKind-1]++;
            intenseSum[moodKind-1] += moodIntense;
        }
        
        if((int)result[i].moodChosen2 ){
            moodKind = (int)result[i].moodChosen2 / 10;
            moodIntense = (int)result[i].moodChosen2 % 10;
            chosenCount[moodKind-1]++;
            intenseSum[moodKind-1] += moodIntense;
        }
        if((int)result[i].moodChosen3 ) {
            moodKind = (int)result[i].moodChosen3 / 10;
            moodIntense = (int)result[i].moodChosen3 % 10;
            chosenCount[moodKind-1]++;
            intenseSum[moodKind-1] += moodIntense;
        }
    }
    
    if(hasMoodMon == NO){
        [resultRepresentationArray addObject:@0];
        [resultRepresentationArray addObject:@0];
        [resultRepresentationArray addObject:@0];
        return resultRepresentationArray;
    }
    
    int numOfSamebigCount = 0;
    int bigCountIdx = 0;
    for (int i= 0; i < 5; i++){
        if(chosenCount[i] < chosenCount[bigCountIdx]) continue;
        
        if(chosenCount[i] > chosenCount[bigCountIdx]){
            bigCountIdx = i;
            numOfSamebigCount = 1;
            [resultRepresentationArray removeAllObjects];
        } else if ( chosenCount[i] == chosenCount[bigCountIdx]){
            numOfSamebigCount ++;
        }
        
        if(chosenCount[i] > 0){
            [resultRepresentationArray addObject: [NSNumber numberWithInteger:( 10 *(i + 1) + ((int)intenseSum[i]/(int)chosenCount[i]))]];
        }
    }
    
    if(numOfSamebigCount <=3){
        
        int resultCount = (int)[resultRepresentationArray count];
        for(int i = resultCount; i < 3; i++){
            [resultRepresentationArray insertObject:@0 atIndex:i];
        }
        
        return resultRepresentationArray;
    }
    
    [resultRepresentationArray removeAllObjects];
    int topIntenseIndex1 = 0;
    int topIntenseIndex2 = 0;
    int topIntenseIndex3 = 0;
    
    for(int i = 0 ; i< 5 ; i++){
        
        if(intenseSum[i] >= intenseSum[topIntenseIndex1]){
            topIntenseIndex1 = i;
            [resultRepresentationArray insertObject: [NSNumber numberWithInteger:( 10 *(i + 1) + ((int)intenseSum[i]/(int)chosenCount[i]))] atIndex:0];
        }else if(intenseSum[i] >= intenseSum[topIntenseIndex2]){
            topIntenseIndex2 = i;
            [resultRepresentationArray insertObject: [NSNumber numberWithInteger:( 10 *(i + 1) + ((int)intenseSum[i]/(int)chosenCount[i]))] atIndex:1];
        }else if(intenseSum[i] >= intenseSum[topIntenseIndex3]){
            topIntenseIndex3 = i;
            [resultRepresentationArray insertObject: [NSNumber numberWithInteger:( 10 *(i + 1) + ((int)intenseSum[i]/(int)chosenCount[i]))] atIndex:2];
        }
    }
    
    int resultCount = (int)[resultRepresentationArray count];
    for(int i = resultCount; i < 3; i++){
        [resultRepresentationArray insertObject:@0 atIndex:i];
    }
    
    return resultRepresentationArray;
}


/*
 0 - angry - 11~15
 1 - happy - 21~25
 2 - sad - 31~35
 3 - excited - 41~45
 4 - exhausted - 51~55
 */
-(NSArray<Moodmon*>*)getFilteredMoodmons{
    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    NSMutableSet *chosenMoodInteger = [[NSMutableSet alloc]initWithCapacity:_chosenMoodCount];
    
    for(int i = 0 ; i<5 ; i++){
        if ([_isChecked[i] isEqual:@YES]){
            [chosenMoodInteger addObject: [NSNumber numberWithInteger:(i+1)]];
        }
    }
    
    RLMResults *allObject = [Moodmon allObjects];
    Moodmon *object;
    NSMutableSet *objectInteger =[[NSMutableSet alloc]init];
    for(int i = 0 ; i < allObject.count; i++ ){
        object = [allObject objectAtIndex:i];
        NSNumber *first = [NSNumber numberWithInteger:object.moodChosen1 / 10];
        [objectInteger addObject:  first];
        NSNumber *second =  [NSNumber numberWithInteger:object.moodChosen2 / 10];
        [objectInteger addObject:  second];
        NSNumber *third =  [NSNumber numberWithInteger:object.moodChosen3 / 10];
        [objectInteger addObject:  third];
        [objectInteger intersectSet:chosenMoodInteger];
        
        if([objectInteger count]>= _chosenMoodCount){
            [result addObject:object];
        }
        [objectInteger removeAllObjects];
    }
    
    NSLog(@"filtered: %@", result);
    
    return NULL;
}



@end
