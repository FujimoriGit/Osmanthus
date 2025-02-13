//
//  LicenseListView.swift
//  Osmanthus
//  
//  Created by Daiki Fujimori on 2025/02/13
//  


import SwiftUI

struct LicenseListView: View {
    
    private let viewModel = LicenseViewModel()

    var body: some View {
        ScrollView {
            ForEach(viewModel.licenses) { license in
                
                Text(license.name)
                    .font(.headline)
                
                Text(license.license)
                    .font(.body)
                    .padding()
                
                Divider()
            }
            .navigationTitle("ライセンス情報")
        }
        .onAppear {
            
            viewModel.onAppear()
        }
    }
}

struct LicenseDetailView: View {
    
    let license: License

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(license.name)
                    .font(.title)
                    .bold()

                Text("URL: \(license.url)")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if let url = URL(string: license.url) {
                            UIApplication.shared.open(url)
                        }
                    }

                Divider()

                Text(license.license)
                    .font(.body)
                    .padding()
            }
            .padding()
        }
        .navigationTitle(license.name)
    }
}


#Preview {
    LicenseListView()
}
