//
//  MAParanoidAllocator_Tests.m
//  MAParanoidAllocator Tests
//
//  Created by Michael Ash on 4/15/14.
//  Copyright (c) 2014 mikeash. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MAParanoidAllocator.h"


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

@end
