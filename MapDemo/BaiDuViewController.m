//
//  BaiDuViewController.m
//  MapDemo
//
//  Created by David on 16/9/6.
//  Copyright © 2016年 WM. All rights reserved.
//

#import "BaiDuViewController.h"
#import <BaiduMapKit/BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapKit/BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapKit/BaiduMapAPI_Base/BMKTypes.h>
#import <BaiduMapKit/BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapKit/BaiduMapAPI_Map/BMKPointAnnotation.h>
#import "CustomBMKAnnotationView.h"
#import "CityModel.h"

@interface BaiDuViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (strong,nonatomic) BMKLocationService *lcService;
@property (strong, nonatomic) BMKGeoCodeSearch *geoCodeSearch;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CityModel *model;
@property (strong, nonatomic) CustomBMKAnnotationView *customView;
//@property (strong, nonatomic) BMKPointAnnotation 
@end

@implementation BaiDuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMapView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mapView.delegate = self;
    self.lcService.delegate =self;
    self.geoCodeSearch.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.mapView.delegate = nil;
    self.lcService.delegate = nil;
    self.geoCodeSearch.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initMapView
{
    [self.lcService startUserLocationService];
    _mapView.mapType = BMKMapTypeStandard;
    _mapView.showMapScaleBar = YES;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = BMKUserTrackingModeNone;
    _mapView.showMapPoi = YES;
    _mapView.trafficEnabled = YES;
    _mapView.gesturesEnabled = YES;
    _mapView.compassPosition = CGPointMake(20, 20);
}

#pragma mark  BMKMapViewDelegate



#pragma mark BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"%@", userLocation.location);
    _currentLocation = userLocation.location;
    BMKReverseGeoCodeOption *codeOption = [[BMKReverseGeoCodeOption alloc] init];
    codeOption.reverseGeoPoint = _currentLocation.coordinate;
    [self.geoCodeSearch reverseGeoCode:codeOption];
    [_mapView setCenterCoordinate:_currentLocation.coordinate];
//    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
//    annotation.coordinate = _currentLocation.coordinate;
//    annotation.title = @"喵哥";
//    annotation.subtitle = @"W了个M";
//    [_mapView addAnnotation:annotation];
    [_lcService stopUserLocationService];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    BMKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"item"];
    if (annotationView == nil) {
        annotationView = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"item"];
    }
    annotationView.image = [UIImage imageNamed:@"yuandian"];
    CustomBMKAnnotationView *view = [[CustomBMKAnnotationView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    view.backgroundColor = [UIColor redColor];
    view.model = self.model;
    self.customView = view;
    annotationView.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView: view];
    annotationView.canShowCallout = YES;
    annotationView.selected = YES;
    return annotationView;
}

#pragma mark BMKGeoCodeSearchDelegate
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"%@", result.address);
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"%@", result.address);
    CityModel *model = [[CityModel alloc] init];
    model.cityname = [result.addressDetail city];
    model.street_information = result.address;
//    self.customView.model = model;
    self.model = model;
    
    BMKPointAnnotation *annotation = [self addAnnotionView:model location:_currentLocation];
    [_mapView addAnnotation:annotation];
}


#pragma mark func
- (BMKPointAnnotation *)addAnnotionView:(CityModel *)model location:(CLLocation *)location
{
    BMKPointAnnotation * annotion = [[BMKPointAnnotation alloc] init];
    annotion.title = model.cityname;
    annotion.subtitle = model.street_information;
    annotion.coordinate = location.coordinate;
    return annotion;
}

#pragma mark setter and getter
- (BMKLocationService *)lcService
{
    if (!_lcService) {
        _lcService = [[BMKLocationService alloc] init];
    }
    return _lcService;
}

- (BMKGeoCodeSearch *)geoCodeSearch
{
    if (!_geoCodeSearch) {
        _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    }
    return _geoCodeSearch;
}

@end
