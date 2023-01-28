//
//  AccountItemView.swift
//  SwiftUI-Toot
//
//  Created by dave on 21/12/22.
//

import SwiftUI

struct AccountItemView<Content: View>: View {
    var description: String
    var value: String?

    let content: Content

    init(description: String,
         value: String? = nil,
         @ViewBuilder content: () -> Content = { EmptyView() }) {
        self.description = description
        self.value = value
        self.content = content()
    }

    var body: some View {
        HStack {
            Text(description + ": ")
            content
            Text(value ?? "")
            Spacer()
        }
    }
}

//
//struct AccountItemView<Content>: View where Content: View {
//    var description: String
//    var value: String?
//
//    let content: () -> Content?
//
//    init(description: String, value: String) {
//        self.init(description: description, value: value, content: EmptyView())
//    }
//
//    init(description: String,
//         value: String? = nil,
//content: @ViewBuilder
//        self.description = description
//        self.value = value
//        self.content = content
//    }
//
//    var body: some View {
//        HStack {
//            Text(description + ": ")
//            Text(value ?? "")
//            content()
//        }
//    }
//}
