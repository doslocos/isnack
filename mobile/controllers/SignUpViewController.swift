import UIKit

class SignUpViewController: UIViewController {
    
    var username : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fileManager = FileManager.default
        let directoryPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = directoryPaths[0]
        let usersDirectoryPath = documentsURL.appendingPathComponent("users").path
        labelDIR_Change: //Check For Successful Change of Current DIR
            if !fileManager.changeCurrentDirectoryPath(usersDirectoryPath){
            print("Change to users Directory first attempt FAILURE")
            if !FileManager.default.fileExists(atPath: usersDirectoryPath){
                print("no files exist atPath: users")
                do {
                    print("CREATING users Directory")
                    try FileManager.default.createDirectory(atPath: usersDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                    print("users Directory")
                } catch { //Failure Case: Use Temp DIR
                    print("ERROR: using temp dir")
                    FileManager.default.changeCurrentDirectoryPath(FileManager.default.temporaryDirectory.path)
                    break labelDIR_Change
                }
            }
            if fileManager.changeCurrentDirectoryPath(usersDirectoryPath) {
                print("Change to users Directory second attempt SUCCESS")
            } else {
                print("ERROR: using temp dir unexpectedly")
            FileManager.default.changeCurrentDirectoryPath(FileManager.default.temporaryDirectory.path)
            }
        } else {
            print("Change to users Directory first attempt SUCCESS")
        }
    }

    @IBOutlet weak var lblSignUpError: UILabel!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPasswordConfirm: UITextField!
    @IBAction func btnSignUp(_ sender: UIButton)
    {
        let name = txtName.text!
        let username = txtUsername.text!
        let password = txtPassword.text!
        let password2 = txtPasswordConfirm.text!

        if (name == "" || username == "" || password == "") {
            lblSignUpError.text = "Empty fields!"
        }
        else if (password2 != password) {
            lblSignUpError.text = "Passwords do not match!"
            return
        }
        else {
            
            lblSignUpError.text = ""
   
            let request = NSMutableURLRequest(url: NSURL(string: "https://jyoung9.create.stedwards.edu/PhotoNotes/SignUp.php")! as URL)
           
            request.httpMethod = "POST"
            
            let postString = "a=\(name)&b=\(username)&c=\(password)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {

                data, response, error in
                
                if error != nil{
                    print("error=\(error!)")
                    return
                }
                print("response=\(response!)")
                
                let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("responseString=\(responseString!)")
                
                DispatchQueue.main.async()
                {
                    //check if username already exists
                    if (responseString! == "Success"){
                        let fileManager = FileManager.default
                        let usersDirectoryPath = fileManager.currentDirectoryPath
                        print("Current Path : \(usersDirectoryPath)")
                        let usernameDirectoryPath = usersDirectoryPath + "/" + username + "/"
                        
                        labelDIR_Change: //Check For Successful Change of Current DIR
                            if !fileManager.changeCurrentDirectoryPath(usernameDirectoryPath){
                            print("Change to usernameDirectory first attempt FAILURE")
                            if !FileManager.default.fileExists(atPath: usernameDirectoryPath){
                                print("no files exist atPath: \(username)")
                                do{
                                    print("CREATING directory for username \(username)")
                                    try FileManager.default.createDirectory(atPath: usernameDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                                    self.username = username
                                    print("Directory for username \(username) CREATED")
                                } catch { //Failure Case: Use Temp DIR
                                    print("ERROR: using temp dir")
                                    FileManager.default.changeCurrentDirectoryPath(FileManager.default.temporaryDirectory.path)
                                    self.username = "tempUser"
                                    break labelDIR_Change
                                }
                            }
                            if fileManager.changeCurrentDirectoryPath(usernameDirectoryPath) {
                                print("Change to usernameDirectory second attempt SUCCESS")
                                self.signUpAlert()
                            } else {
                                print("ERROR: using temp dir unexpectedly")
                                FileManager.default.changeCurrentDirectoryPath(FileManager.default.temporaryDirectory.path)
                                self.username = "tempUser"
                                self.signUpAlert()
                            }
                        }
                        else {
                            print("Change to userDirectory first attempt SUCCESS")
                            self.username = username
                            self.signUpAlert()
                        }
                        print(fileManager.currentDirectoryPath)
                    }
                    else {
                        let alertController = UIAlertController(title: "Cannot Create New Account", message: "Username Already Exists", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                    
                    self.txtUsername.text = ""
                    self.txtPassword.text = ""
                    self.txtPasswordConfirm.text = ""
                    self.txtName.text = ""
                    
                }
                
            }
            task.resume()
            
        }
        
    }
    
    func signUpAlert()
    {
        let signUpAlertController = UIAlertController(title: "New Account", message: "Successfully Added", preferredStyle: UIAlertControllerStyle.alert)
        let signUpAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            action in self.performSegue(withIdentifier: "signUpSegue", sender: self)
            signUpAlertController.dismiss(animated: true, completion: nil)
        })
        signUpAlertController.addAction(signUpAction)
        self.present(signUpAlertController, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signUpSegue"{
            let cameraViewController = segue.destination as! CameraViewController
            cameraViewController.username = self.username
        }
    }  
}

