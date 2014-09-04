//
//  Station.m
//  NearestPetrolObc
//
//  Created by Johann Werner on 2014/08/31.
//  Copyright (c) 2014 Johann Werner. All rights reserved.
//

#import "Station.h"

@implementation Station

- (id)initWithDictionary:(NSDictionary *)attributes {
    self = [super init];
    if (self) {
        NSDictionary *properties = attributes[@"properties"];
        self.name = properties[@"name"];
        NSArray *coordinates = attributes[@"geometry"][@"coordinates"];
        self.latitude = [coordinates[1] floatValue];
        self.longitude = [coordinates[0] floatValue];
    }
    return self;
}

@end
