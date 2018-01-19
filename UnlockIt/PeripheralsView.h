//
//  PeripheralsViewViewController.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 19.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralsView : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *peripheralTable;

@end
