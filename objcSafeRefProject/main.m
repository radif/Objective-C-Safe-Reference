//
//  main.m
//
//
//  Created by Radif Sharafullin on 3/7/12.
//  Copyright (c) 2012 Radif Sharafullin. All rights reserved.
//
// Released under MIT license

#import <Foundation/Foundation.h>
#import "rsSafeRefSystem.h"

void testManualSafeRefManagement(){
    NSString *str=@"SampleString";
    NSString *ss=str;
    NSString *ss2=str;
    NSString *ss3=str;
    NSString *ss4=str;
    NSString *ss5=str;
    
    
    rs_registerSafeRef(&ss);
    rs_registerSafeRef(&ss2);
    rs_registerSafeRef(&ss3);
    rs_registerSafeRef(&ss4);
    rs_registerSafeRef(&ss5);
    
    NSLog(@"1: %@",ss);
    NSLog(@"2: %@",ss2);
    NSLog(@"3: %@",ss3);
    NSLog(@"4: %@",ss4);
    NSLog(@"5: %@",ss5);
    
    
    
    rs_nullSafeRef(ss);
    
    NSLog(@"1: %@",ss);
    NSLog(@"2: %@",ss2);
    NSLog(@"3: %@",ss3);
    NSLog(@"4: %@",ss4);
    NSLog(@"5: %@",ss5);
    
    NSLog(@"original: %@",str);
}
void testAutomatedSafeRefManagement(){
    
//#define x a <-- b x a;[b registerWeakRef:a]
    NSArray *obj=[[NSArray alloc] initWithObjects:@"obj",@"key", nil];
    
    safeRefSelf(obj);
    
    safeRefNew(NSArray *, obj1, obj);
    safeRefNew(NSArray *, obj2, obj);
    safeRefNew(NSArray *, obj3, obj);
    safeRefNew(NSArray *, obj4, obj);
    safeRefNew(NSArray *, copy2, obj);

    NSLog(@"1: %@",obj);
    NSLog(@"1: %@",obj1);
    NSLog(@"2: %@",obj2);
    NSLog(@"3: %@",obj3);
    NSLog(@"4: %@",obj4);
    NSLog(@"4: %@",copy2);
    
    [obj release];
    
    NSLog(@"1: %@",obj);
    NSLog(@"1: %@",obj1);
    NSLog(@"2: %@",obj2);
    NSLog(@"3: %@",obj3);
    NSLog(@"4: %@",obj4);
    NSLog(@"4: %@",copy2);
}
int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        // insert code here...
        
        printf("------Manual Safe Ref Example:\n");
        //for toll free bridged object (NSString, NSDictionary, etc)
        testManualSafeRefManagement();
        printf("\n\n------Automatic Safe Ref Example:\n");
        testAutomatedSafeRefManagement();
        testAutomatedSafeRefManagement();
        testAutomatedSafeRefManagement();
        
        
        
    
        
        
        
    }
    return 0;
}

