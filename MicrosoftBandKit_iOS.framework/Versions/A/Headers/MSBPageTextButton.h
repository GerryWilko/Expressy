//----------------------------------------------------------------
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//
//----------------------------------------------------------------

#import "MSBPageElement.h"

@interface MSBPageTextButton : MSBPageElement

@property (nonatomic, strong) MSBColor *pressedColor;
@property (nonatomic, assign) MSBPageElementColorSource pressedColorSource;

- (id)initWithRect:(MSBPageRect *)rect;

@end
