//
//  FeedSelectionView.swift
//  SwiftUI-Toot
//
//  Created by dave on 15/02/23.
//

import SwiftUI

enum SelectionOptions: String, CaseIterable {
    case home
    case local
    case federated
}

struct FeedSelectionView: View {
    
    @State private var selection: SelectionOptions = .home
    
    @StateObject var timeLineHomeViewModel = FeedViewModel(streamType: .home)
    @StateObject var timeLineLocalViewModel = FeedViewModel(streamType: .local)
    @StateObject var timeLineFederatedViewModel = FeedViewModel(streamType: .federated)
    
    var body: some View {
        VStack {
            Picker("Select your feed", selection: $selection) {
                ForEach(SelectionOptions.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            switch selection {
            case .home:
                FeedView(viewModel: timeLineHomeViewModel)
            case .local:
                FeedView(viewModel: timeLineLocalViewModel)
            case .federated:
                FeedView(viewModel: timeLineFederatedViewModel)
            }
        }
    }
}
