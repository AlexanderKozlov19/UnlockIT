//
//  ViewController.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewControllerProtocol.h"
#import "KnownDeviceTableCell.h"

@interface MainViewController : UIViewController <ViewControllerProtocol, UITableViewDataSource, UITableViewDelegate, SwipeableCellDelegate>

-(void)updateBluetoothState:(BOOL)state withText:(NSString*)stateText;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) NSMutableDictionary *dictionaryDevices;
@property (weak, nonatomic) IBOutlet UITableView *knownDevicesTable;

-(void)startScan;
-(void)stopScan;



@end

