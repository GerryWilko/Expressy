//----------------------------------------------------------------
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//
//----------------------------------------------------------------

#import "MSBPageElementData.h"

@interface MSBPageWrappedTextBlockData : MSBPageElementData

@property (nonatomic, readonly) NSString  *text;

+ (MSBPageWrappedTextBlockData *)pageWrappedTextBlockDataWithElementId:(MSBPageElementIdentifier)elementId text:(NSString *)text error:(NSError **)pError;

@end
