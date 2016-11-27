//
//  WelcomeViewController.swift
//  QuotesToGo
//

import UIKit
import CoreData



class WelcomeViewController: UIViewController {

    var randomQuote: NSArray!
    var selectedRandomQuote:Dictionary<String,String>!
    var moc:NSManagedObjectContext!

    @IBOutlet weak var ribbon: UIImageView!
    @IBOutlet weak var dailyQuoteTextView: QuotesTextView!
    @IBOutlet weak var dailyQuoteAuthor: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var saveQuoteButton: UIButton!
    
    // Constraint outlets for animation
    @IBOutlet weak var quoteToGoLabelCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var quoteWidthConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        if let path = NSBundle.mainBundle().pathForResource("DailyQuotes", ofType: "plist") {
            randomQuote = NSArray(contentsOfFile: path)

        }

        moc = CoreDataHelper.managedObjectContext()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        chooseRandomQuote()
        
    }
    
    func chooseRandomQuote() {
        let randomQuoteIndex = Int(arc4random_uniform(UInt32(randomQuote.count)))
        selectedRandomQuote = randomQuote.objectAtIndex(randomQuoteIndex) as! Dictionary<String,String>
        dailyQuoteAuthor.text = selectedRandomQuote["author"]
        dailyQuoteTextView.text = selectedRandomQuote["quote"]
    }

    @IBAction func saveRandomQuote(sender: AnyObject) {

        let button = sender as! UIButton
        button.setTitle("Saving...", forState: .Normal)
        button.enabled = false
        getStartedButton.enabled = false

        UIView.animateWithDuration(0.2) { () -> Void in
            button.backgroundColor = UIColor(red: 0.6, green: 0.84, blue: 0.29, alpha: 1.0)
            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        }


        let quote = CoreDataHelper.inserManagedObject(NSStringFromClass(Quote), managedObjectContext: moc) as! Quote
        quote.content = selectedRandomQuote["quote"]
        quote.createdAt = NSDate()

        AuthorManager.addAuthor(selectedRandomQuote["author"]!) { (author:Author!) -> () in
            quote.author = author
            try! self.moc.save()

            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                button.setTitle("Quote Saved", forState: .Normal)
                self.performSegueWithIdentifier("getStarted", sender: self)
            }
        )}
    }
    
}

