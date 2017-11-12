//
//  MapViewController.m
//  TechCall
//
//  Created by Maverics on 9/8/16.
//  Copyright © 2016 David. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
@implementation MapViewController{
    IBOutlet MKMapView *mapView;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"Map";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self setupPinWithAddress:self.addresString];
}

- (void)setupPinWithAddress:(NSString*)location{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:topResult];
                         
                         MKCoordinateRegion region = mapView.region;
                         region.center = placemark.region.center;
                         region.span.longitudeDelta /= 8.0;
                         region.span.latitudeDelta /= 8.0;
                         
                         [mapView setRegion:region animated:YES];
                         [mapView addAnnotation:placemark];
                     }
                 }
     ];
}
@end
