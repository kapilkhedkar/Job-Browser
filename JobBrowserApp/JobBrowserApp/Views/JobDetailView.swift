//
//  JobDetailView.swift
//  JobBrowserApp
//
//  Created by Kapil Khedkar on 05/06/26.
//
import SwiftUI

struct JobDetailView: View {
    let job: Job
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.title)
                        .font(.title)
                        .bold()
                    
                    Text(job.companyName)
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 10) {
                        GridRow {
                            Label("Location", systemImage: "mappin.and.ellipse")
                                .bold()
                            Text(job.location)
                        }
                        GridRow {
                            Label("Salary", systemImage: "dollarsign.circle")
                                .bold()
                            Text(job.salaryRange)
                        }
                    }
                    .font(.body)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                // Job Description Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Job Description")
                        .font(.headline)
                    Text(job.description)
                        .font(.body)
                        .lineSpacing(4)
                }
                
                // Company Information Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("About the Company")
                        .font(.headline)
                    Text(job.companyInfo)
                        .font(.body)
                        .lineSpacing(4)
                }
                
                Spacer()
                
                Button(action: { /* Native Apply Logic */ }) {
                    Text("Apply Now")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.bottom))
    }
}
