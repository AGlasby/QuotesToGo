//
//  AllQuotesViewController.swift
//  QuotesToGo
//


import UIKit

class AllQuotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var ribbonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var ribbon: UIImageView!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var quotesTableView: UITableView!
    
    @IBOutlet weak var searchButton: UIButton!
    
    var moc:NSManagedObjectContext!
    var quotesList = [Quote]()
    var searchMenu:QuoteSearchView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        quotesTableView.delegate = self
        quotesTableView.dataSource = self
        quotesTableView.separatorStyle = .None
        quotesTableView.showsVerticalScrollIndicator = false

        createBorder()

        moc = CoreDataHelper.managedObjectContext()

        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AllQuotesViewController.persistentStoreDidChange), name: NSPersistentStoreCoordinatorStoresDidChangeNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AllQuotesViewController.persistentStoreWillChange(_:)), name: NSPersistentStoreCoordinatorStoresWillChangeNotification, object: self.moc.persistentStoreCoordinator)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AllQuotesViewController.receiveICloudChanges(_:)), name: NSPersistentStoreDidImportUbiquitousContentChangesNotification, object: self.moc.persistentStoreCoordinator)
        }
        loadData()
    }

    func persistentStoreDidChange() {
        loadData()
    }

    func persistentStoreWillChange(notification: NSNotification) {
        moc.performBlock{ () -> Void in
            if self.moc.hasChanges {
                do {
                    try self.moc.save()
                    self.moc.reset()
                } catch {
                    print(error)
                }
            }
        }
    }

    func receiveICloudChanges(notification:NSNotification) {
        moc.performBlock { () -> Void in
            self.moc.mergeChangesFromContextDidSaveNotification(notification)
            self.loadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }

    func createBorder() {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor(white: 0.95, alpha: 1.0).CGColor
        borderLayer.lineWidth = 24
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.path = UIBezierPath(rect: self.view.bounds).CGPath

        self.borderView.layer.addSublayer(borderLayer)

    }
    
    func loadData() {
        quotesList = [Quote]()
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        quotesList = CoreDataHelper.fetchEntities(NSStringFromClass(Quote), managedObjectContext: moc, predicate: nil, sortDescriptor: sortDescriptor) as! [Quote]
        quotesTableView.reloadData()
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotesList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! QuoteTableViewCell

        cell.selectionStyle = .None
        cell.backgroundColor = UIColor.clearColor()
        cell.backgroundView?.backgroundColor = UIColor.clearColor()

        if let quote = quotesList[indexPath.row] as Quote? {
            if let authObj = quote.author {
                cell.quoteLabel.text = quote.content
                cell.authorLabel.text = authObj.name

                let dateFormat = NSDateFormatter()
                dateFormat.dateFormat = "MMM d, yyyy"

                let dateString = dateFormat.stringFromDate(quote.createdAt!)
                cell.dataLabel.text = dateString

                if let imgData = authObj.image {
                    let image = UIImage(data: imgData)
                    cell.authorImageView.image = image
                } else {
                    cell.authorImageView.image = UIImage(named: "avatar")
                }

            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete quote") { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            let quoteToDelete = self.quotesList[indexPath.row]
            quoteToDelete.managedObjectContext!.deleteObject(quoteToDelete)
            try! self.moc.save()
            self.handleDelete(indexPath)
        }

        delete.backgroundColor = UIColor(red: 0.902, green: 0.31, blue: 0.306, alpha: 1.0)
        return [delete]
    }

    func handleDelete(indexPath: NSIndexPath) {
        self.quotesTableView.beginUpdates()
        quotesList.removeAtIndex(indexPath.row)
        self.quotesTableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.quotesTableView.endUpdates()

    }

    @IBAction func searchQuotes(sender: AnyObject) {

        let quoteSearch = (NSBundle.mainBundle().loadNibNamed("QuoteSearch", owner: self, options: nil)?.last) as! QuoteSearchView
        quoteSearch.frame = CGRectMake(0, -150, self.view.bounds.size.width, 150)
        quoteSearch.doneButton.addTarget(self, action: #selector(AllQuotesViewController.hideSearch), forControlEvents: .TouchUpInside)
        quoteSearch.searchTextField.delegate = self
        quoteSearch.searchTextField.becomeFirstResponder()


        searchMenu = quoteSearch

        self.view.addSubview(quoteSearch)
        self.ribbonTopConstraint.constant = 119

        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: { () -> Void in
            var newSearchMenuFrame = quoteSearch.frame
            newSearchMenuFrame.origin.y = -30
            quoteSearch.frame = newSearchMenuFrame
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    func hideSearch() {
        if let menu = searchMenu {
            loadData()
            ribbonTopConstraint.constant = 0
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .CurveEaseInOut, animations: { () -> Void in
                var newSearchFrame = menu.frame
                newSearchFrame.origin.y = -150
                menu.frame = newSearchFrame
                self.view.layoutIfNeeded()
                }, completion: { (success:Bool) -> Void in
                    menu.removeFromSuperview()
                    self.searchMenu = nil
            })
        }
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text! == "Search for quote or author" {
            textField.text = ""
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        searchFor(textField.text!)
        return true
    }

    func searchFor(searchString:String) {
        let predicate = NSPredicate(format: "content CONTAINS[c] %@ || ANY author.name CONTAINS[c] %@", searchString, searchString)
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        quotesList = [Quote]()
        quotesList = CoreDataHelper.fetchEntities(NSStringFromClass(Quote), managedObjectContext: moc, predicate: predicate, sortDescriptor: sortDescriptor) as! [Quote]
        quotesTableView.reloadData()

    }


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showQuote" {
            let quoteVC = segue.destinationViewController as! QuoteViewController
            if let indexPath = self.quotesTableView.indexPathForSelectedRow {
                quoteVC.quote = quotesList[indexPath.row]

            }
        }
    }

}
