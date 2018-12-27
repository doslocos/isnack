import UIKit
import MobileCoreServices

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var operationToolbar: UIToolbar!
    var username:String?
    @IBOutlet weak var lblUsername: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!username!.isEmpty){
            lblUsername.text = username!.uppercased()
        } else {
            getUsername()
        }
        configureToolbar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBOutlet weak var imgImageView: UIImageView!
    var imagePicker : UIImagePickerController!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        self.imgImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnUseCamera(_ sender: UIBarButtonItem)
    {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera){ imagePicker.sourceType = .camera
            if UIImagePickerController.isCameraDeviceAvailable(.rear){ imagePicker.cameraDevice = .rear
            } else {imagePicker.cameraDevice = .front}
        } else{ imagePicker.sourceType = .photoLibrary }
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func unwindToCameraViewController(segue:UIStoryboardSegue) { }
    @IBAction func btnDisplayCollections(_ sender: Any)
    {
        performSegue(withIdentifier:"displaySegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displaySegue" {
            let displayViewController = segue.destination as! DisplayViewController
            displayViewController.username = self.username!
        }
    }
    
    @IBAction func btnSave(_ sender: UIBarButtonItem)
    {
        if self.imgImageView.image != nil{ newNoteAlertAction() }
        else {
            let dialog = UIAlertController(title: "Nil Image", message: "Take a photo, then save", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(dialog, animated: true)
        }
    }
    
    func saveAndUploadImage(imageName: String)
    {
        let image = imgImageView.image!
        let imageData:Data = UIImagePNGRepresentation(image)!
        let fileManager = FileManager.default
        let currentUserDirectoryURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let imageFileURL = currentUserDirectoryURL.appendingPathComponent("\(imageName)")
        if !fileManager.fileExists(atPath: imageFileURL.path)
        {
            do{ try imageData.write(to: imageFileURL)
                    saveSuccessAlert()
            } catch{
                saveFailureAlert()
            }
        }
        else{ renameImageFile() }
        
        let userName = username!
        let base64 = imageData.base64EncodedString()
        let postString = "a=\(imageName)&b=\(base64)&c=\(userName)"
        addResource(postString: postString)
    }
    
    func addResource(postString: String) -> Void
    {
        let request = NSMutableURLRequest(url: NSURL(string: "https://rsummerl.create.stedwards.edu/doslocos.php")! as URL)
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {
            data, response, error in
            if error != nil {
                print("error=\(error!)")
                return
            }
            print("response=\(response!)")
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString=\(responseString!)")
            DispatchQueue.main.async()
            {
                if (responseString! == "Success"){print("Successful Image Upload")}
                else{self.storeImageFailureAlert()}
            }
        }; task.resume()
    }
    
    func saveSuccessAlert()
    {
        let saveSuccessAlertController = UIAlertController(title: "Save Successful", message: "Local Image File Created", preferredStyle: UIAlertControllerStyle.alert)
        let saveImageAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            action in self.performSegue(withIdentifier: "displaySegue", sender: self)
            saveSuccessAlertController.dismiss(animated: true, completion: nil)
        })
        saveSuccessAlertController.addAction(saveImageAction)
        self.present(saveSuccessAlertController, animated: true, completion: nil)
    }

    func saveFailureAlert()
    {
        print("Write to file failed")
        let alertController = UIAlertController(title: "Save Failed", message: "Image File Not Created", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    func storeImageSuccessAlert()
    {
        let storeImageSuccessAlertController = UIAlertController(title: "Upload Successful", message: "Hooray. Image File Uploaded", preferredStyle: UIAlertControllerStyle.alert)
        let storeImageAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            action in //self.performSegue(withIdentifier: "displaySegue", sender: self)
            storeImageSuccessAlertController.dismiss(animated: true, completion: nil) })
        storeImageSuccessAlertController.addAction(storeImageAction)
        self.present(storeImageSuccessAlertController, animated: true, completion: nil)
    }

    func storeImageFailureAlert()
    {
        let storeImageFailureAlertController = UIAlertController(title: "Save Failed", message: "Image Not Uploaded", preferredStyle: UIAlertControllerStyle.alert)
        storeImageFailureAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(storeImageFailureAlertController, animated: true, completion: nil)
    }

    func newNoteAlertAction()
    {
        let saveImageAlertController = UIAlertController(title: "New Note", message: "Apply an Image Name", preferredStyle: .alert)
        saveImageAlertController.addTextField()
        saveImageAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let saveAction = UIAlertAction(title: "Save", style: .default)
        {
            [unowned self] action in
            
            if let inputImageName = saveImageAlertController.textFields?.first?.text{
                let imageName = inputImageName
                self.saveAndUploadImage(imageName: "\(imageName).png")
            }
        }
        saveImageAlertController.addAction(saveAction)
        present(saveImageAlertController, animated: true)
    }

    func renameImageFile()
    {
        let renameImageAlertController = UIAlertController(title: "Note Name Unavailable", message: "Apply a New Image Name", preferredStyle: .alert)
        renameImageAlertController.addTextField()
        renameImageAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let saveAction = UIAlertAction(title: "Save", style: .default)
        {
            [unowned self] action in
            
            if let inputImageName = renameImageAlertController.textFields?.first?.text{
                let imageName = inputImageName
                self.saveAndUploadImage(imageName: "\(imageName).png")
            }
        }
        renameImageAlertController.addAction(saveAction)
        present(renameImageAlertController, animated: true)
    }

    func getUsername()
    {
        let fileManager = FileManager.default
        let userFilePath = fileManager.currentDirectoryPath
        let lastPathComponent = (userFilePath as NSString).lastPathComponent
        if self.username != lastPathComponent {
            self.username = lastPathComponent.uppercased()
        }
    }
    
    func configureToolbar(){
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        for item in operationToolbar.items! {
            var index: CGFloat = 0.0
            item.width = screenWidth/3.0
            let offset = UIOffset(horizontal: (0.33*index*screenWidth), vertical: 0.0)
            item.setTitlePositionAdjustment(offset, for: UIBarMetrics.default)
            index += 1.0
        }
    }
}

