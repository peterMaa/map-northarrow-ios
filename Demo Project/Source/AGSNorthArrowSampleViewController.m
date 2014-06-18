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

@interface AGSNorthArrowSampleViewController ()<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet AGSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *northArrow;
@property (strong, nonatomic) CLLocationManager *locManager;
@end

@implementation AGSNorthArrowSampleViewController
bool rotateActive;

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
    //double randomAngle = rand() % 360;
    //[self.mapView setRotationAngle:randomAngle animated:YES];
    //
    if ([CLLocationManager headingAvailable])
    {
        if (rotateActive) {
            [self.locManager stopUpdatingHeading];
        }else{
            [self.locManager startUpdatingHeading];
        }
        rotateActive = !rotateActive;
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"atention" message:@"compass not Available" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
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
    //CGFloat heading = -1.0f * M_PI * newHeading.magneticHeading / 180.0f;
    
    //angel.text=[[NSString alloc]initWithFormat:@"angle:%f",newHeading.magneticHeading];
    //arrow.transform = CGAffineTransformMakeRotation(heading);
    
    double randomAngle = newHeading.magneticHeading;
    [self.mapView setRotationAngle:randomAngle animated:YES];
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}
@end
