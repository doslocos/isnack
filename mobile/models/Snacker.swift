import UIKit

protocol SnackerProtocol: class {
    func itemsDownloaded(items: NSArray)}

class Snacker: User {

    weak var delegate: SnackerProtocol!
    let urlPath = "http://yourapproadmap.com/gitRdun.php" //this will be changed to the path where service.php lives

    func downloadItems() {
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        let task = defaultSession.dataTask(with: url) { (data, response, error) in

            if error != nil {
                print("Failed to download data")
            } else {
                print("Data downloaded")
                self.parseJSON(data!)
            }
        }
        task.resume()
    }

    func parseJSON(_ data:Data) {

        var jsonResult = NSArray()

        do{
            jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray

        } catch let error as NSError {
            print(error)

        }

        var jsonElement = NSDictionary()
        let vendors = NSMutableArray()

        for i in 0 ..< jsonResult.count
        {
            jsonElement = jsonResult[i] as! NSDictionary
            let vendor = vendor()

            //check to ensure that none of the JsonElement values are nil through optional binding
            if let name = jsonElement["Name"] as? String,
                let address = jsonElement["Address"] as? String,
                let latitude = jsonElement["Latitude"] as? String,
                let longitude = jsonElement["Longitude"] as? String
            {
                vendor.name = name
                vendor.address = address
                vendor.latitude = latitude
                vendor.longitude = longitude
            }
            vendors.add(vendor)
        }

        DispatchQueue.main.async(execute: { () -> Void in
            self.delegate.itemsDownloaded(items: vendors)
        })
    }
}
