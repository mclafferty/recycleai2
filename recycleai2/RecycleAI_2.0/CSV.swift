//
//  CSV.swift
//  RecycleAI_2.0
//
//
//  Created by Naoto Kaneko on 2/18/16.
//  Copyright © 2016 Naoto Kaneko. All rights reserved.
//  https://github.com/swiftcsv/SwiftCSV/blob/master/SwiftCSV/CSV.swift

//This code was taken from the SwiftCSV library to parse CSV files
//Due to issues importing this library we decided to use the code directly

import Foundation

public protocol CSVView {
    associatedtype Rows
    associatedtype Columns

    var rows: Rows { get }
    var columns: Columns { get }

    init(header: [String], text: String, delimiter: Character, limitTo: Int?, loadColumns: Bool) throws
}

open class CSV {
    static public let comma: Character = ","
    
    public let header: [String]

    lazy var _namedView: NamedView = {
        return try! NamedView(
            header: self.header,
            text: self.text,
            delimiter: self.delimiter,
            loadColumns: self.loadColumns)
    }()

    lazy var _enumeratedView: EnumeratedView = {
        return try! EnumeratedView(
            header: self.header,
            text: self.text,
            delimiter: self.delimiter,
            loadColumns: self.loadColumns)
    }()

    var text: String
    var delimiter: Character

    let loadColumns: Bool

    /// List of dictionaries that contains the CSV data
    public var namedRows: [[String : String]] {
        return _namedView.rows
    }

    /// Dictionary of header name to list of values in that column
    /// Will not be loaded if loadColumns in init is false
    public var namedColumns: [String : [String]] {
        return _namedView.columns
    }

    /// Collection of column fields that contain the CSV data
    public var enumeratedRows: [[String]] {
        return _enumeratedView.rows
    }

    /// Collection of columns with metadata.
    /// Will not be loaded if loadColumns in init is false
    public var enumeratedColumns: [EnumeratedView.Column] {
        return _enumeratedView.columns
    }


    @available(*, unavailable, renamed: "namedRows")
    public var rows: [[String : String]] {
        return namedRows
    }

    @available(*, unavailable, renamed: "namedColumns")
    public var columns: [String : [String]] {
        return namedColumns
    }

    
    /// Load CSV data from a string.
    ///
    /// - parameter string: CSV contents to parse.
    /// - parameter delimiter: Character used to separate  row and header fields (default is ',')
    /// - parameter loadColumns: Whether to populate the `columns` dictionary (default is `true`)
    /// - throws: `CSVParseError` when parsing `string` fails.
    public init(string: String, delimiter: Character = comma, loadColumns: Bool = true) throws {
        self.text = string
        self.delimiter = delimiter
        self.loadColumns = loadColumns
        self.header = try Parser.array(text: string, delimiter: delimiter, limitTo: 1).first ?? []
    }

    @available(*, deprecated, message: "Use init(url:delimiter:encoding:loadColumns:) instead of this path-based approach. Also, calling the parameter `name` instead of `path` was a mistake.")
    public convenience init(name: String, delimiter: Character = comma, encoding: String.Encoding = .utf8, loadColumns: Bool = true) throws {
        try self.init(url: URL(fileURLWithPath: name), delimiter: delimiter, encoding: encoding, loadColumns: loadColumns)
    }

    /// Load a CSV file as a named resource from `bundle`.
    ///
    /// - parameter name: Name of the file resource inside `bundle`.
    /// - parameter ext: File extension of the resource; use `nil` to load the first file matching the name (default is `nil`)
    /// - parameter bundle: `Bundle` to use for resource lookup (default is `.main`)
    /// - parameter delimiter: Character used to separate row and header fields (default is ',')
    /// - parameter encoding: encoding used to read file (default is `.utf8`)
    /// - parameter loadColumns: Whether to populate the columns dictionary (default is `true`)
    /// - throws: `CSVParseError` when parsing the contents of the resource fails, or file loading errors.
    /// - returns: `nil` if the resource could not be found
    public convenience init?(name: String, extension ext: String? = nil, bundle: Bundle = .main, delimiter: Character = comma, encoding: String.Encoding = .utf8, loadColumns: Bool = true) throws {
        guard let url = bundle.url(forResource: name, withExtension: ext) else {
            return nil
        }
        try self.init(url: url, delimiter: delimiter, encoding: encoding, loadColumns: loadColumns)
    }
    
    /// Load a CSV file from `url`.
    ///
    /// - parameter url: URL of the file (will be passed to `String(contentsOfURL:encoding:)` to load)
    /// - parameter delimiter: Character used to separate row and header fields (default is ',')
    /// - parameter encoding: Character encoding to read file (default is `.utf8`)
    /// - parameter loadColumns: Whether to populate the columns dictionary (default is `true`)
    /// - throws: `CSVParseError` when parsing the contents of `url` fails, or file loading errors.
    public convenience init(url: URL, delimiter: Character = comma, encoding: String.Encoding = .utf8, loadColumns: Bool = true) throws {
        let contents = try String(contentsOf: url, encoding: encoding)
        
        try self.init(string: contents, delimiter: delimiter, loadColumns: loadColumns)
    }
    
    /// Turn the CSV data into NSData using a given encoding
    open func dataUsingEncoding(_ encoding: String.Encoding) -> Data? {
        return description.data(using: encoding)
    }
}

public struct NamedView: CSVView {

    public var rows: [[String : String]]
    public var columns: [String : [String]]

    public init(header: [String], text: String, delimiter: Character, limitTo: Int? = nil, loadColumns: Bool = false) throws {

        var rows = [[String: String]]()
        var columns = [String: [String]]()

        try Parser.enumerateAsDict(header: header, content: text, delimiter: delimiter, limitTo: limitTo) { dict in
            rows.append(dict)
        }

        if loadColumns {
            for field in header {
                columns[field] = rows.map { $0[field] ?? "" }
            }
        }

        self.rows = rows
        self.columns = columns
    }
}

extension CSV: CustomStringConvertible {
    public var description: String {
        let head = header.joined(separator: ",") + "\n"
        let cont = namedRows.map { row in
            return header.map { key -> String in
                let value = row[key]!
                
                // Add quotes if value contains a comma
                if value.contains(",") {
                    return "\"\(value)\""
                }
                return value
                
            }.joined(separator: ",")
            
        }.joined(separator: "\n")
        return head + cont
    }
}

public struct EnumeratedView: CSVView {

    public struct Column {
        public let header: String
        public let rows: [String]
    }

    public private(set) var rows: [[String]]
    public private(set) var columns: [Column]

    public init(header: [String], text: String, delimiter: Character, limitTo: Int? = nil, loadColumns: Bool = false) throws {

        var rows = [[String]]()
        var columns: [EnumeratedView.Column] = []

        try Parser.enumerateAsArray(text: text, delimiter: delimiter, limitTo: limitTo, startAt: 1) { fields in
            rows.append(fields)
        }

        if loadColumns {
            columns = header.enumerated().map { (index: Int, header: String) -> EnumeratedView.Column in

                return EnumeratedView.Column(
                    header: header,
                    rows: rows.map { $0[index] })
            }
        }

        self.rows = rows
        self.columns = columns
    }

}

extension CSV {
    /// Parse the file and call a block on each row, passing it in as a list of fields
    /// limitTo will limit the result to a certain number of lines
    public func enumerateAsArray(limitTo: Int? = nil, startAt: Int = 0, _ block: @escaping ([String]) -> ()) throws {

        try Parser.enumerateAsArray(text: self.text, delimiter: self.delimiter, limitTo: limitTo, startAt: startAt, block: block)
    }

    public func enumerateAsDict(_ block: @escaping ([String : String]) -> ()) throws {

        try Parser.enumerateAsDict(header: self.header, content: self.text, delimiter: self.delimiter, block: block)
    }
}

enum Parser {

    static func array(text: String, delimiter: Character, limitTo: Int? = nil, startAt: Int = 0) throws -> [[String]] {

        var rows = [[String]]()

        try enumerateAsArray(text: text, delimiter: delimiter) { row in
            rows.append(row)
        }

        return rows
    }

    /// Parse the text and call a block on each row, passing it in as a list of fields.
    ///
    /// - parameter text: Text to parse.
    /// - parameter delimiter: Character to split row and header fields by (default is ',')
    /// - parameter limitTo: If set to non-nil value, enumeration stops
    ///   at the row with index `limitTo` (or on end-of-text, whichever is earlier.
    /// - parameter startAt: Offset of rows to ignore before invoking `block` for the first time. Default is 0.
    /// - parameter block: Callback invoked for every parsed row between `startAt` and `limitTo` in `text`.
    static func enumerateAsArray(text: String, delimiter: Character, limitTo: Int? = nil, startAt: Int = 0, block: @escaping ([String]) -> ()) throws {
        var currentIndex = text.startIndex
        let endIndex = text.endIndex

        var fields = [String]()
        var field = ""

        var count = 0

        func finishRow() {
            fields.append(String(field))
            if count >= startAt {
                block(fields)
            }
            count += 1
            fields = [String]()
            field = ""
        }

        var state: ParsingState = ParsingState(
            delimiter: delimiter,
            finishRow: finishRow,
            appendChar: { field.append($0) },
            finishField: {
                fields.append(field)
                field = ""
        })

        func limitReached(_ count: Int) -> Bool {

            guard let limitTo = limitTo,
                count >= limitTo
                else { return false }

            return true
        }

        while currentIndex < endIndex {
            let char = text[currentIndex]

            try state.change(char)

            if limitReached(count) {
                break
            }

            currentIndex = text.index(after: currentIndex)
        }

        if !fields.isEmpty || !field.isEmpty || limitReached(count) {
            fields.append(field)
            block(fields)
        }
    }

    static func enumerateAsDict(header: [String], content: String, delimiter: Character, limitTo: Int? = nil, block: @escaping ([String : String]) -> ()) throws {

        let enumeratedHeader = header.enumerated()

        try enumerateAsArray(text: content, delimiter: delimiter, startAt: 1) { fields in
            var dict = [String: String]()
            for (index, head) in enumeratedHeader {
                dict[head] = index < fields.count ? fields[index] : ""
            }
            block(dict)
        }
    }
}

public enum CSVParseError: Error {
    case generic(message: String)
    case quotation(message: String)
}

/// State machine of parsing CSV contents character by character.
struct ParsingState {

    private(set) var atStart = true
    private(set) var parsingField = false
    private(set) var parsingQuotes = false
    private(set) var innerQuotes = false

    let delimiter: Character
    let finishRow: () -> Void
    let appendChar: (Character) -> Void
    let finishField: () -> Void

    init(delimiter: Character,
         finishRow: @escaping () -> Void,
         appendChar: @escaping (Character) -> Void,
         finishField: @escaping () -> Void) {

        self.delimiter = delimiter
        self.finishRow = finishRow
        self.appendChar = appendChar
        self.finishField = finishField
    }

    mutating func change(_ char: Character) throws {
        if atStart {
            if char == "\"" {
                atStart = false
                parsingQuotes = true
            } else if char == delimiter {
                finishField()
            } else if char.isNewline {
                finishRow()
            } else {
                parsingField = true
                atStart = false
                appendChar(char)
            }
        } else if parsingField {
            if innerQuotes {
                if char == "\"" {
                    appendChar(char)
                    innerQuotes = false
                } else {
                    throw CSVParseError.quotation(message: "Can't have non-quote here: \(char)")
                }
            } else {
                if char == "\"" {
                    innerQuotes = true
                } else if char == delimiter {
                    atStart = true
                    parsingField = false
                    innerQuotes = false
                    finishField()
                } else if char.isNewline {
                    atStart = true
                    parsingField = false
                    innerQuotes = false
                    finishRow()
                } else {
                    appendChar(char)
                }
            }
        } else if parsingQuotes {
            if innerQuotes {
                if char == "\"" {
                    appendChar(char)
                    innerQuotes = false
                } else if char == delimiter {
                    atStart = true
                    parsingField = false
                    innerQuotes = false
                    finishField()
                } else if char.isNewline {
                    atStart = true
                    parsingQuotes = false
                    innerQuotes = false
                    finishRow()
                } else {
                    throw CSVParseError.quotation(message: "Can't have non-quote here: \(char)")
                }
            } else {
                if char == "\"" {
                    innerQuotes = true
                } else {
                    appendChar(char)
                }
            }
        } else {
            throw CSVParseError.generic(message: "me_irl")
        }
    }
}

extension String {
    internal var firstLine: String {
        var current = startIndex
        while current < endIndex && self[current].isNewline == false {
            current = self.index(after: current)
        }
        return String(self[..<current])
    }
}

extension Character {
    internal var isNewline: Bool {
        return self == "\n" || self == "\r\n" || self == "\r"
    }
}


