//
//  rsSafeRefSystem.c
//
//
//  Created by Radif Sharafullin on 3/7/12.
//  Copyright (c) 2012 Radif Sharafullin. All rights reserved.
//
// Released under MIT license

#include "rsSafeRefSystem.h"
#import <objc/runtime.h>

typedef struct __rs_safe_ref{
    id *object;
    id value;
    uint tag;
} __rs_safe_ref;

typedef struct __rs_safe_array {
    size_t num, max;
    struct __rs_safe_ref *refs;
} __rs_safe_array;



static inline void _rs_safeRefArrayDoubleCapacity(__rs_safe_array *arr){
	arr->max *= 2;
	arr->refs = (__rs_safe_ref*) realloc( arr->refs, arr->max * sizeof(__rs_safe_ref) );
}

static inline void _rs_safeRefArrayEnsureExtraCapacity(__rs_safe_array *safeRefArray, size_t extra){
	while (safeRefArray->max < safeRefArray->num + extra)
		_rs_safeRefArrayDoubleCapacity(safeRefArray);
}

static inline void _rs_safeRefArrayAppendObject(__rs_safe_array *safeRefArray, __rs_safe_ref ref){
	safeRefArray->refs[safeRefArray->num] = ref;
	safeRefArray->num++;
}

static inline void rs_safeRefArrayAppendObjectWithResize(__rs_safe_array *safeRefArray, __rs_safe_ref ref)
{
	_rs_safeRefArrayEnsureExtraCapacity(safeRefArray, 1);
	_rs_safeRefArrayAppendObject(safeRefArray, ref);
}

static inline void rs_safeRefArrayRemoveObjectAtIndex(__rs_safe_array *safeRefArray, size_t index){
	safeRefArray->num--;
	int remaining = safeRefArray->num - index;
	if(remaining>0)
		memmove(&safeRefArray->refs[index], &safeRefArray->refs[index+1], remaining * sizeof(__rs_safe_ref));
}



static inline __rs_safe_array* rs_safeRefArrayNew(size_t max_capacity) {
	if (max_capacity == 0)
		max_capacity = 1; 
	
	__rs_safe_array *safeRefArray = (__rs_safe_array*)malloc( sizeof(__rs_safe_array) );
	safeRefArray->num = 0;
	safeRefArray->refs =  (__rs_safe_ref*) malloc( max_capacity * sizeof(__rs_safe_ref) );
	safeRefArray->max = max_capacity;
	return safeRefArray;
}


static inline void rs_safeRefArrayFree(__rs_safe_array *safeRefArray){
	if(!safeRefArray) return;
	free(safeRefArray->refs);
	free(safeRefArray);
}

static __rs_safe_array *__refs;

static void beginSafeRefArray(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __refs=__refs?__refs:rs_safeRefArrayNew(1);
    });
}

id rs_storeSafeRef(id *object, id value){
    
    
    beginSafeRefArray();
    
    if (!value) return nil;
    dispatch_queue_t q=dispatch_queue_create("com.objcSafeRef.storeSafeRef", NULL);    
    dispatch_sync(q, ^{
        
        __rs_safe_ref ref;
        ref.object=object;
        ref.value=value;
        rs_safeRefArrayAppendObjectWithResize(__refs,ref);
        
        *object=value;
    });
    dispatch_release(q);
    
    return *object;
}

id rs_registerSafeRef(id *object){
    
    return rs_storeSafeRef(object, *object);
}

void rs_nullSafeRef(id value){
    beginSafeRefArray();
    if (!value) return;
    
    
    __block __rs_safe_array *removed_tags=rs_safeRefArrayNew(1);
    dispatch_queue_t q=dispatch_queue_create("com.objcSafeRef.nullSafeRef", NULL);    
    dispatch_apply(__refs->num, q, ^(size_t index){ 
        
        if (__refs->refs[index].value==value) {
            id *object=__refs->refs[index].object;
            *object=nil;
            __rs_safe_ref tag;
            tag.tag=index;
            rs_safeRefArrayAppendObjectWithResize(removed_tags, tag);
        }
        
    });
    dispatch_release(q);
    
    q=dispatch_queue_create("com.objcSafeRef.nullSafeRefP2", NULL);    
    dispatch_apply(removed_tags->num, q, ^(size_t index){ 
        rs_safeRefArrayRemoveObjectAtIndex(__refs, removed_tags->refs[index].tag);
    });
    dispatch_release(q);
    
}
void __safe_ref_method_swizzle(Class c, SEL orig, SEL new){
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}
static IMP deallocFunctionIMP=nil;
@implementation NSObject (SafeRef)

-(void)registerSafeRef:(id *)ref{
    rs_storeSafeRef(ref, self);
    static dispatch_once_t registerSafeRefOnceToken;
    dispatch_once(&registerSafeRefOnceToken, ^{
        deallocFunctionIMP=[NSObject instanceMethodForSelector:@selector(dealloc)];
        __safe_ref_method_swizzle([NSObject class],@selector(dealloc),@selector(nullSafeRefsAndDealloc));
    });
    
    //isSwizzled=TRUE;
}

-(void)nullSafeRefsAndDealloc{
    rs_nullSafeRef(self);
    deallocFunctionIMP(self,@selector(dealloc));
}
@end
