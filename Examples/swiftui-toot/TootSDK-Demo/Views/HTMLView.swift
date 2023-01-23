//  HTMLPostView.swift
//  Created by dave on 23/01/23.
//

import SwiftUI
import WebKit
import SafariServices
import MessageUI

struct HTMLView: View {
    @Environment(\.multilineTextAlignment) var alignment
    @State var dynamicHeight: CGFloat? = .zero
    
    var defaultHeight: CGFloat = 170
    
    var html: String
    var conf: HTMLViewConfiguration = HTMLViewConfiguration(customCSS: "img[data-tootsdk-emoji] { width: 28px; height: 28px; object-fit: cover; vertical-align:middle;}" )
    
    var body: some View {
        VStack {
            WrappedWKWebView(dynamicHeight: $dynamicHeight, html: html)
        }
        .frame(height: dynamicHeight ?? defaultHeight)
    }
}

extension UIColor {
    var hex: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        
        if alpha == 1.0 {
            return String(
                format: "%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier)
            )
        } else {
            return String(
                format: "%02lX%02lX%02lX%02lX",
                Int(red * multiplier),
                Int(green * multiplier),
                Int(blue * multiplier),
                Int(alpha * multiplier)
            )
        }
    }
}


public struct ColorSet {
    private let light: String
    private let dark: String
    public var isImportant: Bool
    
    public init(light: String, dark: String, isImportant: Bool = false) {
        self.light = light
        self.dark = dark
        self.isImportant = isImportant
    }
    
    public init(light: UIColor, dark: UIColor, isImportant: Bool = false) {
        self.light = light.hex ?? "000000"
        self.dark = dark.hex ?? "F2F2F2"
        self.isImportant = isImportant
    }
    
    func value(_ isLight: Bool) -> String {
        "#\(isLight ? light : dark)\(isImportant ? " !important" : "")"
    }
}

public enum FontType {
    case system
    case monospaced
    case italic
    case custom(UIFont)
    case customName(String)
    
    @available(*, deprecated, renamed: "system")
    case `default`
    
    var name: String {
        switch self {
        case .monospaced:
            return UIFont.monospacedSystemFont(ofSize: 17, weight: .regular).fontName
        case .italic:
            return UIFont.italicSystemFont(ofSize: 17).fontName
        case .custom(let font):
            return font.fontName
        case .customName(let name):
            return name
        default:
            return "-apple-system"
        }
    }
}

public enum LinkOpenType {
    case SFSafariView(configuration: SFSafariViewController.Configuration = .init(), isReaderActivated: Bool? = nil, isAnimated: Bool = true)
    case Safari
    case none
}

public enum ColorPreference {
    case all
    case onlyLinks
    case none
}

public enum ColorScheme {
    case light
    case dark
    case auto
}


public struct HTMLViewConfiguration {
    
    public var customCSS: String
    
    public var fontType: FontType
    public var fontColor: ColorSet
    public var lineHeight: CGFloat
    
    public var colorScheme: ColorScheme
    
    public var imageRadius: CGFloat
    
    public var linkOpenType: LinkOpenType
    public var linkColor: ColorSet
    
    public var isColorsImportant: ColorPreference
    
    public init(
        customCSS: String = "",
        fontType: FontType = .system,
        fontColor: ColorSet = .init(light: "000000", dark: "F2F2F2"),
        lineHeight: CGFloat = 170,
        colorScheme: ColorScheme = .auto,
        imageRadius: CGFloat = 0,
        linkOpenType: LinkOpenType = .SFSafariView(),
        linkColor: ColorSet = .init(light: "007AFF", dark: "0A84FF", isImportant: true),
        isColorsImportant: ColorPreference = .onlyLinks
    ) {
        self.customCSS = customCSS
        self.fontType = fontType
        self.fontColor = fontColor
        self.lineHeight = lineHeight
        self.colorScheme = colorScheme
        self.imageRadius = imageRadius
        self.linkOpenType = linkOpenType
        self.linkColor = linkColor
        self.isColorsImportant = isColorsImportant
    }
    
    func css(isLight: Bool, alignment: TextAlignment) -> String {
        """
        img{max-height: 100%; min-height: 100%; height:auto; max-width: 100%; width:auto;margin-bottom:5px; border-radius: \(imageRadius)px;}
        h1, h2, h3, h4, h5, h6, p, div, dl, ol, ul, pre, blockquote {text-align:\(alignment.htmlDescription); line-height: \(lineHeight)%; font-family: '\(fontType.name)' !important; color: \(fontColor.value(isLight)); }
        iframe{width:100%; height:250px;}
        a:link {color: \(linkColor.value(isLight));}
        A {text-decoration: none;}
        """
    }
}


struct WrappedWKWebView: UIViewRepresentable {
    @Environment(\.multilineTextAlignment) var alignment
    @Binding var dynamicHeight: CGFloat?
    
    var html: String
    var conf: HTMLViewConfiguration = HTMLViewConfiguration()
    
    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        
        webview.scrollView.bounces = false
        webview.navigationDelegate = context.coordinator
        webview.scrollView.isScrollEnabled = false
        
        let bundleURL = Bundle.main.bundleURL
        webview.loadHTMLString(generateHTML(), baseURL: bundleURL)
        
        webview.isOpaque = false
        webview.backgroundColor = UIColor.clear
        webview.scrollView.backgroundColor = UIColor.clear
        
        return webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let bundleURL = Bundle.main.bundleURL
        uiView.loadHTMLString(generateHTML(), baseURL: bundleURL)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension WrappedWKWebView {
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WrappedWKWebView
        
        init(_ parent: WrappedWKWebView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
                DispatchQueue.main.async {
                    self.parent.dynamicHeight = height as? CGFloat
                }
            })
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard navigationAction.navigationType == WKNavigationType.linkActivated,
                  var url = navigationAction.request.url else {
                decisionHandler(WKNavigationActionPolicy.allow)
                return
            }
            
            if url.scheme == nil {
                guard let httpsURL = URL(string: "https://\(url.absoluteString)") else { return }
                url = httpsURL
            }
            
            switch url.scheme {
            case "mailto", "tel":
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            case "http", "https":
                switch self.parent.conf.linkOpenType {
                case .SFSafariView(let conf, let isReaderActivated, let isAnimated):
                    if let reader = isReaderActivated {
                        conf.entersReaderIfAvailable = reader
                    }
                    let root = UIApplication.shared.windows.first?.rootViewController
                    root?.present(SFSafariViewController(url: url, configuration: conf), animated: isAnimated, completion: nil)
                case .Safari:
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                case .none:
                    break
                }
            default:
                return
            }
            
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
    }
}

extension WrappedWKWebView {
    func generateHTML() -> String {
        return """
            <HTML>
            <head>
                <meta name='viewport' content='width=device-width, shrink-to-fit=YES, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
            </head>
            \(generateCSS())
            <div>\(html)</div>
            </BODY>
            </HTML>
            """
    }
    
    func generateCSS() -> String {
        switch conf.colorScheme {
        case .light:
            return "<style type='text/css'>\(conf.css(isLight: true, alignment: alignment))\(conf.customCSS)</style><BODY>"
        case .dark:
            return "<style type='text/css'>\(conf.css(isLight: false, alignment: alignment))\(conf.customCSS)</style><BODY>"
        case .auto:
            return """
            <style type='text/css'>
            @media (prefers-color-scheme: light) {
                \(conf.css(isLight: true, alignment: alignment))
            }
            @media (prefers-color-scheme: dark) {
                \(conf.css(isLight: false, alignment: alignment))
            }
            \(conf.customCSS)
            </style>
            <BODY>
            """
        }
    }
}
