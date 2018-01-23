//
//  KnownDeviceTableCell.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 22.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KnownDeviceTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *storedName;

@property (weak, nonatomic) IBOutlet UILabel *storedUUID;

@end
