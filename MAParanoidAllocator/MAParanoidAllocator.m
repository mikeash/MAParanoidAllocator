//
//  MAParanoidAllocator.m
//  MAParanoidAllocator
//
//  Created by Michael Ash on 4/15/14.
//  Copyright (c) 2014 mikeash. All rights reserved.
//

#import "MAParanoidAllocator.h"

@implementation MAParanoidAllocator {
    size_t _size;
}

- (id)init {
    return [super init];
}

- (id)initWithSize: (size_t)size {
    self = [self init];
    [self setSize: size];
    return self;
}

- (size_t)size {
    return _size;
}

- (void)setSize: (size_t)size {
    _size = size;
}

@end
