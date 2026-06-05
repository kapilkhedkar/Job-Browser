//
//  JobListView.swift
//  JobBrowserApp
//
//  Created by Kapil Khedkar on 05/06/26.
//
import SwiftUI

struct JobListView: View {
    @StateObject private var viewModel = JobListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .idle:
                    Color.clear.onAppear {
                        Task { await viewModel.loadJobs() }
                    }
                case .loading:
                    ProgressView("Loading jobs...")
                        .scaleEffect(1.2)
                case .empty:
                    ContentUnavailableView(
                        "No Jobs Found",
                        systemImage: "briefcase.slash",
                        description: Text("Try adjusting your search filters or try again later.")
                    )
                case .success(let jobs):
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(jobs) { job in
                                NavigationLink(destination: JobDetailView(job: job)) {
                                    JobRowView(job: job)
                                }
                                .buttonStyle(PlainButtonStyle()) // Keeps text colors normal
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground)) // Subtle gray background behind cards
                case .error(let message):
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(message)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.loadJobs() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle("Job Board")
            .searchable(text: $viewModel.searchText, prompt: "Search title or company")
        }
    }
}
struct JobRowView: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title & Company Block
            VStack(alignment: .leading, spacing: 4) {
                Text(job.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(job.companyName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            Divider()
                .opacity(0.6)
            
            // Metadata Badges
            HStack(spacing: 12) {
                // Location Badge
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                    Text(job.location)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                .lineLimit(1)
                
                Spacer()
                
                // Salary Badge
                Text(job.salaryRange)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
            }
        }
        .padding()
        // Card Background & Styling
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
