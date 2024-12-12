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
    @EnvironmentObject var databaseManager: DatabaseManager
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
        
                const dateDiv = document.querySelector('div[aria-label="Travel date"]');
                console.log(dateDiv);
                const dateButton = dateDiv ? dateDiv.querySelector('button') : null;
                const date = dateButton ? dateButton.textContent : 'Unknown';

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
                    totalTime: totalTime,
                    date: date
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
        Coordinator(self, startingLocation: startingLocation, destination: destination, databaseManager: databaseManager)
    }

    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        var databaseManager: DatabaseManager
        var startingLocation: String
        var destination: String
        
        
        init(_ parent: WebView, startingLocation: String, destination: String, databaseManager: DatabaseManager) {
            self.parent = parent
            self.startingLocation = startingLocation
            self.destination = destination
            self.databaseManager = databaseManager
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "buttonClicked", let body = message.body as? String,
               let data = body.data(using: .utf8),
               let tripDetails = try? JSONDecoder().decode([String: String].self, from: data) {
                
               databaseManager.addTrip(
                    in_startingLocation: startingLocation,
                    in_destination: destination,
                    in_price: tripDetails["price"] ?? "Unknown",
                    in_startTime: tripDetails["startTime"] ?? "Unknown",
                    in_endTime: tripDetails["endTime"] ?? "Unknown",
                    in_totalTime: tripDetails["totalTime"] ?? "Unknown",
                    in_date: tripDetails["date"] ?? "Unknown"
                )
                if let trip = databaseManager.fetchLastInsertedTrip() {
                    parent.onTripSelected?(trip)
                }
            }
        }
    }
}
