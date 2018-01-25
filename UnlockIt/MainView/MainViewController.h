//
//  ViewController.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "ViewControllerProtocol.h"
#import "KnownDeviceTableCell.h"

@interface MainViewController : UIViewController <ViewControllerProtocol, UITableViewDataSource, UITableViewDelegate, SwipeableCellDelegate, UIGestureRecognizerDelegate>

-(void)updateBluetoothState:(BOOL)state withText:(NSString*)stateText;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) NSMutableDictionary *dictionaryDevices;
@property (weak, nonatomic) IBOutlet UITableView *knownDevicesTable;
@property (weak, nonatomic) IBOutlet UILabel *activeLocksLabel;
@property (weak, nonatomic) IBOutlet UILabel *allLocksLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusActiveLocks;
@property (weak, nonatomic) IBOutlet UILabel *statusAllLocks;

@property (nonatomic, strong) LAContext *laContext;

-(void)startScan;
-(void)stopScan;



@end

