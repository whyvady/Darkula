#pragma once
#import <UIKit/UIKit.h>
FOUNDATION_EXTERN BOOL DKProcessEnabled(void);
FOUNDATION_EXTERN BOOL DKIsPrivateObject(id object);
FOUNDATION_EXTERN BOOL DKIsSolidColor(UIColor *color);
FOUNDATION_EXTERN BOOL DKIsLightGray(UIColor *color);
FOUNDATION_EXTERN BOOL DKIsUniformText(NSAttributedString *text);
FOUNDATION_EXTERN UIColor *DKBackgroundColor(UIColor *color);
FOUNDATION_EXTERN UIColor *DKTextColor(UIColor *color);
FOUNDATION_EXTERN UIColor *DKSeparatorColor(void);
FOUNDATION_EXTERN UIColor *DKSelectionColor(void);
