//
//  UIImageView+AGSNorthArrow.m
//  AGSCommonPatternsSample
//
//  Created by Nicholas Furness on 2/14/14.
//  Copyright (c) 2014 ESRI. All rights reserved.
//

#import "UIImageView+AGSNorthArrow.h"
#import <objc/runtime.h>

#define kMapViewKey @"trackingMapView"
#define kAngleKey @"rotationAngle"
#define kTimerKey @"timer"
#define kAnimatingKey @"animating"

@interface UIImageView (AGSNorthArrowInternal)
@property (nonatomic, strong) NSTimer* timer;
@end

@implementation UIImageView (AGSNorthArrow)
-(void)setMapViewForNorthArrow:(AGSMapView *)mapView
{
    AGSMapView* oldMapView = self.mapViewForNorthArrow;
    if (oldMapView) {
        [self setNorthArrowAngle:0];
    }

    objc_setAssociatedObject(self, kMapViewKey, mapView, OBJC_ASSOCIATION_ASSIGN);
    
    if (mapView) {
        [self setNorthArrowAngle:mapView.rotationAngle];
        self.userInteractionEnabled = NO;

        // We want to know when the angle has changed
        [mapView addObserver:self forKeyPath:kAngleKey options:NSKeyValueObservingOptionNew context:nil];
        // But also we want to know if the map is animating towards a new angle
        [mapView addObserver:self forKeyPath:kAnimatingKey options:NSKeyValueObservingOptionNew context:nil];
    }
}

-(AGSMapView *)mapViewForNorthArrow
{
    return objc_getAssociatedObject(self, kMapViewKey);;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:kAngleKey]) {
        // New angle. Rotate to match.
        [self setNorthArrowAngle:(double)[object rotationAngle]];
    } else if ([keyPath isEqualToString:kAnimatingKey]) {
        if (self.mapViewForNorthArrow.animating) {
            // If we're animating, let's update the north arrow as we animate
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                          target:self
                                                        selector:@selector(checkRotation:)
                                                        userInfo:nil repeats:YES];
        } else if (self.timer) {
            // Finished animating. Stop updating on a timer.
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}

-(void)setTimer:(NSTimer *)timer
{
    if (timer) {
        objc_setAssociatedObject(self, kTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, kTimerKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
}

-(NSTimer *)timer
{
    return objc_getAssociatedObject(self, kTimerKey);
}

-(void)checkRotation:(NSTimer*)timer
{
    [self setNorthArrowAngle:self.mapViewForNorthArrow.rotationAngle];
}

-(void)setNorthArrowAngle:(double)mapAngle
{
    self.transform = CGAffineTransformMakeRotation(-M_PI * mapAngle / 180);
}
@end
