//
//  WebView.swift
//  TravelAgency
//
//  Created by Sam Beers on 11/18/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var urlString: String
    var startingLocation: String
        var destination: String
    var onTripSelected: ((TripData) -> Void)?
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        
        configuration.userContentController.add(context.coordinator, name: "buttonClicked")
        
        let script = """
        document.addEventListener('touchend', function(event) {
            const button = event.target.closest('button');
            if (button && button.querySelector('span')?.innerText === 'Select') {
                const parentDiv = button.closest('div');
                const priceElement = parentDiv ? parentDiv.querySelector('h5') : null;
                const price = priceElement ? priceElement.textContent : 'Unknown';

                const detailsDiv = button.closest('div')?.previousElementSibling;
                let startTime = 'Unknown';
                let endTime = 'Unknown';
                let totalTime = 'Unknown';

                if (detailsDiv) {
                    const timeElements = detailsDiv.querySelectorAll('time');
                    if (timeElements.length >= 3) {
                        startTime = timeElements[0].textContent;
                        endTime = timeElements[1].textContent;
                        totalTime = timeElements[2].textContent;
                    }
                }

                const tripData = {
                    price: price,
                    startTime: startTime,
                    endTime: endTime,
                    totalTime: totalTime
                };
                window.webkit.messageHandlers.buttonClicked.postMessage(JSON.stringify(tripData));
            }
        });
        """;
        
        
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        configuration.userContentController.addUserScript(userScript)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            uiView.load(URLRequest(url: url))
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, startingLocation: startingLocation, destination: destination)
    }

    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        var startingLocation: String
        var destination: String
        
        init(_ parent: WebView, startingLocation: String, destination: String) {
            self.parent = parent
            self.startingLocation = startingLocation
            self.destination = destination
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "buttonClicked", let body = message.body as? String,
               let data = body.data(using: .utf8),
               let tripDetails = try? JSONDecoder().decode([String: String].self, from: data) {
                
                let trip = TripData(
                    startingLocation: startingLocation,
                    destination: destination,
                    price: tripDetails["price"] ?? "Unknown",
                    startTime: tripDetails["startTime"] ?? "Unknown",
                    endTime: tripDetails["endTime"] ?? "Unknown",
                    totalTime: tripDetails["totalTime"] ?? "Unknown"
                )
                
                parent.onTripSelected?(trip)
            }
        }
    }
}
