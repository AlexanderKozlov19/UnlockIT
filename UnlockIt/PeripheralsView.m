//
//  PeripheralsViewViewController.m
//  UnlockIt
//
//  Created by Alexander Kozlov on 19.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "PeripheralsView.h"
#import "BluetoothModule.h"
#import "PeripheralInfoCell.h"

@interface PeripheralsView ()

@end

@implementation PeripheralsView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripheralTable.dataSource = self;
    self.peripheralTable.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onDiscoverPeripheral:)
                                                 name: @"DiscoverPeripheral"
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onUpdateRSSI:)
                                                 name: @"UpdateRSSI"
                                               object: nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onDiscoverPeripheral:(NSNotification *)data {
    [self.peripheralTable reloadData];
}

-(void)onUpdateRSSI:(NSNotification *)data {
    
    CBPeripheral *peripheral = data.object;
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
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[BluetoothModule SharedBluetoothModule] peripheralsBLE] count];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    return 1;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     UITableViewCell *tableCell = nil;
    
    if ( indexPath.row == 0 ) {
        NSMutableDictionary *peripheralDict = [[[BluetoothModule SharedBluetoothModule] peripheralsBLE] objectAtIndex:indexPath.section];
        CBPeripheral *peripheral = peripheralDict[@"CBPeripheral"];
        PeripheralInfoCell *tableCellInfo = [tableView dequeueReusableCellWithIdentifier:@"peripheralInfoCell"];
        
        [tableCellInfo.nameLabel setText:peripheral.name];
        [tableCellInfo.nameLabel sizeToFit];
        
        [tableCellInfo.uuidLabel setText:peripheral.identifier.UUIDString];
        [tableCellInfo.uuidLabel sizeToFit];
        
        NSNumber *rssi = [peripheralDict objectForKey:@"RSSI"];
        if ( rssi == nil )
            [tableCellInfo.rssiLabel setText:@""];
        else
            [tableCellInfo.rssiLabel setText:[NSString stringWithFormat:@"%@ rssi", rssi]];

        [tableCellInfo.rssiLabel sizeToFit];
        
        tableCell = tableCellInfo;
    }

    return tableCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat fHeight = 0;
    
    if ( indexPath.row == 0 ) {
       PeripheralInfoCell *tableCellInfo = [tableView dequeueReusableCellWithIdentifier:@"peripheralInfoCell"];
       fHeight = tableCellInfo.contentView.bounds.size.height;
    }
    
    return fHeight;
}

/*

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
    
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
    
}

- (void)setNeedsFocusUpdate {
   
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    
}

- (void)updateFocusIfNeeded {
    
}
*/
@end
