//
//  MainViewPresenter.m
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "MainViewPresenter.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothModule.h"

@implementation MainViewPresenter {
    BOOL    automaticStartScanForBLE;
    NSMutableArray *devicesArray, *activeDevicesArray, *showingDevicesArray;
    LAContext *laContext;
    BOOL    isModeShowActiveLocks;
}

@synthesize view, numberOfDispalyingLocks;

- (id)init {
    if (self = [super init])
    {
        //--- varibale initialization
        automaticStartScanForBLE = true;
        isModeShowActiveLocks = true;
        
        devicesArray = [[NSMutableArray alloc] init];
        
        activeDevicesArray = [[NSMutableArray alloc] init];
        
        NSArray *storedArray = [[[NSUserDefaults alloc] init] objectForKey:@"savedArray"];
        
        showingDevicesArray = activeDevicesArray;
        
        
        for ( NSDictionary *dictionary in storedArray ) {
            NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
            [mutableDictionary setObject:@NO forKey:@"active"];
            [mutableDictionary setObject:@NO forKey:@"UnlockAvailable"];
            [mutableDictionary removeObjectForKey:@"RSSI"];
            [devicesArray addObject:mutableDictionary];
        }
        
        //----- NSNotifications
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onManagerDidUpdateState:)
                                                     name: @"ManagerUpdateState"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onAddNameToPeripheral:)
                                                     name: @"AddNameToPeripheral"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onDiscoverPeripheral:)
                                                     name: @"DiscoverPeripheral"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onUpdateRSSI:)
                                                     name: @"UpdateRSSI"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onDiscoverUnlock:)
                                                     name: @"DiscoverUnlock"
                                                   object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(onUnlock:)
                                                     name: @"Unlocked"
                                                   object: nil];
 
    }
    return self;
}


#pragma mark - Communication with View
-(void)setView:(id<ViewControllerProtocol>)viewIn {
    view = viewIn;
    [view showAllLocksCount:[devicesArray count]];
}

-(BOOL)onBluetoothState:(NSNumber*)data {
    NSMutableString *stringText = [[NSMutableString alloc] init];
    BOOL status = NO;
    
    switch ([data intValue]) {
        case CBManagerStatePoweredOff:
            [stringText appendString:@"Off"];
            break;
        case CBManagerStatePoweredOn:
            [stringText appendString:@"Ready"];
            status = YES;
            //[self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBManagerStateResetting:
            [stringText appendString:@"Resetting"];
            break;
        case CBManagerStateUnauthorized:
            [stringText appendString:@"Unknown"];
            break;
        case CBManagerStateUnknown:
            [stringText appendString:@"Unknown"];
            break;
        case CBManagerStateUnsupported:
            [stringText appendString:@"Unsupported"];
            break;
        default:
            break;
    }
    
    [view updateBluetoothState:status withText:stringText];
    
    return status;

}

-(void)showActiveLocksCount {
    NSInteger activeLockAmount = 0;
    for ( NSMutableDictionary *dict in devicesArray ) {
        if ( [dict[@"active"] isEqual:@1 ] )
            activeLockAmount++;
    }
    
    [view showActiveLocksCount:activeLockAmount];
}

-(void)showAllLocksCount {
    
    [view showAllLocksCount:[devicesArray count]];
}

#pragma mark - Notifications
-(void)onManagerDidUpdateState:(NSNotification *)data {
    
    BOOL status = [self onBluetoothState:data.object];
    if ( status )
        [self startScan];
    else
        if ( [[BluetoothModule SharedBluetoothModule] isScanning] )
            [self stopScan];
    
}


-(void)onAddNameToPeripheral:(NSNotification *)data {
    NSDictionary *dictIn = data.object;
    CBPeripheral *peripheral = dictIn[@"CBPeripheral"];
    NSDictionary *dictInfo = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral.identifier.UUIDString, @"UUID", dictIn[@"Name"], @"Name", nil];
    
    [devicesArray addObject:dictInfo];
    [[[NSUserDefaults alloc] init] setObject:devicesArray forKey:@"savedArray"];
    
    [view updateTable];

}


-(void)onDiscoverPeripheral:(NSNotification *)data {
    
    CBPeripheral *peripheral = data.object;
    NSLog(@"onDiscoverPeripheral MainView : %@", peripheral.name);
    NSMutableDictionary *dictionary = nil;
    BOOL foundLock = false;
    
    for ( dictionary in devicesArray )  {
        if ( [dictionary[@"UUID"] isEqualToString:peripheral.identifier.UUIDString ] )
            foundLock = true;
        break;
    }
    
    if ( !foundLock ) {
        dictionary = [[NSMutableDictionary alloc] init];
        dictionary[@"UUID"] = peripheral.identifier.UUIDString;
        dictionary[@"Name"] = @"Unknown";
        [devicesArray addObject:dictionary];
        [self showAllLocksCount];
    }
    
    [dictionary setObject:@YES forKey:@"active"];
    [dictionary setObject:@NO forKey:@"UnlockAvailable"];
    [self showActiveLocksCount];
    [view updateTable];
    
    
}

-(void)onUpdateRSSI:(NSNotification *)data {
    NSMutableDictionary *dictionary = data.object;
    CBPeripheral *peripheral = dictionary[@"CBPeripheral"];
    
    for ( NSMutableDictionary *dictionaryF in devicesArray )
        if ( [dictionaryF[@"UUID"] isEqual:peripheral.identifier.UUIDString] ) {
            dictionaryF[@"RSSI"] = dictionary[@"RSSI"];
            break;
            
        }
    
    [view updateTable];
    
}

-(void)onDiscoverUnlock:(NSNotification *)data {
    CBPeripheral *peripheral = data.object;
    NSLog(@"onDiscoverUnlock: %@", peripheral.name);
    NSMutableDictionary *dictionary = nil;
    BOOL foundLock = false;
    
    for ( dictionary in devicesArray )  {
        if ( [dictionary[@"UUID"] isEqualToString:peripheral.identifier.UUIDString ] )
            foundLock = true;
        break;
    }
    
    if ( foundLock ) {
        [dictionary setObject:@YES forKey:@"UnlockAvailable"];
        [view updateTable];
    }
    
}

-(void)onUnlock:(NSNotification *)data {
    NSError *error = data.object;
    
    if ( error  )
        [view updateLockStatus:@"Error"];
    else {
        [view startLockAnimation];
        [view updateLockStatus:@"Unlocked"];
    }
    
    
}

#pragma mark - Local Autentification

-(void)checkBioID {
    laContext = [[LAContext alloc] init];
    NSError *error;
    BOOL bRes = [laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                            error:&error];
    [view updateBioAuthorization:bRes];
    
    [laContext invalidate];
}

#pragma mark - Work with BLE
-(void)startBluetooth {
    //----- start Bluetooth
    [BluetoothModule SharedBluetoothModule];
    
}

-(void)startScan {
    
    for ( NSMutableDictionary *dictionary in devicesArray ) {
        [dictionary setObject:@NO forKey:@"active"];
    }
    [self showActiveLocksCount];
    [view updateTable];
    [view startBLEScanAnimation];
    [view updateBluetoothState:YES withText:@"Scanning"];
    
    
    [[BluetoothModule SharedBluetoothModule] startScan:YES];
    
}

-(void)stopScan {
    [view stopBLEScanAnimation];
    [[BluetoothModule SharedBluetoothModule] stopScan];
    [self onBluetoothState:[NSNumber numberWithInt:[[BluetoothModule SharedBluetoothModule] askForCentralManagerState]]];
        
}

-(void)changeScanModeBLE {
    if ( [[BluetoothModule SharedBluetoothModule] isBluetoothReady] ) {
        if ( [[BluetoothModule SharedBluetoothModule] isScanning])
            [self stopScan];
        else
            [self startScan];
        
    }
}

-(void)unlockDevice:(NSInteger)number {
    NSError *err1 = nil;
    
     [view updateLockStatus:@""];
    
    laContext = [[LAContext alloc] init];
    
    BOOL bRes = [laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                            error:&err1];
    
    if ( !bRes ) {
        NSLog(@"can't initialize Autentification");
        [view updateBioAuthorization:bRes];
        return;
    }
    
    [view startFingerPrintAnimation];

    [laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"UnlockIT" reply:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSLog(@"unlock with TouchID!");
                [view stopFingerPrintAnimation];
                [laContext invalidate];
                
                NSMutableDictionary *dictionary = [showingDevicesArray objectAtIndex:number];
                [[BluetoothModule SharedBluetoothModule] unlockIt:dictionary[@"UUID"]];
                
                [view resetCellAfterUnlock:number];
            } else {
                NSLog(@"TouchID error: %@", error.description );
                [view stopFingerPrintAnimation];
                [laContext invalidate];
                [view resetCellAfterUnlock:number];
            }
        });
    }];
}


#pragma mark - Work with table
-(void)selectTableViewMode:(int)type {
    isModeShowActiveLocks = !type;
    [view setupTableViewSelectors:isModeShowActiveLocks];
    [view updateTable];
}

-(int)askForLocksCountForTableView {
    
    int numberOfRows = 0;
    [activeDevicesArray removeAllObjects];
    showingDevicesArray = isModeShowActiveLocks ? activeDevicesArray : devicesArray;
    
    for ( NSMutableDictionary *dictionary in devicesArray ) {
        if ( isModeShowActiveLocks ) {
            if ( [dictionary[@"active"] isEqual:@1] ) {
                numberOfRows++;
                [activeDevicesArray addObject:dictionary];
            }
        }
        else
            numberOfRows++;
    }
    
    return numberOfRows;
}

-(NSInteger)numberOfDispalyingLocks {
    return [showingDevicesArray count];
}

-(NSString*)nameForLocK:(NSInteger)number {
    NSDictionary *dict = [showingDevicesArray objectAtIndex:number];
    return dict[@"Name"];
}

-(NSString*)uuidForLock:(NSInteger)number {
    NSDictionary *dict = [showingDevicesArray objectAtIndex:number];
    if ( [dict objectForKey:@"RSSI" ] )
        return [[NSString alloc] initWithFormat:@"%@", [dict objectForKey:@"RSSI"]];
    else
        return @"";
}

-(NSString*)statusNameForLock:(NSInteger)number {
    NSDictionary *dict = [showingDevicesArray objectAtIndex:number];
    if ( [dict[@"active"] isEqual:@0] )
        return @"statusOff.png";
    else if ( [dict[@"UnlockAvailable"] isEqual:@NO ])
        return @"statusSearch.png";
    else
        return @"statusOk.png";
    
}

#pragma mark - Work with data
-(void)storeName:(NSString*)name forLock:(NSInteger)lockNumber  {
    NSMutableDictionary *dictionary = [showingDevicesArray objectAtIndex:lockNumber];
    dictionary[@"Name"] = name;
    [[[NSUserDefaults alloc] init] setObject:devicesArray forKey:@"savedArray"];
    [view updateTable];
    
}

-(void)forgetLock:(NSInteger)lockNumber {
    NSString *uuid = nil;
    if ( [devicesArray isEqual:devicesArray ]) {
        NSMutableDictionary *dict = [devicesArray objectAtIndex:lockNumber];
        uuid = [[NSString alloc] initWithString:dict[@"UUID"]];
        [devicesArray removeObjectAtIndex:lockNumber];
    }
    else {
        NSMutableDictionary *dict = [devicesArray objectAtIndex:lockNumber];
        uuid = [[NSString alloc] initWithString:dict[@"UUID"]];
        [devicesArray removeObject:dict];
    }

    [[[NSUserDefaults alloc] init] setObject:devicesArray forKey:@"savedArray"];
    [self showActiveLocksCount];
    [self showAllLocksCount];
    [view updateTable];
    
    [[BluetoothModule SharedBluetoothModule] forgetDeviceWithUUID:uuid];
}


@end
