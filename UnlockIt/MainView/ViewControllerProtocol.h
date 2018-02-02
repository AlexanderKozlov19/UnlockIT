//
//  ViewControllerProtocol.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ViewControllerProtocol <NSObject>

-(void)updateBluetoothState:(BOOL)state withText:(NSString*)stateText;
-(void)updateBioAuthorization:(BOOL)state forType:(int)biometryType;
-(void)updateLockStatus:(NSString*)stateText;

-(void)updateTable;
-(void)resetCellAfterUnlock:(NSInteger)numberOfRaw;

-(void)startBLEScanAnimation;
-(void)stopBLEScanAnimation;
-(void)startFingerPrintAnimation;
-(void)stopFingerPrintAnimation;
-(void)startLockAnimation;

-(void)setupTableViewSelectors:(BOOL)showOnlyActiveLocks;
-(void)showAllLocksCount:(NSInteger)count;
-(void)showActiveLocksCount:(NSInteger)count;



@end
