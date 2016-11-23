//
//  SourceEditorCommand.swift
//  XcodeSourceEditorPlaceholderExtension
//
//  Created by Konstantinos Kontos on 22/11/2016.
//  Copyright © 2016 K. K. Handmade Apps Ltd. All rights reserved.
//

import Foundation
import XcodeKit


//add new selection
/*
let selectionPosition = XCSourceTextRange.init(start: XCSourceTextPosition.init(line: 0, column: 0), end: XCSourceTextPosition.init(line: 0, column: 0))
self.buffer.selections.removeAllObjects()
self.buffer.selections.insert(selectionPosition, at: 0)
*/

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        if invocation.commandIdentifier == "xcodeSourceEditorPlaceholder.Insert" {
            
            
            for i in 0 ..< invocation.buffer.selections.count {
                let sourceCodeRange = invocation.buffer.selections[i] as! XCSourceTextRange
                
                if sourceCodeRange.start.column == sourceCodeRange.end.column && sourceCodeRange.start.line == sourceCodeRange.end.line {
                    processInsertCommand(selection: sourceCodeRange, invocation: invocation, selectionIndex: i)
                } else {
                    processReplaceCommand(selection: sourceCodeRange, invocation: invocation, selectionIndex: i)
                }
            }
            
        }
        
        completionHandler(nil)
        
    } // perform
    
    
    func processInsertCommand(selection: XCSourceTextRange, invocation: XCSourceEditorCommandInvocation, selectionIndex: Int) {
        let sourceCodeRange = selection
        
        var startLine = ""
        
        if sourceCodeRange.start.column == 0 {
            invocation.buffer.lines.add("<# code #>")
        } else {
            startLine = invocation.buffer.lines[sourceCodeRange.start.line] as! String
            
            let startIndex = startLine.index(startLine.startIndex, offsetBy: sourceCodeRange.start.column)
            
            startLine.insert(contentsOf: "<# code #>".characters, at: startIndex)
            
            invocation.buffer.lines[sourceCodeRange.start.line] = startLine
        }
        
    }
    
    
    func processReplaceCommand(selection: XCSourceTextRange, invocation: XCSourceEditorCommandInvocation, selectionIndex: Int) {
        let sourceCodeRange = selection
        
        if sourceCodeRange.start.line == sourceCodeRange.end.line {
            var startLine = invocation.buffer.lines[sourceCodeRange.start.line] as! String
            
            let startIndex = startLine.index(startLine.startIndex, offsetBy: sourceCodeRange.start.column)
            let endIndex = startLine.index(startLine.startIndex, offsetBy: sourceCodeRange.end.column)
            
            let stringRange = Range<String.Index>(uncheckedBounds: (lower: startIndex, upper: endIndex))
            
            startLine.replaceSubrange(stringRange, with: "<# code #>")
            
            invocation.buffer.lines[sourceCodeRange.start.line] = startLine
            
            // Nullify selection
            invocation.buffer.selections[selectionIndex] = XCSourceTextRange(start: sourceCodeRange.start,
                                                                             end: sourceCodeRange.start)
        } else {
            // Get head of replacement
            let startLine = invocation.buffer.lines[sourceCodeRange.start.line] as! String
            
            var editStart = startLine.startIndex
            var editEnd = startLine.index(startLine.startIndex, offsetBy: sourceCodeRange.start.column)
            
            let substringA = startLine.substring(with: Range<String.Index>(uncheckedBounds: (lower: editStart, upper: editEnd)))
            
            
            // Get tail of replacement
            var endLine = ""
            
            if sourceCodeRange.end.column == 0 {
                endLine = invocation.buffer.lines[sourceCodeRange.end.line-1] as! String
            } else {
                endLine = invocation.buffer.lines[sourceCodeRange.end.line] as! String
            }
            
            editStart = endLine.index(endLine.startIndex, offsetBy: sourceCodeRange.end.column)
            editEnd = endLine.endIndex
            
            let substringB = endLine.substring(with: Range<String.Index>(uncheckedBounds: (lower: editStart, upper: editEnd)))
            
            // replace text
            let replacementString = "\(substringA)<# code #>\(substringB)"
            
            let endlineIndex = sourceCodeRange.end.line - sourceCodeRange.start.line
            if endlineIndex >  invocation.buffer.lines.count {
                invocation.buffer.lines.removeAllObjects()
            } else {
                invocation.buffer.lines.removeObjects(in: NSMakeRange(sourceCodeRange.start.line, endlineIndex))
            }
            
            if invocation.buffer.lines.count == 0 {
                invocation.buffer.lines.add(replacementString)
            } else {
                invocation.buffer.lines.insert(replacementString, at: sourceCodeRange.start.line)
            }
         
            // Nullify selection
            invocation.buffer.selections[selectionIndex] = XCSourceTextRange(start: sourceCodeRange.start,
                                                                             end: sourceCodeRange.start)
        }
        
    }

    
}
