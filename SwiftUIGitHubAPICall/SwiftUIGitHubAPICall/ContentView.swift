//
//  ContentView.swift
//  SwiftUIGitHubAPICall
//
//  Created by Greg Alton on 3/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                
            } placeholder: {
                Circle()
                    .foregroundColor(.secondary)
            }
            .frame(width: 120, height: 120)
            
            Text(user?.name ?? "")
            
            Text(user?.bio ?? "This user has no biography")
            
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.invalidURL {
                print("Invalid URL")
            } catch GHError.invalidResponse {
                print("Invalid Response")
            } catch GHError.invalidData {
                print("Invalid Data")
            } catch {
                print("Unexpected Error")
            }
        }
    }
    
    // This would normally be refactored into a View Model, but I want everything in the same file for the example for easy viewing.
    func getUser() async throws -> GitHubUser {
        let endpoint = "https://api.github.com/users/gregalton"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

// This model could also be refactored into a separate file.
struct GitHubUser: Codable {
    let avatarUrl: String?
    let name: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case avatarUrl = "avatar_url"
        case name = "name"
        case bio = "bio"
    }
}

enum GHError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

#Preview {
    ContentView()
}
