//
//  WeakSafeObject.m
//
//
//  Created by Radif Sharafullin on 3/7/12.
//  Copyright (c) 2012 Radif Sharafullin. All rights reserved.
//
// Released under MIT license

#import "SafeRefObject.h"
#import "rsSafeRefSystem.h"

@implementation SafeRefObject
-(void)registerSafeRef:(id *)ref{
    rs_storeSafeRef(ref, self);
}
-(void)dealloc{
    rs_nullSafeRef(self);
    [super dealloc];
}
@end
