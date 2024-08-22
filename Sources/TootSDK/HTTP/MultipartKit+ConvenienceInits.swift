//
//  File.swift
//  
//
//  Created by Dave Wood on 22/08/2024.
//

import Foundation
import MultipartKit

extension MultipartPart {
    public init(name: String, body: String) {
        self.init(
            headers: [
                "Content-Disposition": "form-data; name=\"\(name)\""
            ],
            body: body
        )
    }
    
    /// convenience init for file/data upload
    public init<Data>(file: String, mimeType: String, body: Data) where Data: DataProtocol {
        self.init(
            headers: [
                "Content-Disposition": "form-data; name=\"\(file)\"; filename=\"\(file)\"",
                "Content-Type": mimeType,
            ],
            body: body
        )
    }
}
