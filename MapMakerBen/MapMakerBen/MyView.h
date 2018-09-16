//
//  MyView.h
//  MapMakerBen
//
//  Created by Benton Ferguson on 2018/07/20.
//  Copyright © 2018年 barely conscious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern int drawGrid;
@interface MyView : NSView
//@property (weak, nonatomic) IBOutlet
//@property (nonatomic) NSData *byteArray;
//@property (nonatomic) uint8_t[] bytearr;
@property (nonatomic) int selectorPositionX;
@property (nonatomic) int selectorPositionY;
@property (nonatomic) NSData *mapBytes;
//@property (nonatomic) String myString;
-(NSData*) getCurrentByteString;
-(void) setSelectorPos: (int)xPos yPosition:(int)yPos;
-(void) setByte: (int)byteNo assignValue:(u_int8_t)newval;
-(void) loadMapBytes: (u_int8_t[])bytevals;
-(u_int8_t) getByte: (int)byteNo;
-(void) drawTestLine;
-(void) setTestLine: (bool)drawLine;
-(void) InitializeByteArray;
//-(void)UpdateMap:(NSTimer*)timer;
@end
