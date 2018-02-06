//
//  KnownDeviceTableCell.h
//  UnlockIt
//
//  Created by Alexander Kozlov on 22.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwipeableCellDelegate <NSObject>
- (void)onDeleteButtonPressed:(NSInteger)numInDataRow;
- (void)onRenameButtonPressed:(NSInteger)numInDataRow;
- (void)onUnlock:(NSInteger)numInDataRow;
- (void)onBrightnessIncreasePressed:(NSInteger)numInDataRow;
- (void)onBrightnessDecreasePressed:(NSInteger)numInDataRow;
@end

@interface KnownDeviceTableCell : UITableViewCell <UIGestureRecognizerDelegate>
@property (nonatomic, weak) id <SwipeableCellDelegate> delegate;

- (IBAction)buttonClicked:(id)sender;

- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing;

@property (nonatomic, assign) NSInteger numberOfDataRow;

@property (weak, nonatomic) IBOutlet UILabel *storedName;

@property (weak, nonatomic) IBOutlet UIView *cellContentView;
@property (weak, nonatomic) IBOutlet UILabel *storedUUID;
@property (weak, nonatomic) IBOutlet UIButton *buttonRename;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintRight;
@property (weak, nonatomic) IBOutlet UILabel *labelUnlock;
@property (weak, nonatomic) IBOutlet UIButton *buttonVolumeIncrease;
@property (weak, nonatomic) IBOutlet UIButton *buttonVolumeDecrease;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UIImageView *batteryLevelImage;
@property (weak, nonatomic) IBOutlet UIImageView *levelImage;
@property (weak, nonatomic) IBOutlet UIImageView *batteryLevelInside;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelPercentage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *batteryLevel;
@property (weak, nonatomic) IBOutlet UILabel *brightnessLabel;



@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint panStartPoint;
@property (nonatomic, assign) CGFloat startingRightConstraint;
@property (nonatomic, assign) CGFloat startingLeftConstraint;
@property (nonatomic, assign) int initialState;

@property (nonatomic, assign) BOOL isPanning;
@property (nonatomic, assign) BOOL isUnlockEnable;

-(void)showRSSI:(NSInteger)level;
-(void)showBatteryLevel:(NSInteger)level;
-(void)showBrightnessControl:(BOOL)show;

@end
