//
//  PostRow.swift
//  TootSDKExample
//
//  Created by Konstantin Gerry on 19/08/2025.
//

import SwiftUI

struct PostRow: View {
    let post: DisplayPost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.authorName)
                .font(.headline)
            Text(post.content)
                .font(.body)
                .lineLimit(5)
            Text(post.createdAt, style: .relative)
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
}
