//
//  MapPoint.h
//  DollarThrifty
//
//  Created by Johann on 2013/10/22.
//  Copyright (c) 2013 immedia. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Foundation/Foundation.h>

@interface MapPoint : NSObject <MKAnnotation>

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;

-(id) initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t subtitle:(NSString *) st;

@end
