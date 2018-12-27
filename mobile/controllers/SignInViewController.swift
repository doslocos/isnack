import UIKit

class SignInViewController: UIViewController {
    
    var username:String = ""
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBAction func btnSignIn(_ sender: UIButton)
    {
        let username = txtUsername.text!
        let password = txtPassword.text!
        if (username == "" || password == "") {
            let alertController = UIAlertController(title: "Blank Fields", message: "username or password field empty", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }

        let request = NSMutableURLRequest(url: NSURL(string: "https://weiot.us/img")! as URL)
        request.httpMethod = "POST"
        let postString = "a=\(username)&b=\(password)"
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
                if (responseString! == "Success")
                {
                    let fileManager = FileManager.default
                    let usersDirectoryPath = fileManager.currentDirectoryPath
                    print("Current Path : \(usersDirectoryPath)")
                    let usernameDirectoryPath = usersDirectoryPath + "/" + username + "/"
                    
                    labelDIR_Change:
                    if !fileManager.changeCurrentDirectoryPath(usernameDirectoryPath){
                        print("Change to usernameDirectory first attempt FAILURE")
                        if !FileManager.default.fileExists(atPath: usernameDirectoryPath){
                            print("no files exist atPath: \(username)")
                            do{
                                print("CREATING directory for username \(username)")
                                try FileManager.default.createDirectory(atPath: usernameDirectoryPath, withIntermediateDirectories: true, attributes: nil)
                                print("Directory for username \(username) CREATED")
                            } catch { //temp?
                                print("ERROR: using temp dir")
                                FileManager.default.changeCurrentDirectoryPath(FileManager.default.temporaryDirectory.path)
                                break labelDIR_Change
                            }
                        }
                        if fileManager.changeCurrentDirectoryPath(usernameDirectoryPath) {
                            print("Change to usernameDirectory second attempt SUCCESS")
                            self.username = username
                            self.signInAlert()
                        } else { //FailureCase Final: Use Temp DIR
                            print("ERROR: using temp dir unexpectedly")
                            FileManager.default.changeCurrentDirectoryPath(FileManager.default.temporaryDirectory.path)
                            self.username = "tempUser"
                            self.signInAlert()
                        }
                    }
                    else {
                        print("Change to userDirectory first attempt SUCCESS")
                        self.username = username
                        self.signInAlert()
                    }
                print(fileManager.currentDirectoryPath)
                }
                else {
                    let alertController = UIAlertController(title: "Login Failure", message: "Incorrect uername or password", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            self.txtUsername.text = ""
            self.txtPassword.text = ""
            }
        }
        task.resume()
        
    }
    
    func signInAlert()
    {
        let signInAlertController = UIAlertController(title: "Sign In Success", message: "Welcome", preferredStyle: UIAlertControllerStyle.alert)
        
        let signInAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default,
            handler: { action in self.performSegue(withIdentifier: "signInSegue",sender: self)
            signInAlertController.dismiss(animated: true, completion: nil) })
        
        signInAlertController.addAction(signInAction)
        self.present(signInAlertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInSegue" {
            let cameraViewController = segue.destination as! CameraViewController
            cameraViewController.username = self.username
        }
    }
    func createUserFile()
    {
        let fileManager = FileManager.default
        let directoryPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = directoryPaths[0]
        let usersDirectoryPath = documentsURL.appendingPathComponent("users").path
        labelDIR_Change:
            if !fileManager.changeCurrentDirectoryPath(usersDirectoryPath){
            print("Change to users Directory first attempt FAILURE")
            if !FileManager.default.fileExists(atPath: usersDirectoryPath){
                print("no files exist atPath: users")
                do{
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
        }
        else {
            print("Change to users Directory first attempt SUCCESS")
        }
    }  
}

