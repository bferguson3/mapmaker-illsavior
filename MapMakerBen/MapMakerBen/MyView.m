//
//  MyView.m
//  MapMakerBen
//
//  Created by Benton Ferguson on 2018/07/20.
//  Copyright © 2018年 barely conscious. All rights reserved.
//

#import "MyView.h"

//static int byteCount = 1024;
int drawGrid = 0;
@implementation MyView

int selectorPositionX;
int selectorPositionY;
//NSMutableData *FileData;
NSRect* mapWindow;
NSData *mapBytes;
NSString *myString;
uint8_t bytearr[1024];
bool testdrawgridvar = false;

-(void)loadMapBytes:(u_int8_t [])bytevals{
    for(int i = 0; i < 1024; i++){
        bytearr[i] = bytevals[i];
    }
    //drawRect();
    self.needsDisplay=true;
}

-(void)setSelectorPos:(int)xPos yPosition:(int)yPos{
    selectorPositionX=xPos;
    selectorPositionY=yPos;
}

- (void)setByte:(int)byteNo assignValue:(u_int8_t)newval {
    bytearr[byteNo]=newval;
}

-(void)InitializeByteArray{
    mapBytes = [NSData dataWithBytes:&bytearr length:1024];
}

- (u_int8_t)getByte:(int)byteNo {
    //bytearr[0] = 0x01;
    return bytearr[byteNo];
    //[FileData getBytes:bytearr range:NSMakeRange(byteNo,byteNo+1)];
    //uint8_t newBytes = (uint8_t)FileData.bytes;
    //return newBytes;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSRect myRect = NSMakeRect(0, 0, 256, 256);
    [[NSColor whiteColor] set];
    NSRectFill(myRect);
    //draw grid
    if(drawGrid==1){
        //First, draw the grid lines.
        NSBezierPath *path = [NSBezierPath bezierPath];
        [[NSColor blackColor] set];
        [path setLineWidth:0.1];
        for (int i = 1; i < 16; i++){
            [path moveToPoint:CGPointMake(16*i, 256)];
            [path lineToPoint:CGPointMake(16*i,0)];
            [path moveToPoint:CGPointMake(0,16*i)];
            [path lineToPoint:CGPointMake(256,16*i)];
        }
        [path stroke];
        [path stroke];
        
        //Draw selector
        NSBezierPath *pathSelector = [NSBezierPath bezierPath];
        [[NSColor orangeColor] set];
        [pathSelector setLineWidth:0.5];
        for (int i = 0; i < 2; i++){
            [pathSelector moveToPoint:CGPointMake(1+(selectorPositionX*16), 256-(i*16)-(selectorPositionY*16))];
            [pathSelector lineToPoint:CGPointMake(15+(selectorPositionX*16), 256-(i*16)-(selectorPositionY*16))];
            [pathSelector moveToPoint:CGPointMake((i*16)+(selectorPositionX*16), 255-(selectorPositionY*16))];
            [pathSelector lineToPoint:CGPointMake((i*16)+(selectorPositionX*16), 256-15-(selectorPositionY*16))];
        }
        [pathSelector stroke];
        [pathSelector stroke];
        
        //Now draw individual walls for every 4th byte
        NSBezierPath *pathWalls = [NSBezierPath bezierPath];
        [[NSColor blackColor] set];
        for (int i = 0; i < 16; i++){
            for (int y=0; y < 16; y++){
                if((bytearr[((y*16)+i)*4] & 0b00000001) == 0b00000001) {
                    //north
                    [pathWalls moveToPoint:CGPointMake(0+(i*16),256-(y*16)-1)];
                    [pathWalls lineToPoint:CGPointMake(16+(i*16),256-(y*16)-1)];
                }
                if((bytearr[((y*16)+i)*4] & 0b00001000) == 0b00001000) {
                    //west
                    [pathWalls moveToPoint:CGPointMake(0+(i*16)+1,256-(y*16))];
                    [pathWalls lineToPoint:CGPointMake(0+(i*16)+1,256-(y*16)-16)];
                }
                if((bytearr[((y*16)+i)*4] & 0b00000010) == 0b00000010) {
                    //east
                    [pathWalls moveToPoint:CGPointMake(16+(i*16)-1, 256-(y*16))];
                    [pathWalls lineToPoint:CGPointMake(16+(i*16)-1, 256-(y*16)-16)];
                }
                if((bytearr[((y*16)+i)*4] & 0b00000100) == 0b00000100) {
                    //south
                    [pathWalls moveToPoint:CGPointMake(0+(i*16), 256-(y*16)-16+1)];
                    [pathWalls lineToPoint:CGPointMake(16+(i*16), 256-(y*16)-16+1)];
                }
            }
        }
        [pathWalls stroke];
        [pathWalls stroke];
        //draw doors
        NSBezierPath *pathDoors = [NSBezierPath bezierPath];
        [[NSColor brownColor] set];
        for (int i = 0; i < 16; i++){
            for (int y=0; y < 16; y++){
                if((bytearr[((y*16)+i)*4] & 0b00010000) == 0b00010000) {
                    //north
                    [pathDoors moveToPoint:CGPointMake(0+(i*16)+4,256-(y*16)-2)];
                    [pathDoors lineToPoint:CGPointMake(16+(i*16)-4,256-(y*16)-2)];
                }
                if((bytearr[((y*16)+i)*4] & 0b10000000) == 0b10000000) {
                    //west
                    [pathDoors moveToPoint:CGPointMake(0+(i*16)+2,256-(y*16)-4)];
                    [pathDoors lineToPoint:CGPointMake(0+(i*16)+2,256-(y*16)-16+4)];
                }
                if((bytearr[((y*16)+i)*4] & 0b00100000) == 0b00100000) {
                    //east
                    [pathDoors moveToPoint:CGPointMake(16+(i*16)-2, 256-(y*16)-4)];
                    [pathDoors lineToPoint:CGPointMake(16+(i*16)-2, 256-(y*16)-16+4)];
                }
                if((bytearr[((y*16)+i)*4] & 0b01000000) == 0b01000000) {
                    //south
                    [pathDoors moveToPoint:CGPointMake(0+(i*16)+4, 256-(y*16)-16+2)];
                    [pathDoors lineToPoint:CGPointMake(16+(i*16)-4, 256-(y*16)-16+2)];
                }
            }
        }
        [pathDoors stroke];
        [pathDoors stroke];
        //?
        if(bytearr[0] == 0x01){
            [path moveToPoint:CGPointMake(0, 0)];
            [path lineToPoint:CGPointMake(256,256)];
            //[path stroke];
            //[path stroke];
        }
        
    }
}

-(NSData*) getCurrentByteString {
    mapBytes = [NSData dataWithBytes:&bytearr length:1024];
    //[myString release];
    return mapBytes;
}

-(void) setTestLine:(bool)drawLine{
    if(drawLine==true){
        testdrawgridvar=true;
    }
    else{
        testdrawgridvar=false;
    }
}

@end
