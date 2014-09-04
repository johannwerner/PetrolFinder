//
//  MasterViewController.m
//  NearestPetrolObc
//
//  Created by Johann Werner on 2014/08/31.
//  Copyright (c) 2014 Johann Werner. All rights reserved.
//

#import "MasterViewController.h"
#import <MapKit/MapKit.h>
#import "DetailViewController.h"
#import "Station.h"
#import "UIViewController+BaseContentViewController.h"

@interface MasterViewController ()  <CLLocationManagerDelegate, UISearchBarDelegate>
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@property NSMutableArray *objects;
@property NSMutableArray *stations;
@property NSMutableArray *allStations;
@end

@implementation MasterViewController
            
- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    NSDictionary *json = [self getJsonFromFileName:@"Petrol_ZA"];
    self.stations = json[@"features"];
    self.allStations = json[@"features"];
    self.searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSDictionary*)getJsonFromFileName:(NSString*)fileName {
    NSError *e = nil;
    NSString *responseString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:NSJSONReadingMutableContainers
                                                           error:&e];
    return JSON;
}



#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        if (indexPath.section == 0) {
            NSDate *object = self.objects[indexPath.row];
            [controller setDetailItem:object];
        } else {
            Station *station = [[Station alloc] initWithDictionary:[self.stations objectAtIndex:indexPath.row]];
            controller.station = station;
        }
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.objects.count;
    } else {
        return self.stations.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        NSDate *object = self.objects[indexPath.row];
        cell.textLabel.text = [object description];
    } else {
        Station *station = [[Station alloc] initWithDictionary:[self.stations objectAtIndex:indexPath.row]];
        cell.textLabel.text = station.name;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section == 0) {
            [self.objects removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.stations removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        
    }
}

#pragma mark - Core Location
- (BOOL)locationServicesEnabled {
    if (([CLLocationManager locationServicesEnabled]) && ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorizedAlways)) {
        return YES;
    } else {
        return NO;
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations lastObject];
    [self.locationManager stopUpdatingLocation];
    if (currentLocation != nil) {
        [self sortStationsByLocation:currentLocation];
    }
}

- (void)sortStationsByLocation:(CLLocation *)location {
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSArray *orderedLocations = [self.allStations sortedArrayUsingComparator:^(id a,id b) {
            Station *stationA = [[Station alloc] initWithDictionary:a];
            Station *stationB = [[Station alloc] initWithDictionary:b];
            
            CGFloat aLatitude = stationA.latitude;
            CGFloat aLongitude = stationA.longitude;
            CLLocation *participantALocation = [[CLLocation alloc] initWithLatitude:aLatitude longitude:aLongitude];
            
            CGFloat bLatitude = stationB.longitude;
            CGFloat bLongitude = stationB.latitude;
            CLLocation *participantBLocation = [[CLLocation alloc] initWithLatitude:bLatitude longitude:bLongitude];
            CLLocationDistance distanceA = [participantALocation distanceFromLocation:location];
            CLLocationDistance distanceB = [participantBLocation distanceFromLocation:location];
            
            return distanceA < distanceB ? NSOrderedAscending : distanceA > distanceB ? NSOrderedDescending : NSOrderedSame;
        }];
        //    self.stations = [[orderedLocations subarrayWithRange:NSMakeRange(0, 10)] mutableCopy];
        [self.stations removeAllObjects];
        self.stations = [orderedLocations mutableCopy];
        [self.tableView reloadData];
    });
}

#pragma mark - utility methods
- (void)updateLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    if([CLLocationManager locationServicesEnabled] == NO){
        //Your location service is not enabled, Settings>Location Services
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [self.locationManager startUpdatingLocation];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self addTapGestureToCloseKeyboardView:searchBar];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (IBAction)nearMe:(id)sender {
    [self updateLocation];
}

@end
