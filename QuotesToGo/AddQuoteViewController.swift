//
//  AddQuoteViewController.swift
//  QuotesToGo
//

import UIKit

class AddQuoteViewController: UIViewController, UITextViewDelegate, NSLayoutManagerDelegate {


    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var test: UIImageView!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var quoteTextView: UITextView!
    @IBOutlet weak var donebutton: UIButton!
    @IBOutlet weak var backButton: UIButton!

    var randomQuotes: NSArray!
    var selectedRandomQuote:Dictionary<String,String>!
    var moc:NSManagedObjectContext!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        quoteTextView.delegate = self
        quoteTextView.layoutManager.delegate = self
        self.createBorder()

        moc = CoreDataHelper.managedObjectContext()
    }


    func createBorder() {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor(white: 0.95, alpha: 1.0).CGColor
        borderLayer.lineWidth = 24
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.path = UIBezierPath(rect: self.view.bounds).CGPath
        self.borderView.layer.addSublayer(borderLayer)

    }


    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Enter quote here" {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
    }


    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter quote here"
            textView.textColor = UIColor(white: 0.8, alpha: 1.0)
        }
    }


    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 9
    }

    
    @IBAction func addNewQuote(sender: AnyObject) {
        quoteTextView.resignFirstResponder()
        authorTextField.resignFirstResponder()
        if quoteTextView.text != "" && quoteTextView.text != "Enter quote here" {
            donebutton.enabled = false
            backButton.enabled = false
            let quoteObject = CoreDataHelper.inserManagedObject(NSStringFromClass(Quote), managedObjectContext: moc) as! Quote
            quoteObject.content = quoteTextView.text
            quoteObject.createdAt = NSDate()

            var authorString = authorTextField.text! as NSString
            if authorString == "" {
                authorString = "Unknown"
            }

            let lastCharacter = authorString.substringFromIndex(authorString.length - 1)
            if lastCharacter == " " {
                authorString = authorString.substringToIndex(authorString.length - 1)
            }

            AuthorManager.addAuthor(authorString as String, completion: { (author) -> () in
                quoteObject.author = author
                try! self.moc.save()
                self.navigationController?.popViewControllerAnimated(true)
            })
        } else {
            let alert = UIAlertController(title: "Quote missing", message: "Please enter a quote", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }


    @IBAction func getRandomQuote(sender: AnyObject) {
        randomQuotes = QuoteHelper.initRandomQuotes()
        selectedRandomQuote = QuoteHelper.getRandomQuote(randomQuotes)
        authorTextField.text = selectedRandomQuote["author"]
        quoteTextView.text = selectedRandomQuote["quote"]
    }


    @IBAction func dismiss(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }


}
