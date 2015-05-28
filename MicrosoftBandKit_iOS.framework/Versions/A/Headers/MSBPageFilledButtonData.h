//----------------------------------------------------------------
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//
//----------------------------------------------------------------

#import "MSBPageElementData.h"

@interface MSBPageFilledButtonData : MSBPageElementData

@property (nonatomic, strong) MSBColor *pressedColor;

+ (MSBPageFilledButtonData *)pageFilledButtonDataWithElementId:(MSBPageElementIdentifier)elementId;

@end
