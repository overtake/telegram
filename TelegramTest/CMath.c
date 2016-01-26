//
//  CMath.c
//  TelegramTest
//
//  Created by keepcoder on 05.10.13.
//  Copyright (c) 2013 keepcoder. All rights reserved.
//

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
int gcd(int m, int n) {
    
    int t, r;
    
    if (m < n) {
        t = m;
        m = n;
        n = t;
    }
    
    r = m % n;
    
    if (r == 0) {
        return n;
    } else {
        return gcd(n, r);
    }
}



int uniqueElement(int first, int last, int exeption) {
    return first == exeption ? last : first;
}

long rand_long() {
    char bytes[8];
    arc4random_buf(bytes, 8);
    
    long rand;
    memcpy(&rand, bytes, 8);
    return rand;
}

int rand_int() {
    return abs(arc4random());
}

int rand_limit(int limit) {
    /* return a random number between 0 and limit inclusive.
     */
    if(limit < 0) return 0;
    int divisor = 0x7fffffff/(limit+1);
    int retval;
    
    do {
        retval = arc4random() / divisor;
    } while (retval > limit);
    
    return retval;
}

