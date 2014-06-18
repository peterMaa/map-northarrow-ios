//
//  AGSNorthArrowSampleViewController.m
//
//  Created by Nicholas Furness on 11/29/12.
//  Copyright (c) 2012 ESRI. All rights reserved.
//

#import "AGSNorthArrowSampleViewController.h"
#import <ArcGIS/ArcGIS.h>
#import "BasemapURLs.h"
#import "UIImageView+AGSNorthArrow.h"
#import <CoreLocation/CoreLocation.h>

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

@interface AGSNorthArrowSampleViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *northArrow;
@property (strong, nonatomic) CLLocationManager *locManager;
@end

@implementation AGSNorthArrowSampleViewController
bool rotateActive;
bool messageForSimulator;

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *basemapURL = [NSURL URLWithString:kGeoQCommunityURL];
    AGSTiledMapServiceLayer *basemapLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:basemapURL];
    [self.mapView addMapLayer:basemapLayer];

    self.mapView.allowRotationByPinching = YES;
    self.northArrow.mapViewForNorthArrow = self.mapView;

    AGSEnvelope *initialEnvelope = [AGSEnvelope envelopeWithXmin:13174000
                                                            ymin:3750000
                                                            xmax:13279000
                                                            ymax:3791000
                                                spatialReference:[AGSSpatialReference spatialReferenceWithWKID:102100]];
    [self.mapView zoomToEnvelope:initialEnvelope animated:YES];
    
    self.locManager = [[CLLocationManager alloc] init];
    self.locManager.delegate = self;
    
}

- (IBAction)randomAngleTapped:(id)sender {
    if (SIMULATOR == 1) {
        if (!messageForSimulator) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Atention" message:@"Compass not available,so give a random map rotation angle." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            messageForSimulator = !messageForSimulator;
        }
        double randomAngle = rand() % 360;
        [self.mapView setRotationAngle:randomAngle animated:YES];
    }else{
        if ([CLLocationManager headingAvailable])
        {
            if (rotateActive) {
                [self.locManager stopUpdatingHeading];
                [self.mapView setRotationAngle:0.0];
            }else{
                [self.locManager startUpdatingHeading];
            }
            rotateActive = !rotateActive;
        }
    }
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager error: %@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    double randomAngle = newHeading.magneticHeading;
    [self.mapView setRotationAngle:randomAngle animated:YES];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}
@end
