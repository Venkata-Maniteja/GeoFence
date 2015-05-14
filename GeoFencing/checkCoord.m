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
#import <sqlite3.h>




@interface checkCoord ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *databasePath;
@property (nonatomic) sqlite3 *myDatabase;
@property (strong, nonatomic) NSString *statusOfAddingToDB;


@end

@implementation checkCoord

@synthesize databasePath;
@synthesize myDatabase;
@synthesize statusOfAddingToDB;





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setLocationManager:[[CLLocationManager alloc] init]];
    [_locationManager requestAlwaysAuthorization];
    [_locationManager setDelegate:self];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager startUpdatingLocation];
    
    map.delegate=self;
   
    [self prepareDatabase];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [map removeOverlays: map.overlays];
    [self addCircle];
    
    
}

- (void)prepareDatabase
{
    
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    
    
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"GeoFencing.db"]];
    
    //  NSError *error = nil;
    //  [[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
    
    
    NSLog(@"DB Path: %@", databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
            char *errMsg;
            
            const char *sql_stmt ="CREATE TABLE IF NOT EXISTS GEO_HIST (TIME_HIST TEXT )";
            if (sqlite3_exec(myDatabase, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                statusOfAddingToDB = @"Failed to create table";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else {
                
                statusOfAddingToDB = @"Success in creating table";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            sqlite3_close(myDatabase);
        } else {
            statusOfAddingToDB = @"Failed to open/create database";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DB Status" message:statusOfAddingToDB delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    
    animatedCircle* circleView = [[animatedCircle alloc] initWithCircle:(MKCircle *)overlay];
    
    return circleView;
}


-(void)addCircle{
    
    CLLocationCoordinate2D location;
    NSUserDefaults *getCoords=[NSUserDefaults standardUserDefaults];
    float lon= [getCoords floatForKey:@"lat"];
    float lat=[getCoords floatForKey:@"long"];
    float rad=[getCoords floatForKey:@"rad"];
    NSLog(@"lat and long are %f %f",lat,lon);
    
    location.latitude = lat;
    location.longitude = lon;  //use constants here
    
    //add annotation
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.coordinate = location;
    [map addAnnotation:anno];
    
    //add overlay
    [map addOverlay:[MKCircle circleWithCenterCoordinate:location radius:rad]];
    
    //zoom into the location with the defined circle at the middle
    [self zoomInto:location distance:(rad * 4.0) animated:YES];
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
    NSLog(@"lat and long are %f %f",lat,lon);
    
    
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:lat
                                                            longitude:lon];
    
    
    
    
    CLLocation *lastLocation=[locations lastObject];
    
    CLLocationDistance distance = [lastLocation distanceFromLocation:centerLocation];
    
    NSLog(@"distance is %f",distance);
    
    if (distance<=rad) {
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALert" message:@"you entered the zone" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
        
        sqlite3_stmt  *statement=NULL;
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &myDatabase) == SQLITE_OK) {
            //12,21
         NSString  * insertSQL = [NSString stringWithFormat:@"INSERT INTO GEO_HIST (TIME_HIST) VALUES (\"%@\")",
                         [NSDate date]];
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(myDatabase, insert_stmt,
                               -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE) {
                NSLog(@"data inserted");
            }
            else{
                NSLog(@"data not insertrd %s,",sqlite3_errmsg(myDatabase));
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(myDatabase);
        }
        
        
    }
    NSLog(@"locations are %@",locations);
    //2
    CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
  //  NSLog(@"Received location %@ with accuracy %f", lastLocation, accuracy);
    
    //3
    if(accuracy <=50) {   //metres
        //4
        
        
        // More code here
        
        [manager stopUpdatingLocation];
    }
}







/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
