//
//  MDSearchTableViewController.m
//  moodMon
//
//  Created by Lee Kyu-Won on 4/25/16.
//  Copyright © 2016 HUB. All rights reserved.
//

#import "MDSearchTableViewController.h"
#import "MDSearchTableViewCell.h"
#import "MDMoodColorView.h"
#import "MDSmallMoodFaceView.h"

@implementation MDSearchTableViewController{
    BOOL isFirstVisit;
}
UIVisualEffectView *blurEffectView;
UIVisualEffectView *visualEffectView;


-(void)viewDidLoad{
    
    self.dataManager = [MDDataManager sharedDataManager];
    isFirstVisit = YES;
    [self setBlurEffect];
    //[self.tableView registerClass:[MDSearchTableViewCell class] forCellReuseIdentifier:@"searchTableCell"];
    [self setNavigationSearch];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    [self.searchController setActive:YES];
    [self.searchController.searchBar becomeFirstResponder];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            //[self.searchController.searchBar.window makeKeyAndVisible];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
    
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    isFirstVisit = NO;
    [searchBar resignFirstResponder];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}




#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    if(searchText.length == 0) return;
    
    NSArray *result = [searchText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *searchString =  [result componentsJoinedByString:@""];
    //NSLog(@"!!!%@!!!! %d",searchString, searchString.length);
    if(searchString.length == 0) return;
    
    
    //    NSMutableArray *searchResults = (NSMutableArray*)_dataManager.moodArray ;
    //
    //    // strip out all the leading and trailing spaces
    //    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    //
    //    // break up the search terms (separated by spaces)
    //    NSArray *searchItems = nil;
    //    if (strippedString.length > 0) {
    //        searchItems = [strippedString componentsSeparatedByString:@" "];
    //    }
    //
    //    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    //
    //    for (NSString *searchString in searchItems) {
    //        // each searchString creates an OR predicate for: name, yearIntroduced, introPrice
    //        //
    //        // example if searchItems contains "iphone 599 2007":
    //        //      name CONTAINS[c] "iphone"
    //        //      name CONTAINS[c] "599", yearIntroduced ==[c] 599, introPrice ==[c] 599
    //        //      name CONTAINS[c] "2007", yearIntroduced ==[c] 2007, introPrice ==[c] 2007
    //        //
    //        NSMutableArray *searchItemsPredicate = [NSMutableArray array];
    //
    //        // name field matching
    //        NSExpression *lhs = [NSExpression expressionForKeyPath:@"moodComment"];
    //        NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
    //        NSPredicate *finalPredicate = [NSComparisonPredicate
    //                                       predicateWithLeftExpression:lhs
    //                                       rightExpression:rhs
    //                                       modifier:NSDirectPredicateModifier
    //                                       type:NSContainsPredicateOperatorType
    //                                       options:NSCaseInsensitivePredicateOption];
    //        [searchItemsPredicate addObject:finalPredicate];
    //
    //
    //
    //        // at this OR predicate to our master AND predicate
    //        NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
    //        [andMatchPredicates addObject:orMatchPredicates];
    //    }
    //
    //    // match up the fields of the Product object
    //    NSCompoundPredicate *finalCompoundPredicate =
    //    [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
    //    searchResults = [[searchResults filteredArrayUsingPredicate:finalCompoundPredicate] mutableCopy];
    //
    //
    NSString *query = [NSString stringWithFormat:@"moodComment CONTAINS[c] '%@'",searchString] ;
    _filteredProducts = (NSArray*)[Moodmon objectsWhere: query];
    [self.tableView reloadData];
    
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger numOfSections = 0;
    if (self.filteredProducts.count > 0)
    {
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        numOfSections                 = 1;
        self.tableView.backgroundView   = nil;
    }
    else if(isFirstVisit == NO)
    {
        UILabel *noDataLabel         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height)];
        noDataLabel.text             = @"No such MOODMON";
        noDataLabel.textColor        = [UIColor blackColor];
        noDataLabel.textAlignment    = NSTextAlignmentCenter;
        self.tableView.backgroundView = noDataLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return numOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //NSLog(@"how many? %lu", (unsigned long)self.filteredProducts.count);
    return self.filteredProducts.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    MDEndPageViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"MDEndPageViewController"];
    
    MDSearchTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    VC.moodColorView = cell.moodColorView;
    VC.timest = cell.timest;
    VC.dateString = cell.date;
    VC.comment = cell.commentLabel.text;
    VC.idx = (NSInteger)cell.tag;
    
    [self.navigationController.navigationBar addSubview:visualEffectView];
    [self.view addSubview:blurEffectView];
    VC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:VC animated:YES completion:nil];
}


// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MDSearchTableViewCell *cell = (MDSearchTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"searchTableCell" forIndexPath:indexPath];
    
    if([self.filteredProducts count] <= 0){
        return cell;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    Moodmon *resultMoodmon = self.filteredProducts[indexPath.row];
    UIView *viewForFrame =  [cell viewWithTag:100];
    viewForFrame.layer.cornerRadius = viewForFrame.frame.size.width/2;
    viewForFrame.layer.masksToBounds = YES;
    
    CGRect frame = CGRectMake(viewForFrame.frame.origin.x, 8, viewForFrame.frame.size.width, viewForFrame.frame.size.height);
    [cell.moodColorView setFrame:frame];
    [cell.moodFaceView setFrame:frame];
    
    [cell drawWithMoodmon:resultMoodmon];
    
    cell.tag = (NSInteger)resultMoodmon.idx;
    cell.commentLabel.text = resultMoodmon.moodComment;
    NSString *selectedTime = resultMoodmon.moodTime;
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

    NSString *result = [NSString stringWithFormat:NSLocalizedString(@"Search Full Time Format+", nil), (long)resultMoodmon.moodYear, (long)resultMoodmon.moodMonth, (long)resultMoodmon.moodDay, tt, hour, timeComponents[1], timeComponents[2] ];
    cell.timeLabel.text = result;
    
   
    return cell;
}




#pragma mark - UIStateRestoration

// we restore several items for state restoration:
//  1) Search controller's active state,
//  2) search text,
//  3) first responder

NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}

-(void)setBlurEffect{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:[UIScreen mainScreen].bounds];
    blurEffectView.tag = 799;
    
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.navigationController.navigationBar.bounds;
    visualEffectView.tag = 798;
    visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteBlur:) name:@"deleteBlur" object:nil];
}

-(void)deleteBlur:(NSNotification*)notification{
    [[self.view viewWithTag:799]removeFromSuperview];
    [[self.navigationController.navigationBar viewWithTag:798]removeFromSuperview];
}

-(void)setNavigationSearch{
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    self.searchController.searchBar.placeholder = NSLocalizedString(@"Search a Word or Text", nil);
    self.filteredProducts = nil;
}

@end
