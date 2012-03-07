//
//  cdaWeakSystem.h
//
//
//  Created by Radif Sharafullin on 3/7/12.
//  Copyright (c) 2012 Radif Sharafullin. All rights reserved.
//
// Released under MIT license

#import <Foundation/Foundation.h>


id rs_storeSafeRef(id *object, id value);
id rs_registerSafeRef(id *object);
void rs_nullSafeRef(id value);

