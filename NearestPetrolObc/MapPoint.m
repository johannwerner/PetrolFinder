//
//  MapPoint.m
//  DollarThrifty
//
//  Created by Johann on 2013/10/22.
//  Copyright (c) 2013 immedia. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "MapPoint.h"

@implementation MapPoint

-(id) initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t subtitle:(NSString *) st {
    self.coordinate = c;
    self.title = t;
    self.subtitle = st;
    return  self;
}

@end
