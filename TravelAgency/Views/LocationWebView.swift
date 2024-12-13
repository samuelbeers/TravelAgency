//
//  LocationWebView.swift
//  TravelAgency
//
//  Created by COMP401 on 12/12/24.
//

import SwiftUI
import WebKit

struct LocationWebView: UIViewRepresentable {
    let urlString : String
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString){
            uiView.load(URLRequest(url: url))
        } else{
            uiView.load(URLRequest(url: URL(string: "https://www.google.com")!))
        }
    }
}

#Preview {
    LocationWebView(urlString: "https://en.wikipedia.org/wiki/")
}
