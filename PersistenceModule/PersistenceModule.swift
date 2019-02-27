//
//  PersistenceModule.swift
//  PersistenceModule
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import SQLite3

// Extends Notification names to add Error to the cases of names.
extension Notification.Name {
    static let error = Notification.Name("error")
}

// Custom enumerates for generated errors in each domain
enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

// Protocol for apply to the Classes or Structs wich need to define a Create Table Statement
public protocol SQLTable {
    static var createStatement: String { get }
}

// Class designed  for manage the database
open class PersistenceModule {
    // Pointer to the database
    let db: OpaquePointer?
    
    // With this computed vairable, we can get the last error message from the database log.
    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(db) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    fileprivate init (db: OpaquePointer?) {
        self.db = db
    }
    
    deinit {
        sqlite3_close(db)
    }
        
    // Open instance of DB if exsists
    public static func open() throws -> PersistenceModule {
        var db: OpaquePointer? = nil
        //Try to connect with DB
  
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent((Bundle(for: self).object(forInfoDictionaryKey: "database") as? String)!)
        try FileManager.default.removeItem(at: fileURL as URL)
        if sqlite3_open(fileURL.absoluteString, &db) == SQLITE_OK {
            // If successful, return the pointer to the Database
            return PersistenceModule(db: db)
        } else {
            // Otherwise, return the error, after closing the database in case is not nil.
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError.OpenDatabase(message: "No error mnessage provided from sqlite.")
            }
        }
    }
    
    // Send string to this method to know if is a good statement for execute.
    open func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
    
    // Function Designed to create table.
    // For this function, we send a class with SQLTable protocol implemented
    // And this make let us call createStatement computed property
    open func createTable(table: SQLTable.Type) throws {
        
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        
        defer { sqlite3_finalize(createTableStatement) }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    // Remove database
    // TODO: Controll if don't want to remove the database
    public static func deleteDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent((Bundle(for: self).object(forInfoDictionaryKey: "database") as? String)!)
        do {
            try FileManager.default.removeItem(at: fileURL as URL)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Function where we send a string statement with a Insert Query.
    open func insert(statement: String) throws {
        
        let insertSql = statement
        let insertStatement = try prepareStatement(sql: insertSql)
        defer { sqlite3_finalize(insertStatement) }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
}
