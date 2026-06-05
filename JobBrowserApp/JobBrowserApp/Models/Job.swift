//
//  Job.swift
//  JobBrowserApp
//
//  Created by Kapil Khedkar on 05/06/26.
//
import Foundation

struct Job: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let companyName: String
    let location: String
    let salaryRange: String
    let description: String
    let companyInfo: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, location, description
        case companyName = "company_name"
        case salaryRange = "salary_range"
        case companyInfo = "company_info"
    }
}
