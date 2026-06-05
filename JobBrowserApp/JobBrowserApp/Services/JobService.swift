//
//  JobService.swift
//  JobBrowserApp
//
//  Created by Kapil Khedkar on 05/06/26.
//
import Foundation

protocol JobServiceProtocol {
    func fetchJobs() async throws -> [Job]
}

enum JobServiceError: Error, LocalizedError {
    case fileNotFound
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound: return "The data file could not be found."
        case .decodingError: return "Failed to parse the job data properly."
        }
    }
}

final class JobService: JobServiceProtocol {
    private let fileName: String
    
    init(fileName: String = "mock_jobs") {
        self.fileName = fileName
    }
    
    func fetchJobs() async throws -> [Job] {
        // Simulate network latency (1 second)
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw JobServiceError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([Job].self, from: data)
        } catch {
            throw JobServiceError.decodingError
        }
    }
}
