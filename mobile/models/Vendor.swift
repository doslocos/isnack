import UIKit

class Vendor: NSObject {
    var name: String?
    var address: String?
    var latitude: String?
    var longitude: String?

    override init() {}

    init(name: String, address: String, latitude: String, longitude: String) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }

    override var description: String {
        return "Name: \(name), Address: \(address), Latitude: \(latitude), Longitude: \(longitude)"
    }
}
