//
//  JobListViewModel.swift
//  JobBrowserApp
//
//  Created by Kapil Khedkar on 05/06/26.
//
import Foundation
import Combine

@MainActor
final class JobListViewModel: ObservableObject {
    @Published private(set) var state: ViewState<[Job]> = .idle
    @Published var searchText: String = ""
    
    private let jobService: JobServiceProtocol
    private var allJobs: [Job] = []
    private var cancellables = Set<AnyCancellable>()
    
    init(jobService: JobServiceProtocol = JobService()) {
        self.jobService = jobService
        setupSearchDebounce()
    }
    
    func loadJobs() async {
        state = .loading
        do {
            let jobs = try await jobService.fetchJobs()
            self.allJobs = jobs
            self.processJobs(jobs)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    private func setupSearchDebounce() {
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.filterJobs()
            }
            .store(in: &cancellables)
    }
    
    private func filterJobs() {
        guard !searchText.isEmpty else {
            processJobs(allJobs)
            return
        }
        
        let filtered = allJobs.filter { job in
            job.title.localizedCaseInsensitiveContains(self.searchText) ||
            job.companyName.localizedCaseInsensitiveContains(self.searchText)
        }
        
        processJobs(filtered)
    }
    
    private func processJobs(_ jobs: [Job]) {
        if jobs.isEmpty {
            state = .empty
        } else {
            state = .success(jobs)
        }
    }
}
