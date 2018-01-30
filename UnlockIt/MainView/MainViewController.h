//
//  ViewController.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewPresenter.h"
#import "ViewControllerProtocol.h"
#import "KnownDeviceTableCell.h"

@interface MainViewController : UIViewController <ViewControllerProtocol, UITableViewDataSource, UITableViewDelegate, SwipeableCellDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *knownDevicesTable;
@property (weak, nonatomic) IBOutlet UILabel *activeLocksLabel;
@property (weak, nonatomic) IBOutlet UILabel *allLocksLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusActiveLocks;
@property (weak, nonatomic) IBOutlet UILabel *statusAllLocks;
@property (weak, nonatomic) IBOutlet UIImageView *bluetoothStatusImage;
@property (weak, nonatomic) IBOutlet UIImageView *bioIDStatusImage;
@property (weak, nonatomic) IBOutlet UIImageView *lockStatusImage;
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioIDstatus;
@property (weak, nonatomic) IBOutlet UILabel *lockStatus;

@property (strong, nonatomic) MainViewPresenter *presenter;




@end

