//
//  TL_documentAttributeAudio+Extension.m
//  Telegram
//
//  Created by keepcoder on 05/02/16.
//  Copyright © 2016 keepcoder. All rights reserved.
//

#import "TL_documentAttributeAudio+Extension.h"
#import "FileUtils.h"
@implementation TL_documentAttributeAudio (Extension)

-(NSArray*)arrayWaveform {
    
    NSMutableArray *decoded = [[NSMutableArray alloc] init];
    
    
    
    if(self.waveform.length > 0) {
        
        char bytes[63];
        
        
        [self.waveform getBytes:bytes length:self.waveform.length];
        
        
        int k = 0;
        
        for (int i = 0; i < self.waveform.length;) {
            
            int value = 0;
            
            NSString *binaryString = @"";
            
            
            for (int j = 0; j < 5; j++) {
                
                char byte = bytes[i];
                
                BOOL r = (byte >> k) & 1;
                
                value += r * pow(2, k);
                
                binaryString = [NSString stringWithFormat:@"%d%@",r,binaryString];
                
                k++;
                
                if(k == 8) {
                    i++;
                    k = 0;
                }
            }
            
            
            value = [FileUtils convertBinaryStringToDecimalNumber:binaryString];
            
            [decoded addObject:@(value)];
            
            if(decoded.count == 100) {
                break;
            }
            
        }
        
    }
    
    
    
    return decoded;
}



@end
