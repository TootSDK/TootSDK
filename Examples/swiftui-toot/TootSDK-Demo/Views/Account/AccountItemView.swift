//
//  AccountItemView.swift
//  SwiftUI-Toot
//
//  Created by dave on 21/12/22.
//

import SwiftUI

struct AccountItemView: View {
    var description: String
    var value: String?
    
    var body: some View {
        Text(description + ": " + (value ?? ""))
    }
}
