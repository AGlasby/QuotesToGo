//
//  QuoteHelper.swift
//  QuotesToGo
//
//  Created by Alan Glasby on 27/11/2016.
//  Copyright © 2016 Daniel Autenrieth. All rights reserved.
//

import UIKit

class QuoteHelper: NSObject {

    class func initRandomQuotes() -> NSArray {
        var randomQuotes = NSArray!(nil)
        if let path = NSBundle.mainBundle().pathForResource("DailyQuotes", ofType: "plist") {
           randomQuotes = NSArray(contentsOfFile: path)
        }
        return randomQuotes
    }

    class func getRandomQuote(randomQuotes:NSArray) -> Dictionary<String,String> {
        let randomQuoteIndex = Int(arc4random_uniform(UInt32(randomQuotes.count)))
        let selectedRandomQuote = randomQuotes.objectAtIndex(randomQuoteIndex) as! Dictionary<String,String>
        return selectedRandomQuote
    }

}
