//
//  MAParanoidAllocator.m
//  MAParanoidAllocator
//
//  Created by Michael Ash on 4/15/14.
//  Copyright (c) 2014 mikeash. All rights reserved.
//

#import "MAParanoidAllocator.h"


#define CHECK(condition) do { \
        if(!(condition)) { \
            NSLog(@"%s: %s (%d)", #condition, strerror(errno), errno); \
            abort(); \
        } \
    } while(0)

@implementation MAParanoidAllocator {
    size_t _size;
    char *_memory;
    size_t _pageSize;
}

- (id)init {
    if((self = [super init])) {
        CHECK((_pageSize = sysconf(_SC_PAGESIZE)) > 0);
    }
    return self;
}

- (id)initWithSize: (size_t)size {
    self = [self init];
    [self setSize: size];
    return self;
}

- (void)dealloc {
    [self setSize: 0];
}

- (size_t)size {
    return _size;
}

- (void)setSize: (size_t)size {
    size_t beforeSize = [self roundToPageSize: _size];
    size_t afterSize = [self roundToPageSize: size];
    
    if(beforeSize != afterSize) {
        char *afterPointer = NULL;
        if(afterSize > 0) {
            size_t guardPagesSize = _pageSize * 2;
            size_t toAllocate = afterSize + guardPagesSize;
            char *allocatedPointer;
            CHECK((allocatedPointer = mmap(NULL, toAllocate, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, 0, 0)) != MAP_FAILED);
            
            afterPointer = allocatedPointer + _pageSize;
            
            CHECK(mprotect(allocatedPointer, _pageSize, PROT_NONE) == 0);
            CHECK(mprotect(afterPointer + afterSize, _pageSize, PROT_NONE) == 0);
        }
        
        if(beforeSize > 0 && afterSize > 0) {
            [self read: ^(const void *ptr) {
                memcpy(afterPointer, ptr, MIN(beforeSize, afterSize));
            }];
        }
        
        if(beforeSize > 0) {
            [self write: ^(void *ptr) {
                memset(ptr, 0, beforeSize);
            }];
            size_t guardPagesSize = _pageSize * 2;
            size_t toDeallocate = beforeSize + guardPagesSize;
            char *pointerWithGuards = _memory - _pageSize;
            CHECK(munmap(pointerWithGuards, toDeallocate) == 0);
        }
        
        _memory = afterPointer;
        _size = size;
        
        [self mprotect: PROT_NONE];
    } else {
        _size = size;
    }
}

- (void)read: (void (^)(const void *))block {
    [self withProtections: PROT_READ call: ^{
        block(_memory);
    }];
}

- (void)write: (void (^)(void *))block {
    [self withProtections: PROT_READ | PROT_WRITE call: ^{
        block(_memory);
    }];
}

- (size_t)roundToPageSize: (size_t)size {
    size_t pageCount = (size + _pageSize - 1) / _pageSize;
    return pageCount * _pageSize;
}

- (void)mprotect: (int)prot {
    size_t size = [self roundToPageSize: _size];
    if(size > 0) {
        CHECK(mprotect(_memory, size, prot) == 0);
    }
}

- (void)withProtections: (int)prot call: (void (^)(void))block {
    [self mprotect: prot];
    block();
    [self mprotect: PROT_NONE];
}

@end
