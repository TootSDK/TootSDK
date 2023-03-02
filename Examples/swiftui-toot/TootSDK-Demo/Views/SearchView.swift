//
//  SearchView.swift
//  SwiftUI-Toot
//
//  Created by Łukasz Rutkowski on 12/02/2023.
//

import SwiftUI
import TootSDK

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: Search?
    @State private var path = NavigationPath()
    @EnvironmentObject private var tootManager: TootManager
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if let searchResults {
                    Section("Posts") {
                        ForEach(searchResults.posts) { post in
                            Text(post.id)
                        }
                    }
                    Section("Accounts") {
                        ForEach(searchResults.accounts) { account in
                            Text(account.acct)
                        }
                    }
                    Section("Hashtags") {
                        ForEach(searchResults.hashtags, id: \.name) { hashtag in
                            NavigationLink {
                                FeedView(viewModel: FeedViewModel(streamType: .timeLineHashtag(tag: hashtag.name, anyTags: nil, allTags: nil, noneTags: nil, onlyMedia: nil, locality: nil)))
                            } label: {
                                Text(hashtag.name)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search")
        }
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            Task {
                await performSearch()
            }
        }
    }
    
    private func performSearch() async {
        guard let client = tootManager.currentClient else { return }
        do {
            searchResults = try await client.search(params: SearchParams(query: searchText, resolve: true))
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
