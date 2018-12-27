import UIKit
import MapKit
class Menu Controller: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var selectedVendor : Vendor?

    override func viewDidAppear(_ animated: Bool) {

        // Create coordinates from Vendor lat/long
        var poiCoordinates = CLLocationCoordinate2D()
        poiCoordinates.latitude = CDouble(self.selectedVendor!.latitude!)!
        poiCoordinates.longitude = CDouble(self.selectedVendor!.longitude!)!

        // Zoom to region
        let viewRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(poiCoordinates, 750, 750)
        self.mapView.setRegion(viewRegion, animated: true)

        // Plot pin
        let pin: MKPointAnnotation = MKPointAnnotation()
        pin.coordinate = poiCoordinates
        self.mapView.addAnnotation(pin)

        //add title to the pin
        pin.title = selectedVendor!.name
    }
}
