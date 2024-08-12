//
//  ButtonView.swift
//  SwiftUI-Toot
//
//  Created by dave on 21/12/22.
//

import SwiftUI

struct ButtonView: View {
    var text: String
    var action: () async throws -> Void

    var body: some View {
        Button {
            Task {
                try await action()
            }
        } label: {
            Text(text)
                .frame(height: 44)
        }
    }
}
