//
//  ViewController.m
//  MapDemo
//
//  Created by David on 16/9/5.
//  Copyright © 2016年 WM. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "WMAnnotation.h"
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

@interface ViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *lcManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D center;\
@property (nonatomic, strong) CLGeocoder * geocoder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.userTrackingMode = MKUserTrackingModeNone;
    _mapView.showsUserLocation = YES;
    _mapView.zoomEnabled = YES;
    _mapView.scrollEnabled = YES;
    _mapView.rotateEnabled = YES;
    _mapView.pitchEnabled = NO;
    _mapView.showsCompass = YES;
    _mapView.showsScale = YES;
    _mapView.showsTraffic = YES;
    _mapView.showsBuildings = YES;
    _mapView.showsPointsOfInterest = YES;
 
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        [self.lcManager requestAlwaysAuthorization];
        [self.lcManager requestWhenInUseAuthorization];
        [self.lcManager startUpdatingLocation];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN(@"9.0"))
    {
        _lcManager.allowsBackgroundLocationUpdates = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _lcManager.delegate = self;
    _mapView.delegate = self;
    [_lcManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _lcManager.delegate = nil;
    _mapView.delegate = nil;
    [_lcManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // oc中通过点击view获取经纬度
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [allTouches anyObject];
    CGPoint point = [touch locationInView:_mapView];
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    WMAnnotation *annotation = [self addAnnotionWith:coordinate title:@"淼哥" subtitle:@"世界你好"];
    // 反地理编码
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (!error) {
//            NSLog(@"%@",placemarks.firstObject);
            annotation.subtitle = placemarks.firstObject.name;
            annotation.title = placemarks.firstObject.thoroughfare;
        }
    }];
    
   
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray *annotations = [_mapView annotations];
    [_mapView removeAnnotations:annotations];
}

#pragma mark func
- (WMAnnotation *)addAnnotionWith:(CLLocationCoordinate2D) coordinate title:(NSString *)title subtitle:(NSString *)subtitle
{
    WMAnnotation *annotation = [[WMAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = title;
    annotation.subtitle = subtitle;
    [self.mapView addAnnotation:annotation];
    return annotation;
}

#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"%@", userLocation);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"%f---%f", mapView.region.span.latitudeDelta, mapView.region.span.longitudeDelta);
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString * iden = @"item";
    MKAnnotationView * annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:iden];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:iden];
    }
    annotationView.canShowCallout = YES;
    annotationView.annotation = annotation;
    annotationView.image = [UIImage imageNamed:@"Nearby_park"];
    return annotationView;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    // 模拟动态定位功能
    if (!_center.latitude) {
        CLLocationCoordinate2D center =  [[locations lastObject] coordinate];
        MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
        MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
        _center = center;
        [_mapView setRegion:region animated:YES];
    }
    
    [_lcManager stopUpdatingLocation];
}

#pragma mark setter and getter
- (CLLocationManager *)lcManager
{
    if (!_lcManager) {
        _lcManager = [[CLLocationManager alloc] init];
        _lcManager.delegate = self;
    }
    return _lcManager;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

@end
