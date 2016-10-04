//
//  WebViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class FoursquareViewController: UIViewController, UIWebViewDelegate {
    
    var idVenue: String?
    var idClient: String?
    
    let urlGeneral: String = "https://foursquare.com/v/"+"%idVenue"+"?ref="+"%idClient"
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var url = urlGeneral
        if idVenue != nil && idClient != nil{
            url = url.stringByReplacingOccurrencesOfString("%idVenue", withString: idVenue!, options: NSStringCompareOptions.LiteralSearch, range: nil)
            url = url.stringByReplacingOccurrencesOfString("%idClient", withString: idClient!, options: NSStringCompareOptions.LiteralSearch, range: nil)
            webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /* UIWebViewDelegate
    ------------------------------------------*/
    
    func webViewDidStartLoad(webView: UIWebView) {
        self.view.makeToastActivity()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.view.hideToastActivity()
        self.view.makeToast("An error occured".localized, duration: 2.0, position: "center")
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        self.view.hideToastActivity()
    }
    
    
}
