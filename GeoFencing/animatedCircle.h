//
//  animatedCircle.h
//  GeoFencing
//
//  Created by Venkata Maniteja on 2015-05-14.
//  Copyright (c) 2015 Venkata Maniteja. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface animatedCircle : MKCircleView{
    
    UIImageView* imageView;
}

-(void)start;
-(void)stop;


@end
