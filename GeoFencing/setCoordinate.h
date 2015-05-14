//
//  setCoordinate.h
//  GeoFencing
//
//  Created by Venkata Maniteja on 2015-05-13.
//  Copyright (c) 2015 Venkata Maniteja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface setCoordinate : UIViewController<CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *latitudeField;
@property (weak, nonatomic) IBOutlet UITextField *longitudeField;

@property (weak, nonatomic) IBOutlet UITextField *radiusField;
- (IBAction)getCurrentLocation:(id)sender;
- (IBAction)saveCoordinates:(id)sender;

@end
