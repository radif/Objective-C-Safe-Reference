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
#import "SafeRefObject.h"

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
    
    SafeRefObject *obj=[SafeRefObject new];
    [obj registerSafeRef:&obj];
    SafeRefObject *obj1;
    [obj registerSafeRef:&obj1];
    SafeRefObject *obj2;
    [obj registerSafeRef:&obj2];
    SafeRefObject *obj3;
    [obj registerSafeRef:&obj3];
    SafeRefObject *obj4;
    [obj registerSafeRef:&obj4];
    
    
    
    
    NSLog(@"1: %@",obj1);
    NSLog(@"2: %@",obj2);
    NSLog(@"3: %@",obj3);
    NSLog(@"4: %@",obj4);
    
    [obj release];
    
    NSLog(@"1: %@",obj1);
    NSLog(@"2: %@",obj2);
    NSLog(@"3: %@",obj3);
    NSLog(@"4: %@",obj4);
}
int main(int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        // insert code here...
        
        printf("------Manual Safe Ref Example:\n");
        testManualSafeRefManagement();
        printf("\n\n------Automatic Safe Ref Example:\n");
        testAutomatedSafeRefManagement();
        
        
        
        
        
    }
    return 0;
}

