//
//  FoodieTableViewController.m
//  Foodie
//
//  Created by WangYing on 2/24/16.
//  Copyright (c) 2016 WangYing. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "FoodieTableViewController.h"
#import "DPHandlesMOC.h"
#import "RestaurantEntity.h"
#import "FoodieTableViewCell.h"
#import "DPHandlesRestaurantEntity.h"

@import UIKit;

@interface FoodieTableViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

//@property (nonatomic) bool boolInitial;

@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NSFetchedResultsController *resultsController;
@property (strong,nonatomic) RestaurantEntity *localRestaurantEntity;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBar;

@property (strong, nonatomic) UISearchController *searchController;

@property (nonatomic) bool rateSortingOrder;
@property (nonatomic) bool nameSortingOrder;

@end

@implementation FoodieTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = self.toolBar;
    [self initSeachBar];
    [self initializeNSFetchedResultsControllerDelegate];
    [self readFromURL];
}

- (void)initSeachBar{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Country"),
                                                          NSLocalizedString(@"ScopeButtonCapital",@"Capital")];
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)readFromURL{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSString *urlStr = @"http://localhost:8080/restraunts";
    
//    NSLog([NSString stringWithFormat:@"%lu", (unsigned long)[[self.resultsController.sections[0] objects] count]]);
//    
    NSURL *url = [NSURL URLWithString:urlStr];
    [[session dataTaskWithURL:url completionHandler:^ (NSData *  __nullable data, NSURLResponse * __nullable response, NSError * __nullable error) {
        //Check for network error
        if(error){
            NSLog(@"Error: Couldn't finish request: %@", error);
            return;
        }
        
        //Check for http error
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *) response;
        if (httpResp.statusCode < 200 || httpResp.statusCode >=300){
            NSLog(@"Error: Got status1 code %ld", (long)httpResp.statusCode);
            return;
        }
        
        //Check for JSON parse error
        NSError *parseErr;
        id pkg =[NSJSONSerialization JSONObjectWithData:data options:0 error:&parseErr];
        if (!pkg){
            NSLog(@"Error: Couldn't parse response: %@", parseErr);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSInteger i=0; i< [pkg count]; i++) {
                bool noRepetition = true;
                for (NSObject *restaurant in [self.resultsController.sections[0] objects]) {
                    if ([[restaurant valueForKey:@"restaurantTitle"] isEqualToString: pkg[i][@"name"]]) {
//                        NSLog([NSString stringWithFormat:@"%lu", [restaurant valueForKey:@"restaurantPic"]]);
                        noRepetition = false;
                        break;
                    }
                }
                if (noRepetition) {
                    self.localRestaurantEntity = [NSEntityDescription insertNewObjectForEntityForName:@"RestaurantEntity" inManagedObjectContext:self.managedObjectContext];
                    self.localRestaurantEntity.restaurantTitle = pkg[i][@"name"];
                    self.localRestaurantEntity.restaurantDetails = pkg[i][@"type"];
                    self.localRestaurantEntity.restaurantRate = pkg[i] [@"rating"];
                    [self saveRestaurantEntity];
                }
            }
        });
    }]resume];
}

- (void)saveRestaurantEntity{
    NSError *err;
    BOOL saveSuccess = [self.managedObjectContext save:&err];
    if (!saveSuccess){
        @throw [NSException exceptionWithName:NSGenericException reason:@"Couldn't save" userInfo:@{NSUnderlyingErrorKey:err}];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableViewDelegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resultsController.sections[section] numberOfObjects];
}

- (UITableViewCell *) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RestaurantEntity *item = [self.resultsController.sections[indexPath.section] objects][indexPath.row];
    
    FoodieTableViewCell *cell = (FoodieTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TableCellIdentifier" forIndexPath:indexPath];
    
    [cell setInternalFields:item];
    
    return cell;
}
- (IBAction)filterTapped:(id)sender {
    UISearchDisplayController *searchController = [[UISearchDisplayController alloc]
                        initWithSearchBar:self.searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
}

- (IBAction)rateSorting:(id)sender {
    [self sortingFunction:(NSString *)@"restaurantRate" sortMode:(bool)self.rateSortingOrder];
    self.rateSortingOrder =!self.rateSortingOrder;
}

- (IBAction)nameSorting:(id)sender {
    self.nameSortingOrder =!self.nameSortingOrder;
    [self sortingFunction:(NSString *)@"restaurantTitle" sortMode:(bool)self.nameSortingOrder];

}


- (void)sortingFunction: (NSString *)sortingType sortMode:(bool)ifAscending{

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"RestaurantEntity" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.predicate =[NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:sortingType ascending:ifAscending]];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    
    self.resultsController.delegate = self;
    
    NSError *err;
    BOOL fetchSucceed = [self.resultsController performFetch:&err];
    if(!fetchSucceed) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Couldn't fetch" userInfo:nil];
    }
    
    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:0];
    [[self tableView] reloadSections: indexSet withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - NSFetchedResultsControllerDelegate


- (void) initializeNSFetchedResultsControllerDelegate{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    fetchRequest.entity = [NSEntityDescription entityForName:@"RestaurantEntity" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.predicate =[NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"restaurantTitle" ascending:YES]];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
                              
                              
    self.resultsController.delegate = self;

    NSError *err;
    BOOL fetchSucceed = [self.resultsController performFetch:&err];
    if(!fetchSucceed) {
         @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Couldn't fetch" userInfo:nil];
    }
}


- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView]insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [[self tableView]deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: {
            FoodieTableViewCell *cell = (FoodieTableViewCell *)[self.tableView cellForRowAtIndexPath: indexPath];
            RestaurantEntity *item = [controller objectAtIndexPath:indexPath];
            [cell setInternalFields:item];
            break;
        }
        case NSFetchedResultsChangeMove:
            [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}


#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    id<DPHandlesMOC, DPHandlesRestaurantEntity> child = (id<DPHandlesMOC,DPHandlesRestaurantEntity>)[segue destinationViewController];
    [child receiveMOC:self.managedObjectContext];
    
    RestaurantEntity *item;
    if ([sender isMemberOfClass:[UIBarButtonItem class]]) {
        item = [NSEntityDescription insertNewObjectForEntityForName:@"RestaurantEntity" inManagedObjectContext:self.managedObjectContext];
    }
    else{
        FoodieTableViewCell *source = (FoodieTableViewCell *) sender;
        item = source.localRestaurantEntity;
    }
    
    [child receiveRestaurantEntity:item];
    
}



- (void) receiveMOC:(NSManagedObjectContext *)incomingMOC{
    self.managedObjectContext = incomingMOC;
}

@end
