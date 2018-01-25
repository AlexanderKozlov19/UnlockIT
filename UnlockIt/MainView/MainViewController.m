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
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"ClearSans" size:23.0], NSFontAttributeName, nil];
    [self.navigationController.navigationBar  setBackgroundImage:[UIImage imageNamed:@"backImage.png"] forBarMetrics:UIBarMetricsDefault];
    
    UITapGestureRecognizer *tapRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableLocksViewModeChanged:)];//your action selector
    [tapRecognizer setNumberOfTapsRequired:1];
    
    self.activeLocksLabel.userInteractionEnabled = true;
    [self.activeLocksLabel addGestureRecognizer:tapRecognizer];
    
    tapRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableLocksViewModeChanged:)];//your action selector
    [tapRecognizer setNumberOfTapsRequired:1];
    
    self.allLocksLabel.userInteractionEnabled = true;
    [self.allLocksLabel addGestureRecognizer:tapRecognizer];
    
    
    

    
 //   self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
   // self.navigationController.navigationBar.translucent = NO;
   //     self.title = @"Unlock It";
    

    
    automaticStartScanForBLE = true;    // later will be stored in NSUserDefaults
    devicesArray = [[NSMutableArray alloc] init];
    
    NSArray *storedArray = [[[NSUserDefaults alloc] init] objectForKey:@"savedArray"];
    
    
    for ( NSDictionary *dictionary in storedArray ) {
        NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        [mutableDictionary setObject:@NO forKey:@"active"];
        [devicesArray addObject:mutableDictionary];
    }

    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Safe", @"Name", @"111-222", @"UUID", @YES, @"active", nil ];
    for ( int i = 0; i < 7; i++)
        [devicesArray addObject:mutableDictionary];
    
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

-(void)onTableLocksViewModeChanged:(id)sender {
   
    NSLog(@"onTap: %ld", ((UITapGestureRecognizer *)sender).view.tag );
    [self setupTableViewMode:((UITapGestureRecognizer *)sender).view.tag];
}

-(UIColor*)colorFmHex:(unsigned char)red greenPart:(unsigned char)green bluePart:(unsigned char)blue {
    UIColor *result = [UIColor colorWithRed:(float)red/255.0 green:(float)green/255.0 blue:(float)blue/255.0 alpha:1.0];
    return result;
    
}

-(void)setupTableViewMode:(int)iType {
    
    CGRect newFrame = self.statusActiveLocks.frame;
    newFrame.size.height = iType ? 1 : 2;
    newFrame.origin.y = iType ? 101: 100;
    
    self.statusActiveLocks.backgroundColor = iType ? [self colorFmHex:0x92 greenPart:0xA8 bluePart:0xC1]: [self colorFmHex:0x06 greenPart:0x7A bluePart:0xB5];
                                                                                                           
    self.statusActiveLocks.frame = newFrame;
    
    
    CGRect newFrame2 = self.statusAllLocks.frame;
    newFrame2.size.height = iType ? 2: 1;
    newFrame2.origin.y = iType ? 100 : 101;
    self.statusAllLocks.backgroundColor = iType ? [self colorFmHex:0x06 greenPart:0x7A bluePart:0xB5] : [self colorFmHex:0x92 greenPart:0xA8 bluePart:0xC1] ;
    
    self.statusAllLocks.frame = newFrame2;
    
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
        [self startScan];
        
       
}

-(void)startScan {
    //[self performSegueWithIdentifier:@"SegueToPeripheralView" sender:self];
    
    [[BluetoothModule SharedBluetoothModule] startScan:YES];
    
    
    
}

/*
-(BOOL)startScanForKnownDevices {
    BOOL result = NO;
    if ( [[BluetoothModule SharedBluetoothModule] isBluetoothReady] ) {
        if ( [devicesArray count] > 0 ) {

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
*/
-(void)stopScan {
    [[BluetoothModule SharedBluetoothModule] stopScan];
}

/*
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
 */
/*
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
*/
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
      //  if ( ![dictionary[@"active"] isEqual:[NSNull null]] && [dictionary[@"active"] isEqual:@YES] )
            numberOfRows++;
    }
    return numberOfRows;
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ( indexPath.row < [devicesArray count]) {
        KnownDeviceTableCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"knownDeviceTableCell"];
        tableCell.numberOfDataRow = (int)indexPath.row;
        tableCell.delegate = self;
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       // [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
    }
}

- (void)onDeleteButtonPressed:(int)numInDataRow {
    NSLog(@"delete button pressed %d", numInDataRow);
    [self showDeleteAlertForLock:numInDataRow];

    
}

- (void)onRenameButtonPressed:(int)numInDataRow {
    NSLog(@"rename button pressed %d", numInDataRow);
    [self showAlertWithInputNameForPeripheral:numInDataRow];
}

- (void)onUnlock:(int)numInDataRow {
    NSLog(@"unlock %d", numInDataRow);
    [self unlockWithLA:numInDataRow];
   
}

-(void)showAlertWithInputNameForPeripheral:(int)numberOfDataRow {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Input name for the lock" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSMutableDictionary *dictionary = [devicesArray objectAtIndex:numberOfDataRow];
        textField.text = dictionary[@"Name"];
        textField.placeholder = @"Name";
        textField.secureTextEntry = NO;
        
        
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *dictionary = [devicesArray objectAtIndex:numberOfDataRow];
        dictionary[@"Name"] = [[alertController textFields][0] text];
        [self.knownDevicesTable reloadData];
        [[[NSUserDefaults alloc] init] setObject:devicesArray forKey:@"savedArray"];
        
        
    }];
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)showDeleteAlertForLock:(int)numberOfDataRow {
    NSMutableDictionary *dictionary = [devicesArray objectAtIndex:numberOfDataRow];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: dictionary[@"Name"] message:@"Do you really want to forget this lock?"  preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [devicesArray removeObjectAtIndex:numberOfDataRow];
        [self.knownDevicesTable reloadData];

        
        
    }];
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)unlockWithLA:(int)numberDataRow {
    
NSError *err1 = nil;
    
    self.laContext = [[LAContext alloc] init];

BOOL bRes = [self.laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                        error:&err1];

if ( !bRes ) {
    NSLog(@"can't initialize Autentification");
    return;
}
    
    

[self.laContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"UnlockIT" reply:^(BOOL success, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            NSLog(@"unlock with TouchID!");
            [self.laContext invalidate];
        } else {
            NSLog(@"TouchID error: %@", error.description );
            [self.laContext invalidate];
        }
    });
}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
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
