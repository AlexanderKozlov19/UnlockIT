//
//  MainViewPresenter.m
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "MainViewPresenter.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation MainViewPresenter

@synthesize view;

-(void)onBluetoothState:(NSNumber*)data {
    NSMutableString *stringText = [[NSMutableString alloc] init];
    BOOL status = NO;
    
    switch ([data intValue]) {
        case CBManagerStatePoweredOff:
            [stringText appendString:@"Bluetooth is powered off"];
            break;
        case CBManagerStatePoweredOn:
            [stringText appendString:@"Bluetooth is ready"];
            status = YES;
            //[self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBManagerStateResetting:
            [stringText appendString:@"Bluetooth is resetting"];
            break;
        case CBManagerStateUnauthorized:
            [stringText appendString:@"Bluetooth is unauthorized"];
            break;
        case CBManagerStateUnknown:
            [stringText appendString:@"Bluetooth state is unknown"];
            break;
        case CBManagerStateUnsupported:
            [stringText appendString:@"Bluetooth is unsupported"];
            break;
        default:
            break;
    }
    
  [view updateBluetoothState:status withText:stringText];
}


@end
