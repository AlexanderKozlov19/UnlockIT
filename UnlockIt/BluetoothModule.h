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
-(BOOL)isScanning;
-(CBManagerState)askForCentralManagerState;



-(void)startScan:(BOOL)onlyLocks;
-(void)stopScan;
-(void)disconnectPeripherals;

-(void)unlockIt:(NSString*)uuid;

-(void)forgetDeviceWithUUID:(NSString*)uuid;
@property (nonatomic, strong) NSMutableArray *peripheralsBLE;



@end
