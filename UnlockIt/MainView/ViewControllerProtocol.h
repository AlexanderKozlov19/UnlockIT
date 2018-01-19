//
//  ViewControllerProtocol.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 18.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ViewControllerProtocol <NSObject>

-(void)updateBluetoothState:(BOOL)state withText:(NSString*)stateText;


@end
