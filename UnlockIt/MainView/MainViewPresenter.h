//
//  MainViewPresenter.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ViewControllerProtocol.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface MainViewPresenter : NSObject

@property (weak, nonatomic)  id <ViewControllerProtocol> view;

-(void)startBluetooth;
-(void)changeScanModeBLE;
-(void)stopScan;

-(void)checkBioID;

@property (nonatomic, assign, readonly) NSInteger numberOfDispalyingLocks;
-(void)selectTableViewMode:(int)type;
-(int)askForLocksCountForTableView;
-(NSString*)nameForLocK:(NSInteger)number;
-(NSString*)uuidForLock:(NSInteger)number;
-(NSString*)statusNameForLock:(NSInteger)number;

-(void)storeName:(NSString*)name forLock:(NSInteger)lockNumber;
-(void)forgetLock:(NSInteger)lockNumber;

-(void)unlockDevice:(NSInteger)number;




@end
