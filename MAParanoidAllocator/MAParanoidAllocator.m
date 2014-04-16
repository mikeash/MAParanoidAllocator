//
//  MAParanoidAllocator.m
//  MAParanoidAllocator
//
//  Created by Michael Ash on 4/15/14.
//  Copyright (c) 2014 mikeash. All rights reserved.
//

#import "MAParanoidAllocator.h"


#define CHECK(x, failureCase) do { \
        if((x) failureCase) { \
            NSLog(@"%s: %s (%d)", #x, strerror(errno), errno); \
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
        _pageSize = sysconf(_SC_PAGESIZE);
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
            CHECK(afterPointer = mmap(NULL, afterSize, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, 0, 0), == MAP_FAILED);
        }
        
        if(beforeSize > 0 && afterSize > 0) {
            [self read: ^(const void *ptr) {
                memcpy(afterPointer, ptr, MIN(beforeSize, afterSize));
            }];
        }
        
        if(beforeSize > 0) {
            CHECK(munmap(_memory, beforeSize), < 0);
        }
        
        _memory = afterPointer;
    }
    
    _size = size;
}

- (size_t)roundToPageSize: (size_t)size {
    size_t pageCount = (size + _pageSize - 1) / _pageSize;
    return pageCount * _pageSize;
}

- (void)read: (void (^)(const void *))block {
    block(_memory);
}

- (void)write: (void (^)(void *))block {
    block(_memory);
}

@end
