//
//  checkCoord.m
//  GeoFencing
//
//  Created by Venkata Maniteja on 2015-05-13.
//  Copyright (c) 2015 Venkata Maniteja. All rights reserved.
//

#import "checkCoord.h"
#import <CoreLocation/CoreLocation.h>
#import "animatedCircle.h"
#import "FMResultSet.h"
#import "FMDatabase.h"




@interface checkCoord ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) sqlite3 *myDatabase;
@property (strong, nonatomic) NSString *statusOfAddingToDB;
@property (assign) float saved_lat;
@property (assign) float saved_lon;
@property (assign) float saved_rad;

@property (nonatomic,strong) IBOutlet UILabel *savedLat;
@property (nonatomic,strong) IBOutlet UILabel *savedLon;
@property (nonatomic,strong) IBOutlet UILabel *currentLat;
@property (nonatomic,strong) IBOutlet UILabel *currentLon;
@property (nonatomic,strong) IBOutlet UILabel *dist;






@end

@implementation checkCoord

@synthesize myDatabase;
@synthesize statusOfAddingToDB;
@synthesize saved_lat,saved_lon,saved_rad;
@synthesize savedLat,savedLon,currentLat,currentLon,dist;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do  setup after loading the view.
    map.delegate=self;
    
    NSUserDefaults *getCoords=[NSUserDefaults standardUserDefaults];
    saved_lat= [getCoords floatForKey:@"long"];
    saved_lon=[getCoords floatForKey:@"lat"];
    saved_rad=[getCoords floatForKey:@"rad"];
   
    savedLat.text=[NSString stringWithFormat:@"%f",saved_lat];
    savedLon.text=[NSString stringWithFormat:@"%f",saved_lon];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [self setLocationManager:[[CLLocationManager alloc] init]];
    [_locationManager requestAlwaysAuthorization];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager startUpdatingLocation];
    
    [map removeOverlays: map.overlays];
    
    
    [self addCircle];
    
}


-(NSString *)dataBasePath{
    
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    
    
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"GeoFence.db"]];
    
    //  NSError *error = nil;
    // [[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
    
    
   // NSLog(@"DB Path: %@", databasePath);
    
    return databasePath;
    
    
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    animatedCircle* circleView = [[animatedCircle alloc] initWithCircle:(MKCircle *)overlay];
    
    return circleView;
}


-(void)addCircle{
    
    CLLocationCoordinate2D location;
    
    location.latitude = saved_lat;
    location.longitude = saved_lon;  //use constants here
    
    //add annotation
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.coordinate = location;
    [map addAnnotation:anno];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //add overlay
        [map addOverlay:[MKCircle circleWithCenterCoordinate:location radius:saved_rad]];
        
        //zoom into the location with the defined circle at the middle
        [self zoomInto:location distance:(saved_rad * 4.0) animated:YES];
        
    });
    
    
}


#pragma mark - Helper

- (void)zoomInto:(CLLocationCoordinate2D)zoomLocation distance:(CGFloat)distance animated:(BOOL)animated{
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, distance, distance);
    MKCoordinateRegion adjustedRegion = [map regionThatFits:viewRegion];
    [map setRegion:adjustedRegion animated:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
   
    
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSUserDefaults *getCoords=[NSUserDefaults standardUserDefaults];
    float lon= [getCoords floatForKey:@"lat"];
    float lat=[getCoords floatForKey:@"long"];
    float rad=[getCoords floatForKey:@"rad"];
    
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:lat
                                                            longitude:lon];
    
    CLLocation *lastLocation=[locations lastObject];
    
    //display current lat and lon in text fields
    currentLat.text=[NSString stringWithFormat:@"%f",lastLocation.coordinate.latitude];
    currentLon.text=[NSString stringWithFormat:@"%f",lastLocation.coordinate.longitude];
    
    CLLocationDistance distance = [lastLocation distanceFromLocation:centerLocation];
  
    dist.text=[NSString stringWithFormat:@"%f",distance];
    
    if (distance<=rad) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALert" message:@"you entered the restrictted zone" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        NSString *currentDate=[NSString stringWithFormat:@"%@",[NSDate date]];
        
       //save the current timestamp into database
        FMDatabase *db = [FMDatabase databaseWithPath:[self dataBasePath]];
        [db open];
        [db executeUpdate:@"INSERT INTO GEO_HIST (TIME_HIST) VALUES (?)",currentDate,nil];
        [db close];
        
    }
    
    CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
    if(accuracy <=10) {   //accuracy in metres
        
        [manager stopUpdatingLocation];
    }
}




@end
