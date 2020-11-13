//
//  WebBrowser - ViewController.swift
//  Created by yagom.
//  Copyright © yagom. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var goBackButton: UIBarButtonItem!
    @IBOutlet weak var goForwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadPageButton: UIBarButtonItem!
    @IBOutlet weak var searchBarURL: UISearchBar!
    @IBOutlet weak var moveToURLButton: UIButton!
    @IBOutlet weak var initialScreenLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBarURL.autocapitalizationType = .none
        searchBarURL.delegate = self
        webView.navigationDelegate = self
        initialScreenLabel.isHidden = true
        goBackButton.isEnabled = webView.canGoBack
        goForwardButton.isEnabled = webView.canGoBack
        
        let initialURLString = "http://www.naver.com"
        
        guard let initialURL = convertStringToURL(of: initialURLString) else {
            print("URL is nil : 잘못된 값이 입력되었습니다.")
            initialScreenLabel.isHidden = false
            initialScreenLabel.text = "올바른 URL값을 입력해주세요."

            return
        }

        loadWebView(of: initialURL)
    }
    
    @IBAction func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func reloadPage() {
        webView.reload()
    }
    
    @IBAction func tappedMoveToURLButton(_ sender: UIButton) {
        guard let searchBarURLText = searchBarURL.text,
              let requestedURL = convertStringToURL(of: searchBarURLText) else {
            return
        }
        
        loadWebView(of: requestedURL)
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        goBackButton.isEnabled = webView.canGoBack
        goForwardButton.isEnabled = webView.canGoForward
        showCurrentAddress()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let notFoundURLAlert = UIAlertController(title: "Not Found", message: "입력한 주소가 올바른 형태가 아닙니다.", preferredStyle: .alert)
        let exitAction = UIAlertAction(title: "닫기", style: .default, handler: nil)
        notFoundURLAlert.addAction(exitAction)
        present(notFoundURLAlert,animated: false,completion: nil)
        showCurrentAddress()
        return
    }
}

extension ViewController: UISearchBarDelegate {
    private func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tappedMoveToURLButton(moveToURLButton)
        searchBar.resignFirstResponder()
    }
}

extension ViewController {
    private func loadWebView(of requestedURL: URL) {
        let urlRequest = URLRequest(url: requestedURL)
        searchBarURL.text = requestedURL.absoluteString
        print(urlRequest)
        webView.load(urlRequest)
    }
    
    private func convertStringToURL(of searchBarText: String?) -> URL? {
        guard let requestedURLText = searchBarText?.trimmingCharacters(in: [" "]) else {
            return nil
        }
        if validateURL(of: searchBarText) == true {
            return URL(string: requestedURLText)
        } else {
            return URL(string: "http://" + requestedURLText)
        }
    }
    
    private func validateURL(of searchBarText: String?) -> Bool? {
        guard let requestedURLText = searchBarText else {
            return nil
        }
        if requestedURLText.hasPrefix("https://") || requestedURLText.hasPrefix("http://") {
            return true
        } else {
            return false
        }
    }
    
    private func showCurrentAddress() {
        let currentAddress = webView.url
        searchBarURL.text = currentAddress?.absoluteString
    }
}
