import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SnackerProtocol  {
    var feedItems: NSArray = NSArray()
    var selectedVendor : Vendor = Vendor()
    @IBOutlet weak var listTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableView.delegate = self
        self.listTableView.dataSource = self

        let snacker = snacker()
        snacker.delegate = self
        snacker.downloadItems()
    }

    func itemsDownloaded(items: NSArray) {
        feedItems = items
        self.listTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "BasicCell"
        let myCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
        // Get the vendor to be shown
        let item: vendor = feedItems[indexPath.row] as! Vendor
        // Get references to labels of cell
        myCell.textLabel!.text = item.address

        return myCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set selected vendor to var
        vendor = feedItems[indexPath.row] as! Vendor
        // Manually call segue to detail view controller
        self.performSegue(withIdentifier: "detailSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get reference to the destination view controller
        let detailVC  = segue.destination as! DetailViewController
        // Set the property to the selected vendor so when the view for
        // detail view controller loads, it can access that property to get the feeditem obj
        detailVC.selectVendor = selectedVendor
    }

}

