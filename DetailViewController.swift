//
//  DetailViewController.swift
//  URL Shortener
//
//  Created by Lab5student on 2024-03-22.
//

import UIKit
import Foundation

class DetailViewController: UIViewController {
    
    private let API_KEY = "c0RqlsmvCvwrFGBTt0AFIGeUCHID57UQRHRHfIbI5jQcDzL9QNV9Xx21idJ7"
    var selectedURL: URL!
    
    
    @IBOutlet weak var longURLLabel: UILabel!
    @IBOutlet weak var shortURLLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var expiryLabel: UILabel!
    @IBOutlet weak var hitsLabel: UILabel!
    
    @IBOutlet weak var longURLLabelText: UITextView!
    @IBOutlet weak var shortURLLabelText: UITextView!
    @IBOutlet weak var idLabelText: UITextView!
    @IBOutlet weak var createdAtLabelText: UITextView!
    @IBOutlet weak var expiryLabelText: UITextView!
    @IBOutlet weak var hitsLabelText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let shortenedURL = selectedURL.shortURL, let urlString = shortenedURL.absoluteString {
            let urlComponents = URLComponents(string: urlString)
            
            guard let domain = urlComponents?.host, let alias = urlComponents?.url?.pathComponents.last else {
                print("Error: Unable to extract domain or alias from URL")
                return
            }
            
            print("Domain: \(domain)")
            print("Alias: \(alias)")
            
            
            guard let apiURL = Foundation.URL(string:  "https://api.tinyurl.com/alias/\(domain)/\(alias)?api_token=\(API_KEY)") else {
                print("Error: Invalid API URL")
                return
            }
            
            var request = URLRequest(url: apiURL)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let session = URLSession.shared
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                
                print("Status code: \(httpResponse.statusCode)")
                DispatchQueue.main.async{
                    
                    if let data = data, let responseData = String(data: data, encoding: .utf8) {
                        let decoder = JSONDecoder()
                        do{
                            let response = try decoder.decode(DataResponse.self, from: data)
                            let slip = response.data
                            self.idLabelText.text = self.selectedURL.id?.uuidString
                            self.longURLLabelText.text = slip.url
                            self.shortURLLabelText.text = slip.tiny_url
                            self.idLabelText.text = self.selectedURL.id?.uuidString
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                            if let expiryDate = dateFormatter.date(from: slip.expires_at) {
                                let outputDateFormatter = DateFormatter()
                                outputDateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
                                let formattedExpiryDate = outputDateFormatter.string(from: expiryDate)
                                
                                self.expiryLabelText.text = formattedExpiryDate
                            }
                            if let createdDate = dateFormatter.date(from: slip.created_at) {
                                let outputDateFormatter = DateFormatter()
                                outputDateFormatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
                                let formattedCreatedDate = outputDateFormatter.string(from: createdDate)
                                
                                self.createdAtLabelText.text = formattedCreatedDate
                            }
                            self.hitsLabelText.text = String(slip.hits)
                            
                            print("Response data: \(responseData)")
                        }catch{
                            return
                            
                        }}}}
                        
                        task.resume()
                    }
                }
                
                
            }
