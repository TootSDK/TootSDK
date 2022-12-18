//
//  PostView.swift
//  SwiftUI-Toot
//
//  Created by dave on 17/12/22.
//

import SwiftUI
import TootSDK

struct StatusView: View {
    var status: Status
    var attributed: Bool
    
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: status.account.avatar)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            
            VStack {
                HStack {
                    Text(status.account.displayName ?? "?")
                        .font(.caption.bold())
                    Text(status.account.username)
                        .font(.caption)
                }
                
                if attributed, let attributedText = status.content?.attributedString {
                    Text(AttributedString(attributedText))
                } else {
                    Text(status.content?.plainContent ?? "")
                }
            }
        }
        
    }
}
