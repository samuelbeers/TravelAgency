//
//  WebView.swift
//  TravelAgency
//
//  Created by Sam Beers on 11/18/24.
//

import SwiftUI

import WebKit

struct WebView: UIViewRepresentable {
    
    @Binding var urlString : String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
        if let url = URL(string: urlString) {
            let urlRequest = URLRequest(url: url)
            uiView.load(urlRequest)
        } else {
            uiView.load(URLRequest(url: URL(string: "https://www.google.com")!))
        }
        
    }
    
    
    
}
