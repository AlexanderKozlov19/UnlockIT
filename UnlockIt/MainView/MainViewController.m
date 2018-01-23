//
//  ViewController.m
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "MainViewController.h"

#import "BluetoothModule.h"
#import "MainViewPresenter.h"
#import "PeripheralsView.h"
#import "KnownDeviceTableCell.h"

@interface MainViewController ()

@end


@implementation MainViewController {
    MainViewPresenter* presenter;
    BOOL    automaticStartScanForBLE;
    NSMutableArray *devicesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    automaticStartScanForBLE = true;    // later will be stored in NSUserDefaults
    devicesArray = [[NSMutableArray alloc] init];
    
    NSArray *storedArray = [[[NSUserDefaults alloc] init] objectForKey:@"savedArray"];
    
    
    for ( NSDictionary *dictionary in storedArray ) {
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        [mutableDictionary setObject:@NO forKey:@"active"];
        [devicesArray addObject:mutableDictionary];
    }

    [self.knownDevicesTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    presenter = [[MainViewPresenter alloc] init];
    [presenter setView:self];
    
    self.knownDevicesTable.delegate = self;
    self.knownDevicesTable.dataSource = self;
    
    
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
    
    
    [BluetoothModule SharedBluetoothModule];    // start Bluetooth
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onManagerDidUpdateState:(NSNotification *)data {
    [presenter onBluetoothState:data.object];
    
   

    
}


-(void)updateBluetoothState:(BOOL)state withText:(NSString*)stateText {
    if ( state )
       [self.statusImage setImage:[UIImage imageNamed: @"bluetoothOk"]];
    else
      [self.statusImage setImage:[UIImage imageNamed: @"bluetoothDis"]];
    
    [self.statusLabel setText:stateText];
    
   //if ( state && automaticStartScanForBLE )
  //      [self startScan];
    if ( state )
        [self startScanForKnownDevices];
        
       
}

-(void)startScan {
    [self performSegueWithIdentifier:@"SegueToPeripheralView" sender:self];
    
   // [[BluetoothModule SharedBluetoothModule] startScan];
    
    
    
}

-(BOOL)startScanForKnownDevices {
    BOOL result = NO;
    if ( [[BluetoothModule SharedBluetoothModule] isBluetoothReady] ) {
        if ( [devicesArray count] > 0 ) {
            /*
            NSMutableArray *scanDevices = [[NSMutableArray alloc] init];
            for ( NSMutableDictionary *dictionary in devicesArray ) {
                CBUUID *uuid = [CBUUID UUIDWithString:dictionary[@"UUID"]];
                [scanDevices addObject:uuid];
                break;
                
            }
             */
            Byte uuid[2];

            uuid[0] = 0x18;
            uuid[1] = 0x15;
            NSData *dataUUID = [NSData dataWithBytes:&uuid length:sizeof(uuid)];
            
            CBUUID *uuidCB = [CBUUID UUIDWithData:dataUUID];
            NSString *stringUUID = uuidCB.UUIDString;
            NSArray *scanDevices = @[ uuidCB ];
            [[BluetoothModule SharedBluetoothModule] startScan:scanDevices];//scanDevices];
            result = YES;
        }
    }
    return result;
}

-(void)stopScan {
    [[BluetoothModule SharedBluetoothModule] stopScan];
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue sender:(id)sender {

    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onDiscoverPeripheral:)
                                                 name: @"DiscoverPeripheral"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onUpdateRSSI:)
                                                 name: @"UpdateRSSI"
                                               object: nil];
    [self startScanForKnownDevices];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                 name: @"DiscoverPeripheral"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                 name: @"UpdateRSSI"
                                               object: nil];
   // if ( [segue.identifier  isEqual: @"SegueToPeripheralView"] )
   //     [[BluetoothModule SharedBluetoothModule] startScan:nil];

}

-(void)onDiscoverPeripheral:(NSNotification *)data {
    
    CBPeripheral *peripheral = data.object;
    NSLog(@"onDiscoverPeripheral MainView : %@", peripheral.name);
    for ( NSMutableDictionary *dictionary in devicesArray )  {
        if ( [dictionary[@"UUID"] isEqualToString:peripheral.identifier.UUIDString ] ) {
            [dictionary setObject:@YES forKey:@"active"];
            [self.knownDevicesTable reloadData];
            break;
        }
          
          
    };
}

-(void)onUpdateRSSI:(NSNotification *)data {
    
    /*CBPeripheral *peripheral = data.object;
    NSMutableArray *peripheralArray = [[BluetoothModule SharedBluetoothModule] peripheralsBLE];
    
    
    for ( int i = 0; i < [peripheralArray count]; i++ ) {
        NSMutableDictionary *dictionary = peripheralArray[i];
        
        if ( [dictionary[@"CBPeripheral"] isEqual:peripheral] ) {
            NSIndexPath *indexPath = [[NSIndexPath alloc]init];
            indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
            [self.peripheralTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic ];
        }
        
    }
    
    
    [self.peripheralTable reloadData];
     */
}

-(void)onAddNameToPeripheral:(NSNotification *)data {
    NSDictionary *dictIn = data.object;
    CBPeripheral *peripheral = dictIn[@"CBPeripheral"];
    NSDictionary *dictInfo = [[NSDictionary alloc] initWithObjectsAndKeys:peripheral.identifier.UUIDString, @"UUID", dictIn[@"Name"], @"Name", nil];
  
    [devicesArray addObject:dictInfo];
    [[[NSUserDefaults alloc] init] setObject:devicesArray forKey:@"savedArray"];
    
    [self.knownDevicesTable reloadData];
    
    
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numberOfRows = 0;
    for ( NSMutableDictionary *dictionary in devicesArray ) {
        if ( ![dictionary[@"active"] isEqual:[NSNull null]] && [dictionary[@"active"] isEqual:@YES] )
            numberOfRows++;
    }
    return numberOfRows;
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ( indexPath.row < [devicesArray count]) {
        KnownDeviceTableCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"knownDeviceTableCell"];
        NSDictionary *dict = [devicesArray objectAtIndex:indexPath.row];
        [tableCell.storedName setText:dict[@"Name"]];
        [tableCell.storedName sizeToFit];
        
        [tableCell.storedUUID setText:dict[@"UUID"]];
        [tableCell.storedUUID sizeToFit];
        
        cell = tableCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KnownDeviceTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[BluetoothModule SharedBluetoothModule] unlockIt:cell.storedUUID.text];
}



/*

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    <#code#>
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    <#code#>
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    <#code#>
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    <#code#>
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    <#code#>
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    <#code#>
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    <#code#>
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    <#code#>
}

- (void)setNeedsFocusUpdate {
    <#code#>
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    <#code#>
}

- (void)updateFocusIfNeeded {
    <#code#>
}
*/
@end
