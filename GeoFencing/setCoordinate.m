//
//  setCoordinate.m
//  GeoFencing
//
//  Created by Venkata Maniteja on 2015-05-13.
//  Copyright (c) 2015 Venkata Maniteja. All rights reserved.
//

#import "setCoordinate.h"

@interface setCoordinate ()<UITextFieldDelegate>

{
    CLLocationManager *locationManager;
}


@end

@implementation setCoordinate

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view endEditing:YES];
    
     self.latitudeField.delegate = self;
     self.longitudeField.delegate = self;
     self.radiusField.delegate = self;
    
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lat"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"long"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"rad"];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getCurrentLocation:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"This is title"
                                                                   message:@"This is message"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"I am a placeholder";
        
    }];
    
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Submit"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okAction];
    
    
    [self presentViewController:alert animated:YES completion:nil];

    
    //requesting the permission and getting current coordinates
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager requestAlwaysAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    float latitude = locationManager.location.coordinate.latitude;
    float longitude = locationManager.location.coordinate.longitude;
    
    _longitudeField.text = [NSString stringWithFormat:@"%.8f", latitude];
    _latitudeField.text = [NSString stringWithFormat:@"%.8f", longitude];
    
    NSLog(@"float valus are %f",[[_latitudeField text]doubleValue]);
    
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {


}

- (IBAction)saveCoordinates:(id)sender{
    
    //checking null fields
    if ([_longitudeField.text isEqual:@""] || [_latitudeField.text isEqual:@""] || [_radiusField.text isEqual:@""]) {
        
        UIAlertView *empty=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter all fields" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [empty show];
    }else{
    
        //saving the text field data into User Defaults with specific key for each
    NSUserDefaults *saveCoords=[NSUserDefaults standardUserDefaults];
    [saveCoords setObject:[NSNumber numberWithFloat:[[_latitudeField text]doubleValue]] forKey:@"lat"];
    [saveCoords setObject:[NSNumber numberWithFloat:[[_longitudeField text]doubleValue]] forKey:@"long"];
    [saveCoords setObject:[NSNumber numberWithFloat:[[_radiusField text]doubleValue]] forKey:@"rad"];
        
        //clearing the text fields
        _latitudeField.text=@"";
        _longitudeField.text=@"";
        _radiusField.text=@"";
        
        UIAlertView *save=[[UIAlertView alloc]initWithTitle:@"Saved!!" message:@"Coordinates entered are saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [save show];
    }
    
}


@end
