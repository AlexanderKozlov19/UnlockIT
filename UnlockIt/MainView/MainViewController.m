//
//  ViewController.m
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController ()

@end


@implementation MainViewController

@synthesize presenter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //--- Navigation controller and shadow setup
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           shadow, NSShadowAttributeName,
                                                           [UIFont fontWithName:@"ClearSans" size:23.0], NSFontAttributeName, nil];
    [self.navigationController.navigationBar  setBackgroundImage:[[UIImage imageNamed:@"backImage.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
    
    //---- selectors for locks
    UITapGestureRecognizer *tapRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableLocksViewModeChanged:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    
    self.activeLocksLabel.userInteractionEnabled = true;
    [self.activeLocksLabel addGestureRecognizer:tapRecognizer];
    
    tapRecognizer= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTableLocksViewModeChanged:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    
    self.allLocksLabel.userInteractionEnabled = true;
    [self.allLocksLabel addGestureRecognizer:tapRecognizer];
    
    //---- selector for images
    UITapGestureRecognizer *tapRecognizerBLE= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onScanBluetoothImage)];
    [tapRecognizerBLE setNumberOfTapsRequired:1];
    
    self.bluetoothStatusImage.userInteractionEnabled = true;
    [self.bluetoothStatusImage addGestureRecognizer:tapRecognizerBLE];
    
    
    //----- variable initialization
    presenter = [[MainViewPresenter alloc] init];
    [presenter setView:self];
    [presenter checkBioID];
    
    
    //----- view configuration
    //[self.knownDevicesTable setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];

    self.knownDevicesTable.delegate = self;
    self.knownDevicesTable.dataSource = self;
    
    self.knownDevicesTable.layer.borderWidth = 1.0;
    self.knownDevicesTable.layer.borderColor = [[self colorFmHex:0x06 greenPart:0x7A bluePart:0xB5] CGColor];
   
     self.knownDevicesTable.backgroundColor = [self colorFmHex:0xFA greenPart:0xFA bluePart:0xFB];
    self.knownDevicesTable.layer.shadowColor = [[self colorFmHex:0x92 greenPart:0xA8 bluePart:0xC1] CGColor];
    self.knownDevicesTable.layer.shadowOffset = CGSizeMake(0, 3);
    self.knownDevicesTable.layer.shadowOpacity = 0.5;
   // self.knownDevicesTable.layer.masksToBounds = NO;

    [self.lockStatusImage setImage:[UIImage imageNamed:@"lock_1.png"]];
    
    [self setupTableViewSelectors:YES];
    
    //---- start Bluetooth
    [presenter startBluetooth];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIColor*)colorFmHex:(unsigned char)red greenPart:(unsigned char)green bluePart:(unsigned char)blue {
    UIColor *result = [UIColor colorWithRed:(float)red/255.0 green:(float)green/255.0 blue:(float)blue/255.0 alpha:1.0];
    return result;
    
}

#pragma mark - Presenter protocol
-(void)updateBluetoothState:(BOOL)state withText:(NSString*)stateText {
    [self.bluetoothStatusLabel setText:stateText];
    
    if ( state ) {
        [self.bluetoothStatusImage setImage:[UIImage imageNamed:@"bluetooth_scan0.png"]];
    }
    else {
        [self.bluetoothStatusImage setImage:[UIImage imageNamed:@"bluetooth_disabled.png"]];
    }
    
}

-(void)updateTable {
    [self.knownDevicesTable reloadData];
}

-(void)updateBioAuthorization:(BOOL)state forType:(int)biometryType {
    
    if ( state ) {
        if ( biometryType == 1 )
             [self.bioIDStatusImage setImage:[UIImage imageNamed:@"fingerprint_1.png"]];
        else
            if ( biometryType == 2 )
                [self.bioIDStatusImage setImage:[UIImage imageNamed:@"faceIDOk.png"]];
        [self.bioIDstatus setText:@"Ready"];
    }
    else {
        if ( biometryType == 1 )
            [self.bioIDStatusImage setImage:[UIImage imageNamed:@"fingerprintDis.png"]];
        else
            if ( biometryType == 2 )
                [self.bioIDStatusImage setImage:[UIImage imageNamed:@"faceIDDis.png"]];
        [self.bioIDstatus setText:@"Unavailable"];
    }
}

-(void)updateLockStatus:(NSString*)stateText {
    [self.lockStatus setText:stateText];
}

-(void)startBLEScanAnimation {
    NSMutableArray *scanAnimations = [NSMutableArray array];
    for(int i = 0; i <= 3; ++i) {
        [scanAnimations addObject:[UIImage imageNamed:[NSString stringWithFormat:@"bluetooth_scan%d.png", i]]];
    }
    
    self.bluetoothStatusImage.animationImages = scanAnimations;
    self.bluetoothStatusImage.animationDuration = 2.0f;
    [self.bluetoothStatusImage startAnimating];
    
}

-(void)stopBLEScanAnimation {
    [self.bluetoothStatusImage stopAnimating];
    [self.bluetoothStatusImage setImage:[UIImage imageNamed:@"bluetooth_scan0.png"]];
    
}

-(void)setupTableViewSelectors:(BOOL)showOnlyActiveLocks {
    
    CGRect newFrame = self.statusAllLocks.frame;
    newFrame.size.height = showOnlyActiveLocks ? 1 : 2;
    newFrame.origin.y = self.allLocksLabel.frame.origin.y + self.allLocksLabel.frame.size.height + ( showOnlyActiveLocks ? 1: 0 );
    
    self.statusAllLocks.backgroundColor = showOnlyActiveLocks ? [self colorFmHex:0x92 greenPart:0xA8 bluePart:0xC1]: [self colorFmHex:0x06 greenPart:0x7A bluePart:0xB5];
    
    self.statusAllLocks.frame = newFrame;
    
    
    CGRect newFrame2 = self.statusActiveLocks.frame;
    newFrame2.size.height = showOnlyActiveLocks ? 2: 1;
    newFrame2.origin.y = self.activeLocksLabel.frame.origin.y + self.activeLocksLabel.frame.size.height + ( showOnlyActiveLocks ?  0: 1 );
    self.statusActiveLocks.backgroundColor = showOnlyActiveLocks ? [self colorFmHex:0x06 greenPart:0x7A bluePart:0xB5] : [self colorFmHex:0x92 greenPart:0xA8 bluePart:0xC1] ;
    
    self.statusActiveLocks.frame = newFrame2;
    
}

-(void)startFingerPrintAnimation {
    NSMutableArray *scanAnimations = [NSMutableArray array];
    for(int i = 1; i <= 10; ++i) {
        [scanAnimations addObject:[UIImage imageNamed:[NSString stringWithFormat:@"fingerprint_%d.png", i]]];
    }
    
    self.bioIDStatusImage.animationImages = scanAnimations;
    self.bioIDStatusImage.animationDuration = 2.0f;
    [self.bioIDStatusImage startAnimating];
}

-(void)stopFingerPrintAnimation {
    [self.bioIDStatusImage stopAnimating];
}

-(void)startLockAnimation {
    NSMutableArray *scanAnimations = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) {
        [scanAnimations addObject:[UIImage imageNamed:[NSString stringWithFormat:@"lock_%d.png", i]]];
    }
    
    [scanAnimations addObject:[UIImage imageNamed:@"lock_6.png"]];
    
    self.lockStatusImage.animationImages = scanAnimations;
    self.lockStatusImage.animationDuration = 2.0f;
    self.lockStatusImage.animationRepeatCount = 1;
    [self.lockStatusImage startAnimating];
}

-(void)resetCellAfterUnlock:(NSInteger)numberOfRaw {
    NSIndexPath *indexPath = [[NSIndexPath alloc]init];
    indexPath = [NSIndexPath indexPathForItem:numberOfRaw inSection:0];
    KnownDeviceTableCell *cell = [self.knownDevicesTable cellForRowAtIndexPath:indexPath];
    [cell resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
    
}

-(void)showActiveLocksCount:(NSInteger)count {
    if ( count == 0 )
        [self.activeLocksLabel setText:@"Active locks"];
    else
        [self.activeLocksLabel setText:[[NSString alloc] initWithFormat:@"Active locks (%ld)", (long)count]];
    
}

-(void)showAllLocksCount:(NSInteger)count {
    if ( count == 0 )
        [self.allLocksLabel setText:@"All locks"];
    else
        [self.allLocksLabel setText:[[NSString alloc] initWithFormat:@"All locks (%ld)", count]];
}

#pragma mark - View actions

-(void)onTableLocksViewModeChanged:(id)sender {
   
    NSLog(@"onTap: %ld", ((UITapGestureRecognizer *)sender).view.tag );
    [presenter selectTableViewMode:(int)((UITapGestureRecognizer *)sender).view.tag];
}

-(void)onScanBluetoothImage {
    [presenter changeScanModeBLE];
}

- (void)onDeleteButtonPressed:(NSInteger)numInDataRow {
    NSLog(@"delete button pressed %ld", (long)numInDataRow);
    [self showDeleteAlertForLock:numInDataRow];
}

- (void)onRenameButtonPressed:(NSInteger)numInDataRow {
    NSLog(@"rename button pressed %ld", (long)numInDataRow);
    [self showAlertWithInputNameForPeripheral:numInDataRow];
}

- (void)onUnlock:(NSInteger)numInDataRow {
    NSLog(@"unlock %ld", (long)numInDataRow);
    [presenter unlockDevice:numInDataRow];

}

#pragma mark - Work with View
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [presenter askForLocksCountForTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if ( indexPath.row < presenter.numberOfDispalyingLocks) {
        
           KnownDeviceTableCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"knownDeviceTableCell"];
            tableCell.numberOfDataRow = indexPath.row;
            tableCell.delegate = self;
            
            [tableCell.storedName setText:[presenter nameForLocK:indexPath.row]];
            [tableCell.storedName sizeToFit];
        
            [tableCell showRSSI:[presenter rssiForLock:indexPath.row]];
            [tableCell showBatteryLevel:[presenter batteryLevelForLock:indexPath.row]];
            
            //[tableCell.storedUUID setText:[presenter uuidForLock:indexPath.row]];
            //[tableCell.storedUUID sizeToFit];
        
            [tableCell.statusImage setImage:[UIImage imageNamed:[presenter statusNameForLock:indexPath.row]]];
        
            [tableCell setIsUnlockEnable:[presenter isUnlockAvailable:indexPath.row ]];
            
            cell = tableCell;

            
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

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



-(void)showAlertWithInputNameForPeripheral:(NSInteger)numberOfDataRow {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Input name for the lock" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = [presenter nameForLocK:numberOfDataRow];
        textField.placeholder = @"Name";
        textField.secureTextEntry = NO;
        
        
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [presenter storeName:[[alertController textFields][0] text] forLock:numberOfDataRow];
    }];
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canelled");
    }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)showDeleteAlertForLock:(NSInteger)numberOfDataRow {
  
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: [presenter nameForLocK:numberOfDataRow] message:@"Do you really want to forget this lock?"  preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [presenter forgetLock:numberOfDataRow];

    }];
    
    [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancelled");
    }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}



@end
