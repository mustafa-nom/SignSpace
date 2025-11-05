//
//  CSVExporter.swift
//  SignSpace
//
//  Created by Mus Nom on 10/16/25.
//

/*
Abstract:
CSV export functionality for tracking user progress.
*/

import Foundation
import SwiftUI

class CSVExporter: ObservableObject {
    @Published var exportURL: URL?
    
    // track session data
    struct SessionData {
        let timestamp: Date
        let lessonName: String
        let gestureName: String
        let accuracy: Float
        let attempts: Int
        let completed: Bool
    }
    
    private var sessions: [SessionData] = []
    
    // add session record
    func recordSession(lessonName: String, gestureName: String, accuracy: Float, attempts: Int, completed: Bool) {
        let session = SessionData(
            timestamp: Date(),
            lessonName: lessonName,
            gestureName: gestureName,
            accuracy: accuracy,
            attempts: attempts,
            completed: completed
        )
        sessions.append(session)
    }
    
    // generate CSV string
    func generateCSV() -> String {
        var csv = "Timestamp,Lesson,Gesture,Accuracy,Attempts,Completed\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for session in sessions {
            let row = """
            \(dateFormatter.string(from: session.timestamp)),\
            \(session.lessonName),\
            \(session.gestureName),\
            \(session.accuracy),\
            \(session.attempts),\
            \(session.completed)
            """
            csv += row + "\n"
        }
        
        return csv
    }
    
    // export to file
    func exportToFile() -> URL? {
        let csvString = generateCSV()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let filename = "SignSpace_Progress_\(timestamp).csv"
        
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("Could not find documents directory")
            return nil
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            try csvString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV exported to: \(fileURL.path)")
            exportURL = fileURL
            return fileURL
        } catch {
            print("Error exporting CSV: \(error)")
            return nil
        }
    }
    
    // clear all session data
    func clearSessions() {
        sessions.removeAll()
    }
    
    // getter: total sessions count
    func getSessionCount() -> Int {
        return sessions.count
    }
}
