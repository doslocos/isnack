import UIKit

class DisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var notesCollection: UICollectionView!
    var username : String?
    var userImages : [UIImage] = []
    var userResources : NSArray = []
    
    @IBOutlet weak var lblUsername: UILabel!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getResources()
        print(userResources)
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        notesCollection.collectionViewLayout = layout
        notesCollection.backgroundColor = UIColor.black
        notesCollection.alwaysBounceVertical = true
        
        (!username!.isEmpty) ? lblUsername.text = username!.uppercased() : getUsername()
        if (userImages.isEmpty){
            getLocalUserImages()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCell", for: indexPath) as! NotesCollectionViewCell
        cell.backgroundColor = UIColor.black
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 0.5
        cell.frame.size.width = screenWidth / 3
        cell.frame.size.height = screenWidth / 3
        cell.notesImageView.image = userImages[indexPath.row]
        return cell
    }
        
    func getLocalUserImages(){
        let fileManager = FileManager.default
        let userFilePath = fileManager.currentDirectoryPath
        let userImagePaths = fileManager.subpaths(atPath: userFilePath)!
        for imagePath in userImagePaths {
            if let imageData = fileManager.contents(atPath: imagePath){
                if let imageUIImage = UIImage(data: imageData){
                    if (!userImages.contains(imageUIImage)){
                        userImages.append(imageUIImage)
                    }
                }
            }
        }
        notesCollection.reloadData()
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem){
        performSegue(withIdentifier: "backSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backSegue"{
            let camVC = segue.destination as! CameraViewController
            camVC.imgImageView.image = nil
        }
    }

    func getUserImagesFromData(data: NSArray){
        for datum in data {
            let imageData = datum as! Data
            let image = UIImage(data: imageData)!
                if !userImages.contains(image) {
                    userImages.append(image)
                }
        }
        notesCollection.reloadData()
    }

    func getUsername(){
        let fileManager = FileManager.default
        let userFilePath = fileManager.currentDirectoryPath
        let lastPathComponent = (userFilePath as NSString).lastPathComponent
        if (username != lastPathComponent){
            username = lastPathComponent
            lblUsername.text = username!.uppercased()
        }
    }
}
