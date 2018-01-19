//
//  BluetoothModule.m
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "BluetoothModule.h"



@implementation BluetoothModule

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
    
    BOOL isPeripheralExist = false;
    
    for ( NSMutableDictionary *dictionary in peripheralsBLE ) {
        if ( [dictionary[@"CBPeripheral"] isEqual:peripheral] ) {
            isPeripheralExist = true;
            break;
        }
    }
    
    if ( !isPeripheralExist ) {
        [peripheral setDelegate:self];
        [central connectPeripheral:peripheral options:nil];
        
        NSMutableDictionary *peripheralDict = [[NSMutableDictionary alloc] init];
        [peripheralDict setObject:peripheral forKey:@"CBPeripheral"];

        [peripheralsBLE addObject:peripheralDict];
    }
    
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
       [peripheral discoverServices:nil];
       [peripheral readRSSI];
    
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DiscoverPeripheral" object:nil ];
};

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {

};

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
};

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    
};

- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    
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
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

#pragma mark - Work with BLE

-(void)startScan {
    [peripheralsBLE removeAllObjects];
    
    [centralManager scanForPeripheralsWithServices:nil options:nil];
    
}

-(void)stopScan {
    [centralManager stopScan];
    
}




@end
