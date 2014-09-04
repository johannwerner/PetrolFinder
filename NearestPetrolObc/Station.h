//
//  Station.h
//  NearestPetrolObc
//
//  Created by Johann Werner on 2014/08/31.
//  Copyright (c) 2014 Johann Werner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Station : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) float longitude, latitude;

- (id)initWithDictionary:(NSDictionary *)attributes;

@end
