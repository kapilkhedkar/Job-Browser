//
//  JobBrowserAppTests.swift
//  JobBrowserAppTests
//
//  Created by Kapil Khedkar on 05/06/26.
//
import XCTest
import Combine
@testable import JobBrowserApp

final class MockJobService: JobServiceProtocol {
    var shouldReturnError = false
    var mockJobs: [Job] = []
    
    func fetchJobs() async throws -> [Job] {
        if shouldReturnError {
            throw NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Mock connection failure"])
        }
        return mockJobs
    }
}

@MainActor
final class JobBrowserAppTests: XCTestCase {
    private var sut: JobListViewModel!
    private var mockService: MockJobService!
    private var cancellables: Set<AnyCancellable>!
    
    private let testJobs = [
        Job(id: "1", title: "iOS Developer", companyName: "Apple", location: "Cupertino", salaryRange: "$150k", description: "Desc", companyInfo: "Info"),
        Job(id: "2", title: "Android Developer", companyName: "Google", location: "Mountain View", salaryRange: "$140k", description: "Desc", companyInfo: "Info")
    ]
    
    override func setUp() {
        super.setUp()
        mockService = MockJobService()
        sut = JobListViewModel(jobService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_loadJobs_success_updatesStateToSuccess() async {
        mockService.mockJobs = testJobs
        await sut.loadJobs()
        XCTAssertEqual(sut.state, .success(testJobs))
    }
    
    func test_loadJobs_emptyData_updatesStateToEmpty() async {
        mockService.mockJobs = []
        await sut.loadJobs()
        XCTAssertEqual(sut.state, .empty)
    }
    
    func test_loadJobs_failure_updatesStateToError() async {
        mockService.shouldReturnError = true
        await sut.loadJobs()
        
        if case .error(let message) = sut.state {
            XCTAssertFalse(message.isEmpty)
        } else {
            XCTFail("State should have transitioned to .error")
        }
    }
    
    func test_searchFilter_byTitle_returnsFilteredResults() async {
        // Given
        mockService.mockJobs = testJobs
        await sut.loadJobs()
        
        let expectation = XCTestExpectation(description: "Wait for Combine search debounce to process")
        
        // Listen to state changes to handle the Combine pipeline safely
        sut.$state
            .dropFirst() // Drop the initial success state from loadJobs
            .sink { state in
                if case .success(let filteredJobs) = state, filteredJobs.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        // When
        sut.searchText = "iOS"
        
        // Then (Gives the main runloop a 1-second window to finish checking the debounce)
        await fulfillment(of: [expectation], timeout: 1.0)
        
        if case .success(let filteredJobs) = sut.state {
            XCTAssertEqual(filteredJobs.count, 1)
            XCTAssertEqual(filteredJobs.first?.title, "iOS Developer")
        } else {
            XCTFail("Expected .success outcome housing 1 matching query item")
        }
    }
    
    func test_searchFilter_noMatch_returnsEmptyState() async {
        // Given
        mockService.mockJobs = testJobs
        await sut.loadJobs()
        
        let expectation = XCTestExpectation(description: "Wait for Combine empty search result")
        
        sut.$state
            .dropFirst()
            .sink { state in
                if state == .empty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        // When
        sut.searchText = "React Native Architect"
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(sut.state, .empty)
    }
}
