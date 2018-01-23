//
//  KnownDeviceTableCell.m
//  UnlockIt
//
//  Created by Alexander Kozlov on 22.01.2018.
//  Copyright © 2018 eCozy. All rights reserved.
//

#import "KnownDeviceTableCell.h"

@implementation KnownDeviceTableCell

static CGFloat const kBounceValue = 20.0f;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.cellContentView addGestureRecognizer:self.panRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonClicked:(id)sender {
    if (sender == self.buttonDelete) {
        [self.delegate onDeleteButtonPressed:self.numberOfDataRow];
    } else if (sender == self.buttonRename) {
        [self.delegate onRenameButtonPressed:self.numberOfDataRow];
    } 
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self resetConstraintContstantsToZero:NO notifyDelegateDidClose:NO];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)panThisCell:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.panStartPoint = [recognizer translationInView:self.cellContentView];
            self.startingRightConstraint = self.contraintRight.constant;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint currentPoint = [recognizer translationInView:self.cellContentView];
            CGFloat deltaX = currentPoint.x - self.panStartPoint.x;
            BOOL panningLeft = NO;
            if (currentPoint.x < self.panStartPoint.x) {
                panningLeft = YES;
                if (self.startingRightConstraint == 0) {
                    //The cell was closed and is now opening
                    if (!panningLeft) {
                        CGFloat constant = MAX(-deltaX, 0); //3
                        if (constant == 0) { //4
                            [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                        } else { //5
                            self.contraintRight.constant = constant;
                        }
                    } else {
                        CGFloat constant = MIN(-deltaX, [self buttonTotalWidth]); //6
                        if (constant == [self buttonTotalWidth]) { //7
                            [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                        } else { //8
                            self.contraintRight.constant = constant;
                        }
                    }
                }
            }
            else {
                //The cell was at least partially open.
                CGFloat adjustment = self.startingRightConstraint - deltaX; //1
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0); //2
                    if (constant == 0) { //3
                        [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:NO];
                    } else { //4
                        self.contraintRight.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]); //5
                    if (constant == [self buttonTotalWidth]) { //6
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else { //7
                        self.contraintRight.constant = constant;
                    }
                }
            }
            
            self.constraintLeft.constant = -self.contraintRight.constant; //8

        }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.startingRightConstraint == 0) { //1
                //Cell was opening
                CGFloat halfOfButtonOne = CGRectGetWidth(self.buttonRename.frame) / 2; //2
                if (self.contraintRight.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            } else {
                //Cell was closing
                CGFloat buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.buttonRename.frame) + (CGRectGetWidth(self.buttonDelete.frame) / 2); //4
                if (self.contraintRight.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.contraintRight == 0) {
                //Cell was closed - reset everything to 0
                [self resetConstraintContstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //Cell was open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        default:
            break;
    }
}

- (CGFloat)buttonTotalWidth {
    return CGRectGetWidth(self.frame) - CGRectGetMinX(self.buttonRename.frame);
}
            
- (void)resetConstraintContstantsToZero:(BOOL)animated notifyDelegateDidClose:(BOOL)endEditing {
    if (self.startingRightConstraint == 0 &&
        self.contraintRight.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contraintRight.constant = -kBounceValue;
    self.constraintLeft.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contraintRight.constant = 0;
        self.constraintLeft.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightConstraint = self.contraintRight.constant;
        }];
    }];
}
            
- (void)setConstraintsToShowAllButtons:(BOOL)animated notifyDelegateDidOpen:(BOOL)notifyDelegate {
    if (self.startingRightConstraint == [self buttonTotalWidth] &&
        self.contraintRight.constant == [self buttonTotalWidth]) {
        return;
    }
    //2
    self.constraintLeft.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contraintRight.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        //3
        self.contraintRight.constant = -[self buttonTotalWidth];
        self.contraintRight.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            //4
            self.startingRightConstraint = self.contraintRight.constant;
        }];
    }];
}

- (void)updateConstraintsIfNeeded:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    float duration = 0;
    if (animated) {
        duration = 0.1;
    }
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:completion];
}
@end
