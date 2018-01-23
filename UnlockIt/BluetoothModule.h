//
//  BluetoothModule.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothModule : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
    CBCentralManager *centralManager;
}

+(id)SharedBluetoothModule;

-(BOOL)isBluetoothReady;


-(void)startScan:(BOOL)onlyLocks;
-(void)stopScan;

-(void)unlockIt:(NSString*)uuid;

@property (nonatomic, strong) NSMutableArray *peripheralsBLE;


@end
