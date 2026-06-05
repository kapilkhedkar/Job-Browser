//
//  ViewState.swift
//  JobBrowserApp
//
//  Created by Kapil Khedkar on 05/06/26.
//
import Foundation

enum ViewState<T: Equatable>: Equatable {
    case idle
    case loading
    case empty
    case success(T)
    case error(String)
}
