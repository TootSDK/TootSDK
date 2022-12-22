//
//  String+HTML.swift
//  Source: https://gist.github.com/hashaam/31f51d4044a03473c18a168f4999f063?permalink_comment_id=3137487#gistcomment-3137487
//

import Foundation

internal actor TootStringFormatter {
    
    nonisolated func getAttributedString(value: String?) async throws -> NSAttributedString? {
        if let plain = value?.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: ""),
           let data = plain.data(using: plain.fastestEncoding) {
            let attributedString = try NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil)
            
            attributedString.removeAttribute(.font, range: NSRange(location: 0, length: attributedString.length))
            
            return attributedString
        } else {
            return nil
        }
    }
    
    func trimHTMLTags(value: String?) async throws -> String? {
        if let htmlStringData = value?.data(using: String.Encoding.utf8) {
            
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            let attributedString = try NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
            return attributedString.string
        } else {
            return nil
        }
    }
    
}
