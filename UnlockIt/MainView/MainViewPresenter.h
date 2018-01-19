//
//  MainViewPresenter.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MainViewController.h"
#import "ViewControllerProtocol.h"

@interface MainViewPresenter : NSObject

@property (weak, nonatomic)  id <ViewControllerProtocol> view;

-(void)onBluetoothState:(NSNumber*)data;

@end
