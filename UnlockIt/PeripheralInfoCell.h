//
//  PeripheralInfoCell.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 19.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@end
