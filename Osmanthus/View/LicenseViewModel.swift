//
//  LicenseViewModel.swift
//  Osmanthus
//  
//  Created by Daiki Fujimori on 2025/02/13
//  

import Foundation

struct License: Codable, Identifiable {
    var id: String { name }
    let name: String
    let url: String
    let license: String
}

@Observable
@MainActor
class LicenseViewModel {
    
    private(set) var licenses: [License] = []
}

extension LicenseViewModel {
    
    func onAppear() {
        
        guard let url = Bundle.main.url(forResource: "licenses", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([License].self, from: data) else {
            
            print("Failed to load licenses.json")
            return
        }
        
        licenses = decoded
    }
}
