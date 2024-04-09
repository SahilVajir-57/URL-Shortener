//
//  ViewController.swift
//  URL Shortener
//
//  Created by Lab5student on 2024-03-01.
//

import UIKit
import CoreData
import SafariServices
import CoreImage
import CoreImage.CIFilter
import CoreImage.CIFilterGenerator

class URLTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass]{
        return[NSURL.self]
    }
    static func register(){
        let transformer = URLTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName(rawValue: "URLTransformer"))
    }
}

class ViewController: UIViewController {
    
    private let API_KEY = "c0RqlsmvCvwrFGBTt0AFIGeUCHID57UQRHRHfIbI5jQcDzL9QNV9Xx21idJ7"
    
    @IBOutlet weak var view2: UIView!
    
    @IBOutlet weak var longURLText: UITextView!
    @IBOutlet weak var shortenBtn: UIButton!
    @IBOutlet weak var nextScreenBtn: UIButton!
    @IBOutlet weak var copyBtn: UIButton!
    @IBOutlet weak var shortURLText: UILabel!
    @IBOutlet weak var qrCodeBtn: UIButton!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        URLTransformer.register()
        view2.addSubview(shortenBtn)
        view2.addSubview(longURLText)
        view2.addSubview(nextScreenBtn)
        view2.addSubview(copyBtn)
        view2.addSubview(shortURLText)
        view2.addSubview(qrCodeBtn)
        view2.addSubview(qrCodeImageView)
        view.addSubview(view2)
        qrCodeBtn.isHidden = true
        shortURLText.isHidden = true
        copyBtn.isHidden = true
        
     
    }
  

    @IBAction func onsubmitBtnClick(_ sender: UIButton){
        qrCodeBtn.isHidden = false
        shortURLText.isHidden = false
        copyBtn.isHidden = false
        if (sender.titleLabel?.text == "Shorten"){
            print("Hi")
        }
        if (sender.titleLabel?.text == "Reset"){
            longURLText.text = ""
            shortURLText.text = ""
            shortenBtn.setTitle("Shorten", for: .normal)
            qrCodeBtn.isHidden = true
            shortURLText.isHidden = true
            copyBtn.isHidden = true
            qrCodeImageView.isHidden = true
            return
            
        }
            
            let longURL = longURLText.text!
            let context = AppDelegate.viewContext
            let addedURL = URL(context: context)
            addedURL.id = UUID()
            addedURL.longURL = Foundation.NSURL(string: longURL)
            
            guard let apiURL = Foundation.URL(string: "https://tinyurl.com/api-create.php?url=\(longURL)&api_token=\(API_KEY)")
            else {
                print("Invalid URL")
                return
            }
            URLSession.shared.dataTask(with: apiURL) { (data, response, error) in
                guard let data = data else {
                    print("Could not retrieve data")
                    return
                }
                if let sURL = String(data: data, encoding: .utf8) {
                    let s2URL = self.addURLDetails(for: sURL, addedURL: addedURL)
                    DispatchQueue.main.async { [self] in
                        addedURL.shortURL = Foundation.NSURL(string: s2URL)
                        
                        do {
                            let context = AppDelegate.viewContext
                            context.insert(addedURL)
                            try context.save()
                            self.shortURLText.isHidden = false
                            self.shortURLText.text = addedURL.shortURL?.absoluteString!
                            sender.setTitle("Reset", for: .normal)
                            self.shortURLText.isUserInteractionEnabled = true
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openURL(_:)))
                            shortURLText.addGestureRecognizer(tapGesture)
                        } catch {
                            print("Error saving context: \(error)")
                        }
                    }
                }
            }.resume()
    }
    
    func generateRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    func addURLDetails(for sURL: String, addedURL: URL) -> String{
        let randomString = generateRandomString(length: 3)
        if let shortenedURL = Foundation.NSURL(string: sURL), let urlString = shortenedURL.absoluteString {
            let urlComponents = URLComponents(string: urlString)
            
            guard let alias = urlComponents?.url?.pathComponents.last else {
                print("Error: Unable to extract domain or alias from URL")
                return ""
            }
            
            let jsonPayload: [String: Any] = [
                "url": addedURL.longURL?.absoluteString! ?? "",
                "domain": "tinyurl.com",
                "alias": alias+randomString,
                "tags": "example,link",
                "expires_at": "2024-10-25 10:11:12",
        
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonPayload) else {
                print("step 1")
                return ""
            }
            let string2 = "https://api.tinyurl.com/create?api_token=\(API_KEY)"
            
            var request = URLRequest(url: Foundation.URL(string: string2)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                
                DispatchQueue.main.async {
                    do{
                        if let error = error {
                            print("Error: \(error)")
                            return
                        }
                        guard let httpResponse = response as? HTTPURLResponse else {
                            print("Error: Invalid response")
                            return
                        }
                        print("Status code: \(httpResponse.statusCode)")
                        
                        if let data = data, let responseData = String(data: data, encoding: .utf8) {
                            print("Response data: \(responseData)")
                        }
                        else {
                            print("Error: Unable to parse data as UTF-8 string")
                        }
                    }
                }
            }.resume()
        }
        return sURL+randomString
    }
    @IBAction func onNextScreenBtnTapped(_ sender: UIButton){
        performSegue(withIdentifier: "showDetails", sender: self)
    }
    
    @IBAction func oncopyBtnClick(_ sender: UIButton){
        UIPasteboard.general.string = shortURLText.text
        
    }
    
    @objc func openURL(_ sender: UITapGestureRecognizer) {
        if let urlString = shortURLText.text, let url = Foundation.URL(string: urlString) {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }
    func qrCode(inputMessage: String) -> UIImage {
        let qrCodeGenerator = CIFilter(name: "CIQRCodeGenerator")
        qrCodeGenerator!.setValue(inputMessage.data(using: .utf8), forKey: "inputMessage")
        qrCodeGenerator!.setValue("H", forKey: "inputCorrectionLevel")
        let ciImage = (qrCodeGenerator?.outputImage!)!
        return UIImage(ciImage: ciImage)
    }
    @IBAction func ongenerateQRBtnClick(_ sender: UIButton){
        qrCodeImageView.image = UIImageView(image: qrCode(inputMessage: shortURLText.text!)).image
    }
}
