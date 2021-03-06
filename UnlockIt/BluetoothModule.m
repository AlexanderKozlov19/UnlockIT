//
//  BluetoothModule.m
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "BluetoothModule.h"



@implementation BluetoothModule {
    BOOL isScanningBLE;
    BOOL scanOnlyForLocks;
}

@synthesize peripheralsBLE;



#pragma mark - Init

+(id)SharedBluetoothModule {
    
    static BluetoothModule *sharedBluetoothModule = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            sharedBluetoothModule = [[self alloc] init];
        
            
            
    });
    return sharedBluetoothModule;

    
}

-(id)init {
    isScanningBLE = false;
    scanOnlyForLocks = false;
    
    peripheralsBLE = [[NSMutableArray alloc] init];
    
    NSDictionary *optionsCB = [[NSDictionary alloc] initWithObjectsAndKeys:  @YES, @"CBCentralManagerOptionShowPowerAlertKey", nil ];

    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:optionsCB];
    return self;
}

#pragma mark - Central Manager Delegates

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
   
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ManagerUpdateState" object:[NSNumber numberWithInt:central.state] ];
 
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if ( scanOnlyForLocks && ( ![peripheral.name isEqualToString:@"Servo Control"] ) )
        return;
    
    BOOL isPeripheralExist = false;
    
    for ( NSMutableDictionary *dictionary in peripheralsBLE ) {
        if ( [dictionary[@"CBPeripheral"] isEqual:peripheral] ) {
            isPeripheralExist = true;
            break;
        }
    }
    
    if ( !isPeripheralExist ) {
        NSLog(@"bluetooth manager diddiscover: %@, UUID = %@", peripheral.name, peripheral.identifier.UUIDString);
        [peripheral setDelegate:self];
 
        [central connectPeripheral:peripheral options:nil];
        
        NSMutableDictionary *peripheralDict = [[NSMutableDictionary alloc] init];
        [peripheralDict setObject:peripheral forKey:@"CBPeripheral"];

        [peripheralsBLE addObject:peripheralDict];
    }
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    for ( NSMutableDictionary *dict in peripheralsBLE ) {
        CBPeripheral *peripheralLock = dict[@"CBPeripheral"];
        if ( [peripheralLock.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
            if ( [dict[@"NeedUnlock"] isEqual:@1] ) {
                [self unlockIt:peripheral.identifier.UUIDString];
                return;
            }
        }
    
      [peripheral discoverServices:nil];
       [peripheral readRSSI];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DiscoverPeripheral" object:peripheral ];
};

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral");

};

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didFailToConnectPeripheral");
};

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"didRetrieveConnectedPeripherals");
    
};

- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"didRetrievePeripherals");
};

#pragma mark - Peripheral Delegates
- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for ( CBService *service in peripheral.services ) {

        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for ( CBCharacteristic *charactersitc in service.characteristics )
        [peripheral discoverDescriptorsForCharacteristic:charactersitc];

}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error {
    
    for ( NSMutableDictionary *dictionary in peripheralsBLE ) {
        if ( [dictionary[@"CBPeripheral"] isEqual:peripheral] ) {
            [dictionary setValue:RSSI forKey:@"RSSI"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateRSSI" object:peripheral ];
            break;
        }
        
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"writeValueForCharacteristic: %@", error.localizedDescription);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

#pragma mark - Work with BLE

-(BOOL)isBluetoothReady {
    return ( centralManager.state == CBManagerStatePoweredOn );
}

-(BOOL)isScanning {
    return isScanningBLE;
}

-(void)startScan:(BOOL)onlyLocks {
    if ( isScanningBLE )
        [self stopScan];
    
    [peripheralsBLE removeAllObjects];
    
    scanOnlyForLocks = onlyLocks;
    
    [centralManager scanForPeripheralsWithServices:nil options:nil];
    isScanningBLE = YES;
    
    NSLog(@"Bluetooth: startScan");
    
}

-(void)stopScan {

    [centralManager stopScan];
    isScanningBLE = NO;
    
    for ( NSMutableDictionary *peripheralDict in peripheralsBLE ) {
        CBPeripheral *peripheral = peripheralDict[@"CBPeripheral"];
        [centralManager cancelPeripheralConnection:peripheral];
    }
    
    NSLog(@"Bluetooth: stopScan");

    
}


-(void)unlockIt:(NSString*)uuid {
   
    for ( NSMutableDictionary *dict in peripheralsBLE ) {
        CBPeripheral *peripheral = dict[@"CBPeripheral"];
        if ( [peripheral.identifier.UUIDString isEqualToString:uuid]) {
            
            if ( ( peripheral.state == CBPeripheralStateDisconnected ) || ( peripheral.state == CBPeripheralStateDisconnecting ) ) {
                dict[@"NeedUnlock"] = @YES;
                if ( !self->isScanningBLE )
                     [centralManager scanForPeripheralsWithServices:nil options:nil];
                [centralManager connectPeripheral:peripheral options:nil];
                return;
            }
            else if ( peripheral.state == CBPeripheralStateConnecting ) {
                dict[@"NeedUnlock"] = @YES;
                return;
                
            }
            
            for ( CBService *serice in peripheral.services ) {
                if ( [serice.UUID.UUIDString isEqualToString:@"1815"]) {
                    for ( CBCharacteristic *characteristic in serice.characteristics ) {
                        if ( [characteristic.UUID.UUIDString isEqualToString:@"2A56"]) {
                            unsigned char i = 1;
                            NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
                            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                            dict[@"NeedUnlock"] = @NO;
                            
                        }
                    }
                }
                    
            }
            break;
        }
    }
        
}




@end
