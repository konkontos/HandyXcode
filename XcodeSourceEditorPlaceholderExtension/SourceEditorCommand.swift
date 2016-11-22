//
//  SourceEditorCommand.swift
//  XcodeSourceEditorPlaceholderExtension
//
//  Created by Konstantinos Kontos on 22/11/2016.
//  Copyright © 2016 K. K. Handmade Apps Ltd. All rights reserved.
//

import Foundation
import XcodeKit


class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        // Implement your command here, invoking the completion handler when done. Pass it nil on success, and an NSError on failure.
        
        if invocation.commandIdentifier == "xcodeSourceEditorPlaceholder.Insert" {
            
        }
        
        if invocation.commandIdentifier == "xcodeSourceEditorPlaceholder.Replace" {
            
            if invocation.buffer.selections.count == 1 {
                let selection = invocation.buffer.selections[0]
                
                let sourceCodeRange = selection as! XCSourceTextRange
                
                if sourceCodeRange.start.line == sourceCodeRange.end.line {
                    var startLine = invocation.buffer.lines[sourceCodeRange.start.line] as! String
                    
                    let startIndex = startLine.index(startLine.startIndex, offsetBy: sourceCodeRange.start.column)
                    let endIndex = startLine.index(startLine.startIndex, offsetBy: sourceCodeRange.end.column)
                    
                    let stringRange = Range<String.Index>(uncheckedBounds: (lower: startIndex, upper: endIndex))
                    
                    startLine.replaceSubrange(stringRange, with: "<# code #>")
                    
                    invocation.buffer.lines[sourceCodeRange.start.line] = startLine
                } else {
                    let startLine = invocation.buffer.lines[sourceCodeRange.start.line] as! String
                    let endLine = invocation.buffer.lines[sourceCodeRange.end.line] as! String
                    
                    var editStart = startLine.startIndex
                    var editEnd = startLine.index(startLine.startIndex, offsetBy: sourceCodeRange.start.column)
                    
                    let substringA = startLine.substring(with: Range<String.Index>(uncheckedBounds: (lower: editStart, upper: editEnd)))
                    
                    editStart = endLine.index(endLine.startIndex, offsetBy: sourceCodeRange.end.column)
                    editEnd = endLine.endIndex
                    
                    let substringB = endLine.substring(with: Range<String.Index>(uncheckedBounds: (lower: editStart, upper: editEnd)))
                    
                    let replacementString = "\(substringA)<# code #>\(substringB)"
                    
                    invocation.buffer.lines.removeObjects(in: NSMakeRange(sourceCodeRange.start.line, sourceCodeRange.end.line - sourceCodeRange.start.line))
                    invocation.buffer.lines.insert(replacementString, at: sourceCodeRange.start.line)
                    
                    if invocation.buffer.lines.count > sourceCodeRange.start.line + 1 {
                        invocation.buffer.lines.removeObject(at: sourceCodeRange.start.line + 1)
                    }
                    
                }
                
            }
        }
        
        completionHandler(nil)
    }
    
}