//
//  MapPinAnnotation.h
//  Jobalo
//
//  Created by Maverics on 9/19/16.
//  Copyright © 2016 Max Alway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPinAnnotation : NSObject <MKAnnotation>

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
                placeName:(NSString *)placeName
              description:(NSString *)description;

@end
