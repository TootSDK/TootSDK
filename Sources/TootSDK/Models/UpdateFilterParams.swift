//
//  UpdateFilterParams.swift
//
//
//  Created by Łukasz Rutkowski on 02/07/2024.
//

import Foundation

/// Parameters to update an existing filter.
public struct UpdateFilterParams: Sendable {
    let id: String
    let title: String?
    let context: Set<Filter.Context>?
    let action: Filter.Action?
    let expiry: Expiry?
    let keywords: [KeywordChange]

    public enum Expiry: Sendable {
        case never
        case seconds(Int)
    }
    
    /// Creates an object to update an existing filter with.
    ///
    /// - Parameters:
    ///   - id: The id of filter to update.
    ///   - title: New name for the filter.
    ///   - context: New contexts for the filter.
    ///   - action: New action of the filter.
    ///   - expiry: New expiry time of the filter.
    ///   - keywords: Keyword changes to perform.
    public init(
        id: String,
        title: String? = nil,
        context: Set<Filter.Context>? = nil,
        action: Filter.Action? = nil,
        expiry: Expiry? = nil,
        keywords: [KeywordChange] = []
    ) {
        self.id = id
        self.title = title
        self.context = context
        self.action = action
        self.expiry = expiry
        self.keywords = keywords
    }
    
    /// Change to perform on a keyword.
    public struct KeywordChange: Sendable {
        let id: String?
        let keyword: String?
        let wholeWord: Bool?
        let destroy: Bool
        
        /// Delete a keyword with the given `id`.
        ///
        /// - Parameter id: Id of keyword to delete.
        public static func delete(id: String) -> KeywordChange {
            return KeywordChange(
                id: id,
                keyword: nil,
                wholeWord: nil,
                destroy: true
            )
        }
        
        /// Change parameters of a keyword with the given `id`.
        ///
        /// - Parameters:
        ///   - id: Id of keyword to update.
        ///   - keyword: New keyword text.
        ///   - wholeWord: Whether the keyword should consider word boundaries.
        public static func update(
            id: String,
            keyword: String? = nil,
            wholeWord: Bool? = nil
        ) -> KeywordChange {
            return KeywordChange(
                id: id,
                keyword: keyword,
                wholeWord: wholeWord,
                destroy: false
            )
        }
        
        /// Add a new keyword.
        ///
        /// - Parameters:
        ///   - keyword: A keyword to be added to the newly-created filter.
        ///   - wholeWord: Whether the keyword should consider word boundaries.
        public static func create(
            keyword: String,
            wholeWord: Bool
        ) -> KeywordChange {
            return KeywordChange(
                id: nil,
                keyword: keyword,
                wholeWord: wholeWord,
                destroy: false
            )
        }
    }
}

extension UpdateFilterParams {
    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let title {
            items.append(URLQueryItem(name: "title", value: title))
        }
        if let context {
            for context in context {
                items.append(URLQueryItem(name: "context[]", value: context.rawValue))
            }
        }
        if let action {
            items.append(URLQueryItem(name: "filter_action", value: action.rawValue))
        }
        if let expiry {
            let expiresIn: String
            switch expiry {
            case .never:
                expiresIn = ""
            case .seconds(let seconds):
                expiresIn = String(seconds)
            }
            items.append(URLQueryItem(name: "expires_in", value: expiresIn))
        }
        for keyword in keywords {
            items.append(URLQueryItem(name: "keywords_attributes[][id]", value: keyword.id ?? ""))
            if keyword.destroy {
                items.append(URLQueryItem(name: "keywords_attributes[][_destroy]", value: "true"))
                continue
            }
            if let keyword = keyword.keyword {
                items.append(URLQueryItem(name: "keywords_attributes[][keyword]", value: keyword))
            }
            if let wholeWord = keyword.wholeWord {
                items.append(URLQueryItem(name: "keywords_attributes[][whole_word]", value: String(wholeWord)))
            }
        }
        return items
    }
}
