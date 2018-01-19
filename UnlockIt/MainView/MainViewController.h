//
//  ViewController.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewControllerProtocol.h"

@interface MainViewController : UIViewController <ViewControllerProtocol>

-(void)updateBluetoothState:(BOOL)state withText:(NSString*)stateText;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

-(void)startScan;
-(void)stopScan;


@end

