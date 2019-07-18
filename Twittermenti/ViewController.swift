//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    var nsDictionary: NSDictionary?
    
    var swifter : Swifter?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            nsDictionary = NSDictionary(contentsOfFile: path)
            swifter = Swifter(consumerKey: nsDictionary!.value(forKey: "API Key") as! String, consumerSecret: nsDictionary!.value(forKey: "API Secret Key") as! String)
        }
    }

    @IBAction func predictPressed(_ sender: UIButton) {
        if let searchText = textField.text {
            swifter?.searchTweet(using: searchText, lang: "en", count: 100, tweetMode: .extended, success: {(results, metadata) in
                var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<100 {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                do {
                    let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
                    var sentimentScore = 0
                    for pred in predictions {
                        let sentiment = pred.label
                        
                        if sentiment == "Pos" {
                            sentimentScore += 1
                        } else if sentiment == "Neg" {
                            sentimentScore -= 1
                        }
                    }
                    print(sentimentScore)
                    if sentimentScore > 0 {
                        self.sentimentLabel.text = "😀"
                    } else {
                        self.sentimentLabel.text = "😝"
                    }
                } catch {
                    print("There was an error in predicting sentiment score")
                }
            }) { (error) in
                print("There was an error with the Twitter API Request")
            }
        }
    }
    
}

