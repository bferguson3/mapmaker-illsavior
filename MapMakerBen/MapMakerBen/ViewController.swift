//
//  ViewController.swift
//  MapMakerBen
//
//  Created by Benton Ferguson on 2018/07/20.
//  Copyright © 2018年 barely conscious. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    //uint8_t loadeddata[1024];
    //uint8_t loadedbytes[1024]
    
    @IBOutlet var mapDraw: MyView!
    
    @IBAction func loadFile(_ sender: NSButton) {
        var loadfilename=filenameField.stringValue
        var loadeddata = NSData()
        if (loadfilename == ""){
            loadfilename = filenameField.placeholderString!
        }
        loadfilename = loadfilename + ".bin"
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first! as NSString {
            let path = dir.appendingPathComponent(loadfilename);
            
            //reading
            do {
                loadeddata = try NSData(contentsOfFile: path)
                //loadeddata = try NSString(contentsOfFile: path, encoding: String.Encoding.ascii.rawValue) as String
                //debugPrint(loadeddata)
                processMapString(inputstr: loadeddata)
            }
            catch {
                /* error handling here */
            }
        }
        filenameField.isEnabled = false
    }
    @IBAction func renameButtonClick(_ sender: NSButton) {
        filenameField.isEnabled=true
        filenameField.becomeFirstResponder()
    }
    @IBAction func clickButton(_ sender: NSButton) {
        
        newMap()
        filenameField.isEnabled = false
        filenameField.stringValue=""
    }
    @IBAction func saveMap(_ sender: NSButton) {
        writeDataToFile()
        filenameField.isEnabled = false
    }
    
    @IBOutlet weak var debugLabel: NSTextField!
    public var bytearr2 : [UInt8] = [UInt8?](repeating: 0x00, count: 1024) as! [UInt8]
    var currentX=0
    var currentY=0
    var monitor: Any?
    var keyPressed = ""
    enum brushTypes {
        case wall
        case door
    }
    var brush = brushTypes.wall
    
    func processMapString(inputstr: NSData){
        var c = 0
        while c < 1024 {
            bytearr2[c]=0x00
            c = c+1
        }
        //let [bytearr2]:[UInt8]
        //debugPrint(bytearr2.count)
        inputstr.getBytes(&bytearr2, range: NSMakeRange(0,1024))
        //debugPrint(bytearr2[0])
        mapDraw.loadMapBytes(&bytearr2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown, handler: myKeyDownEvent)
        mapDraw.initializeByteArray()
        updateDraw()
    }
    override func viewWillDisappear() {
        if let monitor = self.monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    func myKeyDownEvent(event: NSEvent) -> NSEvent {
        if(filenameField.isEnabled==false){
        
        var targetByte = ((currentY*16)+currentX)*4
        if event.keyCode == 36{ //0x24
            mapDraw.setByte(0, assignValue: 0x01)
            mapDraw.setSelectorPos(4, yPosition: 4)
            updateDraw()
            
        }
        else if event.keyCode == 0x7c {
            currentX+=1
            if(currentX>15){
                currentX=0
            }
            targetByte = ((currentY*16)+currentX)*4
        //
        }
        else if event.keyCode == 0x7d { //down arrwo
            currentY+=1
            if(currentY>15){
                currentY=0
            }
            targetByte = ((currentY*16)+currentX)*4
          
        }
        else if event.keyCode == 0x7b { //left
            currentX-=1
            if(currentX<0){
                currentX=15
            }
            targetByte = ((currentY*16)+currentX)*4
        }
        else if event.keyCode == 0x7e { //up
            currentY-=1
            if(currentY<0){
                currentY=15
            }
            targetByte = ((currentY*16)+currentX)*4
        }
        else if event.keyCode == 0x0d {// "w"
            if( brush == brushTypes.wall){
                let outputBits = mapDraw.getByte(Int32(targetByte)) ^ 0b00000001
                mapDraw.setByte(Int32(targetByte), assignValue: outputBits)
            }
            else if ( brush == brushTypes.door){
                let outputBits = mapDraw.getByte(Int32(targetByte)) ^ 0b00010000
                mapDraw.setByte(Int32(targetByte), assignValue: outputBits)
            }
        }
        else if event.keyCode == 0x00 { //"a"
            if ( brush == brushTypes.wall){
                let outputBits = mapDraw.getByte(Int32(targetByte)) ^ 0b00001000
                mapDraw.setByte(Int32(targetByte), assignValue: outputBits)
            }
            else if ( brush == brushTypes.door){
                let outputBits = mapDraw.getByte(Int32(targetByte)) ^ 0b10000000
                mapDraw.setByte(Int32(targetByte), assignValue: outputBits)
                //debugPrint(mapDraw.getByte(Int32(targetByte)))
            }
        }
        else if event.keyCode == 0x01 { //"s"
            if (brush == brushTypes.wall){
                let outputBits = mapDraw.getByte(Int32(targetByte)) ^ 0b00000100
                mapDraw.setByte(Int32(targetByte), assignValue: outputBits)
            }
            else if ( brush == brushTypes.door){
                let outputBits = mapDraw.getByte(Int32(targetByte)) ^ 0b01000000
                mapDraw.setByte(Int32(targetByte), assignValue: outputBits)
            }
        }
        else if event.keyCode == 0x02 { //"d"
            if (brush == brushTypes.wall){
                let outputBits = mapDraw.getByte(Int32(targetByte)) ^ 0b00000010
                mapDraw.setByte(Int32(targetByte), assignValue: outputBits)
            }
            else if ( brush == brushTypes.door){
                let outputBits = mapDraw.getByte(Int32(targetByte)) ^ 0b00100000
                mapDraw.setByte(Int32(targetByte), assignValue: outputBits)
            }
        }
        else if event.keyCode == 0x31 { //spacebar
            if (brush == brushTypes.wall){
                brush = brushTypes.door
            }
            else {
                brush = brushTypes.wall
            }
        }
        
        mapDraw.setSelectorPos(Int32(currentX), yPosition: Int32(currentY))
        
        updateDraw()
        
        debugLabel.stringValue = "Wall/Doors byte: "+String(mapDraw.getByte(Int32(targetByte)))
        let mbname = "\(brush)"
        debugLabel.stringValue = debugLabel.stringValue + "\n\nCurrent brush: "
        debugLabel.stringValue = debugLabel.stringValue + mbname
        }
        
        return event
    }
    
    @IBOutlet weak var filenameField: NSTextField!
    
    func writeDataToFile() {
        var file : String = filenameField.stringValue
        
        if (file == ""){
            file = filenameField.placeholderString!
            //file = file + ".bin"
        }
        file = file + ".bin"
        let writingText = NSData(data:mapDraw.getCurrentByteString())
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first! as NSString {
                let path = dir.appendingPathComponent(file);
                //writing
                do {
                    try writingText.write(toFile: path, atomically: false)
                } catch {
                    /* error handling here */
                }
                //reading
                do {
                    //_ = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
                }
                catch {
                    /* error handling here */
                }
            }
    }
    
    
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    public func newMap() {
        var i = 0
        while i < 1024 {
            mapDraw.setByte(Int32(i), assignValue: 0x00)
            i = i+1
        }
        updateDraw()
    }
    
    public func updateDraw() {
        drawGrid=1
        
        if(mapDraw.getByte(0) == 0x01){
            
        }
       
        mapDraw.needsDisplay=true
    }
    
    
    
}

