//
//  ViewController.m
//  MapApp
//
//  Created by mac on 2017/2/15.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "NaviPointAnnotation.h"
#import "SelectableOverlay.h"
#import "RouteCollectionViewCell.h"
#define kCollectionCellIdentifier @"cellId"
@interface ViewController ()<AMapSearchDelegate,MAMapViewDelegate,AMapNaviDriveManagerDelegate>
@property (nonatomic,strong) MAMapView *mapView;
@property (nonatomic, strong) AMapNaviPoint *startPoint,*endPoint;
@property (nonatomic, strong) AMapNaviDriveManager *driveManager;
@property (nonatomic, strong) NSMutableArray *routeIndicatorInfoArray;
@property (nonatomic, strong) UICollectionView *routeIndicatorView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //清扫手势
    UISwipeGestureRecognizer *swipe =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction)];
    swipe.direction =UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipeRight =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeActionright)];
    swipeRight.direction =UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UIButton *lineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lineBtn addTarget:self action:@selector(lineAction) forControlEvents:UIControlEventTouchUpInside];
    lineBtn.frame = CGRectMake(100, 30, 80, 30);
    [self.view addSubview:lineBtn];
    lineBtn.backgroundColor = [UIColor purpleColor];
    [lineBtn setTitle:@"路径规划" forState:UIControlStateNormal];
    
    UIButton *line1Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [line1Btn addTarget:self action:@selector(line1Action) forControlEvents:UIControlEventTouchUpInside];
    line1Btn.frame = CGRectMake(200, 30, 80, 30);
    [self.view addSubview:line1Btn];
    line1Btn.backgroundColor = [UIColor purpleColor];
    [line1Btn setTitle:@"画直线" forState:UIControlStateNormal];
    
    ///初始化地图
   self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 80, self.view.bounds.size.width, self.view.bounds.size.height - 40)];
    
    ///把地图添加至view
    [self.view addSubview:self.mapView];
    
    //如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    _mapView.delegate = self;
    
    self.startPoint = [AMapNaviPoint locationWithLatitude:31.138677 longitude:120.645157];
    self.endPoint = [AMapNaviPoint locationWithLatitude:31.4 longitude:120.65];
    
    self.driveManager = [[AMapNaviDriveManager alloc] init];
    [self.driveManager setDelegate:self];
    
     self.routeIndicatorInfoArray = [NSMutableArray array];
    // Do any additional setup after loading the view, typically from a nib.
}
//左边清扫
-(void)swipeAction{
  
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];

}
//右边清扫
-(void)swipeActionright {
   
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];

}
//划线
-(void)lineAction {
    //路径规划
    [self singleRoutePlanAction:nil];
   
}
//划线
-(void)line1Action {
    //画直线
    [self initRoute];
}

#pragma mark-  -----------------------------------------路径规划-------------------------------------------------
- (void)singleRoutePlanAction:(id)sender
{
    
    [_mapView removeAnnotations:_mapView.annotations];
    NaviPointAnnotation *beginAnnotation = [[NaviPointAnnotation alloc] init];
    [beginAnnotation setCoordinate:CLLocationCoordinate2DMake(self.startPoint.latitude, self.startPoint.longitude)];
    
    beginAnnotation.navPointType = NaviPointAnnotationStart;
    [self.mapView addAnnotation:beginAnnotation];
    
    NaviPointAnnotation *endAnnotation = [[NaviPointAnnotation alloc] init];
    [endAnnotation setCoordinate:CLLocationCoordinate2DMake(self.endPoint.latitude, self.endPoint.longitude)];
    endAnnotation.navPointType = NaviPointAnnotationEnd;
    [self.mapView addAnnotation:endAnnotation];
    
    //进行单路径规划
    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint]
                                                endPoints:@[self.endPoint]
                                                wayPoints:nil
                                          drivingStrategy:0];
    // 隐藏中间大头针
//    self.imageView.frame = CGRectZero;
    
}

#pragma mark - Handle Navi Routes

- (void)showNaviRoutes
{
    if ([self.driveManager.naviRoutes count] <= 0)
    {
        return;
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.routeIndicatorInfoArray removeAllObjects];
    
    //将路径显示到地图上
    for (NSNumber *aRouteID in [self.driveManager.naviRoutes allKeys])
    {
        AMapNaviRoute *aRoute = [[self.driveManager naviRoutes] objectForKey:aRouteID];
        int count = (int)[[aRoute routeCoordinates] count];
        
        //添加路径Polyline
        CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < count; i++)
        {
            AMapNaviPoint *coordinate = [[aRoute routeCoordinates] objectAtIndex:i];
            coords[i].latitude = [coordinate latitude];
            coords[i].longitude = [coordinate longitude];
        }
        
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coords count:count];
        
        SelectableOverlay *selectablePolyline = [[SelectableOverlay alloc] initWithOverlay:polyline];
        [selectablePolyline setRouteID:[aRouteID integerValue]];
        
        [self.mapView addOverlay:selectablePolyline];
        free(coords);
    }
    
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
    [self.routeIndicatorView reloadData];
    
    [self selectNaviRouteWithID:[[self.routeIndicatorInfoArray firstObject] routeID]];
}

- (void)selectNaviRouteWithID:(NSInteger)routeID
{
    //在开始导航前进行路径选择
    if ([self.driveManager selectNaviRouteWithRouteID:routeID])
    {
        [self selecteOverlayWithRouteID:routeID];
    }
    else
    {
        NSLog(@"路径选择失败!");
    }
}

- (void)selecteOverlayWithRouteID:(NSInteger)routeID
{
    [self.mapView.overlays enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id<MAOverlay> overlay, NSUInteger idx, BOOL *stop)
     {
         if ([overlay isKindOfClass:[SelectableOverlay class]])
         {
             SelectableOverlay *selectableOverlay = overlay;
             
             MAPolylineRenderer * overlayRenderer = (MAPolylineRenderer *)[self.mapView rendererForOverlay:selectableOverlay];
             
             if (selectableOverlay.routeID == routeID)
             {
                 selectableOverlay.selected = YES;
                 
                 overlayRenderer.fillColor   = selectableOverlay.selectedColor;
                 overlayRenderer.strokeColor = selectableOverlay.selectedColor;
                 
                 [self.mapView exchangeOverlayAtIndex:idx withOverlayAtIndex:self.mapView.overlays.count - 1];
             }
             else
             {
                 
                 selectableOverlay.selected = NO;
                 
                 
                 overlayRenderer.fillColor   = selectableOverlay.regularColor;
                 overlayRenderer.strokeColor = selectableOverlay.regularColor;
             }
             
             [overlayRenderer glRender];
         }
     }];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    
    [self showNaviRoutes];
}
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[SelectableOverlay class]])
    {
        SelectableOverlay * selectableOverlay = (SelectableOverlay *)overlay;
        id<MAOverlay> actualOverlay = selectableOverlay.overlay;
        
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:actualOverlay];
        
        polylineRenderer.lineWidth = 4.f;
        polylineRenderer.strokeColor = [UIColor redColor];
        
        return polylineRenderer;
    }
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 4.f;
        polylineView.strokeColor = [UIColor redColor];
        
        return polylineView;
    }
    
    return nil;
}
#pragma mark- 显示两点之间直线
- (void)showRouteForCoords:(CLLocationCoordinate2D *)coords count:(NSUInteger)count
{
    //show route
    MAPolyline *route = [MAPolyline polylineWithCoordinates:coords count:count];
    
    [self.mapView addOverlay:route];
    
    NSMutableArray * routeAnno = [NSMutableArray array];
    
    for (int i = 0 ; i < count; i++)
    {
        NaviPointAnnotation * a = [[NaviPointAnnotation alloc] init];
        a.coordinate = coords[i];
        a.title = @"route";
        [routeAnno addObject:a];
        if (i == 0) {
            a.navPointType = NaviPointAnnotationStart;
        }else if(i==1) {
            a.navPointType = NaviPointAnnotationEnd;
        }
        
        
        
    }
    [self.mapView addAnnotations:routeAnno];
  [self.mapView showAnnotations:routeAnno animated:NO];
    
}
#pragma mark- 显示两点之间距离的直线
-(void)initRoute
{
    NSUInteger count = 2;
    CLLocationCoordinate2D * coords = malloc(count * sizeof(CLLocationCoordinate2D));
    
    CLLocationCoordinate2D coordinate = {self.startPoint.latitude ,self.startPoint.longitude};
    CLLocationCoordinate2D coordinatebegin = {self.endPoint.latitude,self.endPoint.longitude};
//AMapNaviPoint
    coords[0] = coordinate;
    coords[1] = coordinatebegin;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self showRouteForCoords:coords count:count];
    
    if (coords) {
        free(coords);
    }
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    RouteCollectionViewCell *cell = [[self.routeIndicatorView visibleCells] firstObject];
    
    if (cell.info)
    {
        [self selectNaviRouteWithID:cell.info.routeID];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.routeIndicatorInfoArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RouteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCellIdentifier forIndexPath:indexPath];
    
    cell.shouldShowPrevIndicator = (indexPath.row > 0 && indexPath.row < _routeIndicatorInfoArray.count);
    cell.shouldShowNextIndicator = (indexPath.row >= 0 && indexPath.row < _routeIndicatorInfoArray.count-1);
    cell.info = self.routeIndicatorInfoArray[indexPath.row];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds) - 10, CGRectGetHeight(collectionView.bounds) - 5);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 5, 5, 5);
}


@end
