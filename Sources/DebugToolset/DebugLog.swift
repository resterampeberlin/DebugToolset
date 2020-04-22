//
//  DebugLog.swift
//  DebugToolset
//
//  Created by Markus Nickels on 12.04.20.
//  Copyright © 2020 Resterampe Berlin. All rights reserved.
//

import Foundation

/// A general logging struct
public struct DebugLog {
    
    /// Indent level
    private(set) var indent = 0
    
    /// This array holds all the classes/structs.function for which "start" is called
    private var stack: [String] = []
    
    /// Error and warnings counter
    private(set) var errors = 0
    private(set) var warnings = 0
    
    /// When set to true, nothing will be printed
    #if DEBUG
    
    var silent = false
    
    #else
    
    // in npn debug build it will be always silent
    var silent: Bool {
        get {
            return true
        }
        set {
            return
        }
    }
    
    #endif
    
    public enum Highlight {
        case none, information, warning, error
    }
    
    private var buffer = ""

    /// Print a log message
    /// - Parameters:
    ///   - object: the obejct to be reported. Just use "self"
    ///   - message: a message to be dsiplayed
    ///   - file: the file to be reported
    ///   - function: the function to be reportede
    ///   - line: the line to be reported
    ///
    /// This function is meant to log, that something happend in an object (e.g. "values loaded"). For dumping of specific values use ".print"
    /// because .print does not log all the object information
    /// - Precondition: indent level correct
    /// - Important: Use **always** the default values for file, function and line because they will report automatically the correct values
    public mutating func log(_ object: Any,
                    message: String = "",
                    highlight: Highlight = .none,
                    verbose: Bool = true,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {
        // pre condition
        assert(indent >= 0)
        
        let fileName = (file as NSString).lastPathComponent
        
        if verbose {
            print("\(fileName):\(line)\t- \(String(describing: object)).\(function) : \(message)", highlight: highlight)
        }
        else {
            print("\(fileName):\(line)\t- \(String(describing: type(of: object))).\(function) : \(message)", highlight: highlight)
        }
    }
    
    /// Converty a number of parameters into a string
    /// - Parameter items: unspecified parameters
    /// - Returns: the composed string
    /// - Important: any item should conform to protocoll CustomStringConvertible
    private mutating func message(_ items: [Any], separator: String = " ") -> String {
        var message = ""
                
        for item in items {

            if let value = item as? CustomStringConvertible {
                message += String(describing: value) + separator
            }
            else {
                if let array = item as? [CustomStringConvertible] {
                    for value in array {
                        message += String(describing: value) + separator
                    }
                }
                else {
                    warn("unsupported type '\(String(describing: type(of: item)))'")
                }
            }
        }

        return message
    }

    /// Print items to the console with corrent indentiation and symbol
    /// - Parameter items: items to be printed
    private mutating func print(_ items: Any..., highlight: Highlight = .none) {
        if !silent {
            var prefix = ""
            
            switch highlight {
            case .none:
                prefix = "  "
 
            case .information:
                prefix = "✅"
 
            case .warning:
                prefix = "⚠️"
                warnings += 1

            case .error:
                prefix = "🧨"
                errors += 1
            }
            
            let spaces = String(repeating: " ", count: indent*2)
            
            Swift.print(prefix + "\t" + spaces + message(items))
        }
    }
    
    /// get a unique identifier of a function consting of type.name
    /// - Parameters:
    ///   - object: the object to be identified
    ///   - function: the function to be identified
    /// - Returns: unique identifier
    private func functionId(object: Any, function: String) -> String {
        return String(describing: type(of: object)) + "." + function
    }
    
    /// Start a log section, indenting the rest of the message nicely
    /// - Parameters:
    ///   - object: the obejct to be reported.  Just use "self"
    ///   - file: the file to be reported
    ///   - function: the function to be reportede
    ///   - line: the line to be reported
    /// - Postcondition: stack and indent level coherent
    /// - Important: Use  **always** the default values for file, function and line because they will report automatically the correct values
    public mutating func begin(_ object: Any,
                               file: String = #file,
                               function: String = #function,
                               line: Int = #line) {
        indent += 1
        stack.append(functionId(object: object, function: function))
        
        print(String(repeating: "-", count: 80))
        log(object, message: "🔽", file: file, function: function, line: line)
        
        // post condition
        assert(indent == stack.count)
    }
    
    /// Find a certain  ID in the stack
    /// - Parameter id: search ID
    /// - Returns: stack index or nil if not found
    private func findId(_ id: String) -> Int? {
        for (index, value) in stack.enumerated().reversed() {
            if value == id {
                return index
            }
        }
        
        return nil
    }
    
    /// End a log section
    /// - Parameters:
    ///   - object: the obejct to be reported.  Just use "self"
    ///   - file: the file to be reported
    ///   - function: the function to be reportede
    ///   - line: the line to be reported
    /// - Postcondition: stack and indent level coherent
    /// - Important: Use  **always** the default values for file, function and line because they will report automatically the correct values
    public mutating func end(_ object: Any,
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line) {
        var newIndent = indent
        
        if indent > 0 {
            let id = functionId(object: object, function: function)
            
            // does begin/end match?
            if stack.last == id {
                stack.removeLast()
            }
            else {
                // try to find the id in the array
                if let index = findId(id) {
                    var message = "Incorrect nesting of Debug.begin() and Debug.end(). Insert std.end() in "
                    
                    // append all missing ".end"
                    for i in index+1 ..< stack.count {
                        message += stack[i]
                        
                        if i < stack.count-1 {
                            message += ", "
                        }
                    }
                    
                    warn(message)
                    
                    // clean stack until found id
                    stack.removeSubrange(index ..< stack.count)
                 
                    // in this case we can set the _indent directly to the found level+1
                    newIndent = index+1
                }
                else {
                    newIndent = stack.count+1
                    
                    warn ("Incorrect nesting of Debug.begin() and Debug.end(). " +
                        "Insert std.begin() in \(functionId(object: object, function: function))")

                }
            }
        }
        else {
            newIndent = 1
            
            warn ("Incorrect nesting of Debug.begin() and Debug.end(). " +
                "Insert std.start() in \(functionId(object: object, function: function))")
        }
        
        indent = newIndent
        
        log(object, message: "🔼", file: file, function: function, line: line)
        print(String(repeating: "-", count: 80))
        
        indent -= 1
        
        // post condition
        assert(indent == stack.count)
    }
    
    /// Show an information
    /// - Parameters:
    ///   - message: message to be displayed
    ///   - hightlight: hightlighting style
    ///   - file: the file to be reported
    ///   - line: the file to be reported
    /// - Important: Use  **always** the default values for file and line because they will report automatically the correct values
    /// - Precondition: use only .none or .information for highlight. Other cases should be report with error() or warning()
    public mutating func info(_ items: Any..., highlight: Highlight = .information, file: String = #file, line: Int = #line) {
        assert(highlight == .none || highlight == .information)

        let fileName = (file as NSString).lastPathComponent
        
        print("\(fileName):\(line)\t- \(message(items))", highlight: highlight)
    }
    
    /// Show a warning
    /// - Parameters:
    ///   - message: message to be displayed
    ///   - file: the file to be reported
    ///   - line: the file to be reported
    /// - Important: Use  **always** the default values for file and line because they will report automatically the correct values
    public mutating func warn(_ items: Any..., file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        
        print("\(fileName):\(line)\t- \(message(items))", highlight: .warning)
    }
    
    /// Show am alert
    /// - Parameters:
    ///   - message: message to be displayed
    ///   - file: the file to be reported
    ///   - line: the file to be reported
    /// - Important: Use  **always** the default values for file and line because they will report automatically the correct values
    public mutating func error(_ items: Any..., file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        
        print("\(fileName):\(line)\t- \(message(items))", highlight: .error)
    }

    /// Add a string to the line buffer
    /// - Parameter message: the message to be appended
    /// - Parameter separator: the sepator added to the message (e.g. ",", " ", "\t")
    public mutating func add(_ items: Any..., separator: String = " ") {
        buffer += message(items, separator: separator)
    }
    
    /// Flush the contents of the buffer to the console
    /// - Parameters:
    ///   - file: the file to be reported
    ///   - line: the file to be reported
    /// - Important: Use  **always** the default values for file and line because they will report automatically the correct values
    public mutating func flush(file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent

        print("\(fileName):\(line)\t- \(buffer)", highlight: .none)
        
        buffer = ""
    }    
}


