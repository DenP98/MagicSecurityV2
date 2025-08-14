//
//  WebView.swift
//  MagicSecurity
//
//  Created by User on 5.05.25.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    enum UpcomingAction {
        case goBack
        case goForward
        case refresh
        case stopLoading
    }

    let loadURL: URL
    @Binding var isLoading: Bool
    @Binding var webViewError: String?
    @Binding var displayPage: PageItem?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var upcomingAction: UpcomingAction?

    func makeCoordinator() -> Coordinator {
        Coordinator(
            parent: self
        )
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let action = upcomingAction {
            switch action {
            case .goBack:
                if webView.canGoBack {
                    webView.goBack()
                }
            case .goForward:
                if webView.canGoForward {
                    webView.goForward()
                }
            case .refresh:
                webView.reload()
            case .stopLoading:
                webView.stopLoading()
            }
            DispatchQueue.main.async {
                self.upcomingAction = nil
            }
        }
        
        guard webView.url != loadURL, upcomingAction == nil else {
            return
        }
        
        if webView.isLoading && webView.url != loadURL {
            webView.stopLoading()
        }
        let request = URLRequest(url: loadURL)
        webView.load(request)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(parent: WebView) {
            self.parent = parent
        }
        
        func updateNavigationState(_ webView: WKWebView) {
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
            parent.displayPage = if let url = webView.url {
                PageItem(title: webView.title, value: url)
            } else {
                nil
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.webViewError = nil
            updateNavigationState(webView)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            updateNavigationState(webView)
            parent.upcomingAction = nil
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.webViewError = error.localizedDescription
            updateNavigationState(webView)
            parent.upcomingAction = nil
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.webViewError = error.localizedDescription
            updateNavigationState(webView)
            parent.upcomingAction = nil
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType != .backForward {
                 parent.upcomingAction = nil
            }
            decisionHandler(.allow)
        }
    }
    
    init(
        loadURL: URL,
        isLoading: Binding<Bool>,
        webViewError: Binding<String?>,
        displayPage: Binding<PageItem?>,
        canGoBack: Binding<Bool>,
        canGoForward: Binding<Bool>,
        upcomingAction: Binding<UpcomingAction?>
    ) {
        self.loadURL = loadURL
        self._isLoading = isLoading
        self._webViewError = webViewError
        self._displayPage = displayPage
        self._canGoBack = canGoBack
        self._canGoForward = canGoForward
        self._upcomingAction = upcomingAction
    }
}

#if DEBUG
struct WebView_Previews: PreviewProvider {
    @State static var isLoadingPreview = false
    @State static var webViewErrorPreview: String? = nil
    @State static var displayPagePreview: PageItem?
    @State static var canGoBackPreview = false
    @State static var canGoForwardPreview = false
    @State static var upcomingActionPreview: WebView.UpcomingAction? = nil
    
    static var previews: some View {
        WebView(
            loadURL: URL(string: "https://www.instagram.com")!,
            isLoading: $isLoadingPreview,
            webViewError: $webViewErrorPreview,
            displayPage: $displayPagePreview,
            canGoBack: $canGoBackPreview,
            canGoForward: $canGoForwardPreview,
            upcomingAction: $upcomingActionPreview
        )
    }
}
#endif
