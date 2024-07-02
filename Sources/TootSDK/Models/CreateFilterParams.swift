//
//  CreateFilterParams.swift
//  
//
//  Created by Łukasz Rutkowski on 01/07/2024.
//

import Foundation

/// Parameters to create a new filter.
public struct CreateFilterParams: Sendable {
    let title: String
    let context: Set<Filter.Context>
    let action: Filter.Action
    let expiresInSeconds: Int?
    let keywords: [Keyword]
    
    /// Creates an object to create a new filter with.
    ///
    /// - Parameters:
    ///   - title: The name of the filter.
    ///   - context: Where the filter should be applied. Specify at least one value.
    ///   - action: The policy to be applied when the filter is matched.
    ///   - expiresInSeconds: How many seconds from now should the filter expire.
    ///   - keywords: Keywords to be added to the newly-created filter.
    public init(
        title: String,
        context: Set<Filter.Context>,
        action: Filter.Action,
        expiresInSeconds: Int?,
        keywords: [Keyword]
    ) {
        self.title = title
        self.context = context
        self.action = action
        self.expiresInSeconds = expiresInSeconds
        self.keywords = keywords
    }
    
    /// Keyword added to created filter.
    public struct Keyword: Sendable {
        let keyword: String
        let wholeWord: Bool
        
        /// Creates a keyword for newly created filter.
        ///
        /// - Parameters:
        ///   - keyword: A keyword to be added to the newly-created filter.
        ///   - wholeWord: Whether the keyword should consider word boundaries.
        public init(keyword: String, wholeWord: Bool) {
            self.keyword = keyword
            self.wholeWord = wholeWord
        }
    }
}

extension CreateFilterParams {
    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "title", value: title),
            URLQueryItem(name: "filter_action", value: action.rawValue),
        ]
        for context in context {
            items.append(URLQueryItem(name: "context[]", value: context.rawValue))
        }
        if let expiresInSeconds {
            items.append(URLQueryItem(name: "expires_in", value: String(expiresInSeconds)))
        }
        for keyword in keywords {
            items.append(URLQueryItem(name: "keywords_attributes[][keyword]", value: keyword.keyword))
            items.append(URLQueryItem(name: "keywords_attributes[][whole_word]", value: String(keyword.wholeWord)))
        }
        return items
    }
}
