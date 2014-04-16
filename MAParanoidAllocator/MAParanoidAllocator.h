//
//  MAParanoidAllocator.h
//  MAParanoidAllocator
//
//  Created by Michael Ash on 4/15/14.
//  Copyright (c) 2014 mikeash. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAParanoidAllocator : NSObject

- (id)init;
- (id)initWithSize: (size_t)size;

- (size_t)size;
- (void)setSize: (size_t)size;

- (void)read: (void (^)(const void *ptr))block;
- (void)write: (void (^)(void *ptr))block;

@end
