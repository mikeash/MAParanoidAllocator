//
//  MAParanoidAllocator_Tests.m
//  MAParanoidAllocator Tests
//
//  Created by Michael Ash on 4/15/14.
//  Copyright (c) 2014 mikeash. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MAParanoidAllocator.h"

#import <mach/mach_vm.h>


@interface MAParanoidAllocator_Tests : XCTestCase

@end

@implementation MAParanoidAllocator_Tests

- (void)testSizes {
    MAParanoidAllocator *allocator = [[MAParanoidAllocator alloc] init];
    XCTAssertEqual([allocator size], (size_t)0, @"Unexpected size for freshly allocated allocator");
    [allocator setSize: 42];
    XCTAssertEqual([allocator size], (size_t)42, @"Unexpected size after resizing allocator");
    [allocator setSize: 99999];
    XCTAssertEqual([allocator size], (size_t)99999, @"Unexpected size after resizing allocator");
}

- (void)testAccess {
    MAParanoidAllocator *allocator = [[MAParanoidAllocator alloc] initWithSize: 1];
    [allocator read: ^(const void *ptr) {
        XCTAssertEqual(*(const char *)ptr, (char)0, @"Newly allocated memory should be empty");
    }];
    [allocator write: ^(void *ptr) {
        *(char *)ptr = 1;
    }];
    [allocator read: ^(const void *ptr) {
        XCTAssertEqual(*(const char *)ptr, (char)1, @"Memory write didn't show up");
    }];
}

static int Read(const void *ptr) {
    unsigned char data;
    mach_msg_type_number_t count;
    kern_return_t ret;
    
    ret = mach_vm_read(mach_task_self(), (mach_vm_address_t)ptr, 1, (vm_offset_t *)&data, &count);
    
    if(ret != KERN_SUCCESS) {
        return -1;
    }
    
    return data;
}

static BOOL Write(void *ptr, char value) {
    kern_return_t ret = mach_vm_write(mach_task_self(), (mach_vm_address_t)ptr, (vm_offset_t)&value, 1);
    return ret == KERN_SUCCESS;
}

- (void)testWriteProtection {
    MAParanoidAllocator *allocator = [[MAParanoidAllocator alloc] initWithSize: 1];
    [allocator read: ^(const void *ptr) {
        XCTAssertEqual(Read(ptr), 0, @"Didn't get the expected value from a fresh allocator");
        XCTAssertFalse(Write((void *)ptr, 1), @"Shouldn't be able to write to read-only pointer");
    }];
}

@end
