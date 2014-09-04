//
//  DetailViewController.m
//  NearestPetrolObc
//
//  Created by Johann Werner on 2014/08/31.
//  Copyright (c) 2014 Johann Werner. All rights reserved.
//

#import "DetailViewController.h"
#import <MapKit/MapKit.h>
#import "Station.h"
#import "MapPoint.h"
#import "MapPopOverViewController.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,strong) UIPopoverController *mapPopover;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapsButton;

@end

@implementation DetailViewController
            
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
    if (self.station) {
        float latitude = self.station.latitude;
        float longitude = self.station.longitude;
        [self showSpecificLocationOnMapForLatitude:latitude AndLongitude:longitude];
        [self geocodeLocation];
        self.mapsButton.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.mapsButton.enabled = NO;
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dropPinAtSpecificLatitude:(float)latitude AndLongitude:(float)longitude title:(NSString*)title subtitle:(NSString*)subtitle {
    CLLocationCoordinate2D  coordinates;
    coordinates.latitude = latitude;
    coordinates.longitude = longitude;
    if (CLLocationCoordinate2DIsValid(coordinates)) {
        MapPoint *addAnnotation = [[MapPoint alloc] initWithCoordinate:coordinates title:title subtitle:subtitle];
        [self.mapView addAnnotation:addAnnotation];
    }
}

- (void)showSpecificLocationOnMapForLatitude:(float)latitude AndLongitude:(float)longitude {
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = latitude;
    ctrpoint.longitude = longitude;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    MKCoordinateRegion region;
    region.span = span;
    region.center = ctrpoint;
    [self.mapView setRegion:region animated:YES];
}

- (void)geocodeLocation {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.station.latitude longitude:self.station.longitude];
    if (!self.geocoder)
        self.geocoder = [[CLGeocoder alloc] init];
    
    [self.geocoder reverseGeocodeLocation:location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         NSString *fullThoroughfare = @"";
         if (!error) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
             if (placemark.subThoroughfare && placemark.thoroughfare) {
                              fullThoroughfare = [NSString stringWithFormat:@"%@ %@",placemark.subThoroughfare,placemark.thoroughfare];
             } else {
                 fullThoroughfare = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             }
         }
         [self dropPinAtSpecificLatitude:self.station.latitude AndLongitude:self.station.longitude title:self.station.name subtitle:fullThoroughfare];
     }];
}


- (IBAction)openInMaps:(id)sender {
    NSString *openMapsString = [NSString stringWithFormat:@"http://maps.apple.com/?q=%f,%f",self.station.latitude,self.station.longitude];
    NSURL* url = [[NSURL alloc] initWithString:openMapsString];
    [[UIApplication sharedApplication] openURL:url];
}

//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
//    if (![view.annotation isKindOfClass:[MKUserLocation class]] ) {
//        
//        [mapView deselectAnnotation:view.annotation animated:YES];
//        MapPopOverViewController *mapPopOverViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapPopOver"];
//
//        mapPopOverViewController.modalPresentationStyle = UIModalPresentationPopover;
//        [self presentViewController:mapPopOverViewController animated: YES completion: nil];
//        
//        UIPopoverPresentationController *presentationController =
//        [mapPopOverViewController popoverPresentationController];
//        presentationController.permittedArrowDirections =
//        UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight;
//        
//    }
//}

@end
