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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    automaticStartScanForBLE = true;    // later will be stored in NSUserDefaults
    
    presenter = [[MainViewPresenter alloc] init];
    [presenter setView:self];
    
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(onManagerDidUpdateState:)
                                                 name: @"ManagerUpdateState"
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
    
    if ( state && automaticStartScanForBLE )
        [self startScan];
       
}

-(void)startScan {
    [self performSegueWithIdentifier:@"SegueToPeripheralView" sender:self];
    
    [[BluetoothModule SharedBluetoothModule] startScan];
    
    
    
}

-(void)stopScan {
    [[BluetoothModule SharedBluetoothModule] stopScan];
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue sender:(id)sender {
    [self stopScan];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ( [segue.identifier  isEqual: @"SegueToPeripheralView"] )
        [[BluetoothModule SharedBluetoothModule] startScan];

}

@end
