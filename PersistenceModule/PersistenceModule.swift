//
//  PersistenceModule.swift
//  PersistenceModule
//
//  Created by Victor Capilla Developer on 22/02/2019.
//  Copyright © 2019 VCapillaDev. All rights reserved.
//

import Foundation
import SQLite3

extension Notification.Name {
    static let error = Notification.Name("error")
}

enum SQLiteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

public protocol SQLTable {
    static var createStatement: String { get }
}

open class PersistenceModule {
    let db: OpaquePointer?
    
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
        
    public static func open() throws -> PersistenceModule {
        var db: OpaquePointer? = nil
        // 1 Try to connect with DB
  
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent((Bundle(for: self).object(forInfoDictionaryKey: "database") as? String)!)
        try FileManager.default.removeItem(at: fileURL as URL)
        if sqlite3_open(fileURL.absoluteString, &db) == SQLITE_OK {
            // 2 If successful, return the pointer to the Database
            return PersistenceModule(db: db)
        } else {
            // 3 Otherwise, return the error, after closing the database in case is not nil.
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
    
    open func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        
        return statement
    }
    
    open func createTable(table: SQLTable.Type) throws {
        
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        
        defer { sqlite3_finalize(createTableStatement) }
        
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    public static func deleteDatabase() {
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent((Bundle(for: self).object(forInfoDictionaryKey: "database") as? String)!)
        do {
            try FileManager.default.removeItem(at: fileURL as URL)
        } catch {
//            NotificationCenter.default.post(name: .error, object: ["message": error.localizedDescription])
            print(error.localizedDescription)
        }
    }
    
    open func insert(statement: String) throws {
        
        let insertSql = statement
        let insertStatement = try prepareStatement(sql: insertSql)
        defer { sqlite3_finalize(insertStatement) }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }

//        do {
//            try db.insertContact(contact: Contact(id: 1, name: "Ray"))
//        } catch {
//            print(db.errorMessage)
//        }
    }
    
    /*func getData<T>(query: String) -> [T]? {
        guard let queryStatement = try? prepareStatement(sql: query) else {
            return nil
        }
        
        defer { sqlite3_finalize(queryStatement) }
        var data: [T]? = nil
        while sqlite3_step(queryStatement) == SQLITE_ROW {
            
            
        }
    }*/
    
//    func contact(id: Int32) -> Contact? {
//        let querySql = "SELECT * FROM Contact WHERE Id = ?;"
//        guard let queryStatement = try? prepareStatement(sql: querySql) else {
//            return nil
//        }
//        
//        defer {
//            sqlite3_finalize(queryStatement)
//        }
//        
//        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
//            return nil
//        }
//        
//        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
//            return nil
//        }
//        
//        let id = sqlite3_column_int(queryStatement, 0)
//        
//        let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
//        let name = String(cString: queryResultCol1!) as NSString
//        
//        return Contact(id: id, name: name)
//    }
}

/**
 struct Contact {
 let id: Int32
 let name: NSString
 }
 
 extension Contact: SQLTable {
 static var createStatement: String {
 return """
 CREATE TABLE Contact(
 Id INT PRIMARY KEY NOT NULL,
 Name CHAR(255)
 );
 """
 }
 }
 
 
 do {
 try db.createTable(table: Contact.self)
 } catch {
 print(db.errorMessage)
 }
 
 */
