let INVALID_LOGIN = -1, NET_ERROR = -2, UNKNOWN_ERROR = -3
class User: NSObject
{
    private var firstName: String                      //varchar(40)
    private var lastName: String                       //varchar(40)
    private var phoneNumber: String                    //varchar(20)
    private var email: String                          //varchar(80)
    private var password: String                       //varchar(80)
    private var index = 0 /* 0 => waiting for db to assign index) */
    
    public func getFirstName()   -> String {return firstName   }
    public func getLastName()    -> String {return lastName    }
    public func getPhoneNumber() -> String {return phoneNumber }
    public func getEmail()       -> String {return email       }
    public func getPassword()    -> String {return password    }
    public func getIndex()          -> Int {return index       }
    
    //note: the _ means you don\'t need a tag for the parameter, so
    //you can just type setFirstName("Bob"), not (firstName: "Bob")
    public func setFirstName  (_ x: String) { firstName   = x }
    public func setLastName   (_ x: String) { lastName    = x }
    public func setPhoneNumber(_ x: String) { phoneNumber = x }
    public func setEmail      (_ x: String) { email       = x }
    public func setPassword   (_ x: String) { password    = x }
    
    init(email: String, password: String)
    {
        firstName = ""; lastName = ""; phoneNumber = ""
        self.email = email; self.password = password;
        self.index = 1
    }
    
    //straight-up barfs the contents of a url as a String. name is on point
    public static func meme(_ urlString: String) -> String
    {
        let webpageURL = URL(string: urlString)!;
        guard let rv = try? String(contentsOf: webpageURL) else {return ""}
        return rv
    }
}
class db //the dream. let xs = db.fetch(query: "select*..."), x = xs[0]["key"]
{
    public static func fetch(query: String) -> [[String: String]]
    {
        var rv: [[String: String]]? = nil
        let fetchURL = URL(string: "https://rsummerl.create.stedwards.edu/sql.php")!
        var request = URLRequest(url: fetchURL); request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = query.data(using: .utf8) //request is prepared to send
        let sema = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: request)
        {
            data, response, error in //ridealong parameters for this task. bizarre syntax
            guard let data = data, error == nil else {return}
            if let callback = response as? HTTPURLResponse, callback.statusCode != 200
            {rv = [[String(describing: callback): String(describing: response)]]}
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([[String: String]].self, from: data)
            {rv = decoded;} else {rv = [[String: String]]()}; sema.signal()
        }
        task.resume(); _ = sema.wait(timeout: DispatchTime.distantFuture); return rv!
    }
    
    public static func isValidLogin(email: String, password: String) -> String
    {
        let sql = "sql=select`password`from`Account`where`email`='\(email)'"
        let fetched = fetch(query: sql)
        if fetched.count == 1 && fetched[0]["password"] == password {return "yes"}
        return "no"
    }
    
    public static func test() -> Double
    {
        var one_minute_timer = 60.0
        var queries_handled = 0
        var elapsed_seconds = 0.0
        while (one_minute_timer > 0)  {
            let start = DispatchTime.now()
            var output:String = isValidLogin(email: "user4", password: "pass4")
            queries_handled += 1
            var temp:String = User.meme("https://rsummerl.create.stedwards.edu/sql.php")
            queries_handled += 1
            output.append(temp)
            temp = String(describing: isValidLogin(email: "debug", password: "debug"))
            queries_handled += 1
            output.append(temp)
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            elapsed_seconds += Double(nanoTime) / 1_000_000_000
            output.append("\(queries_handled) queries handled in ~\(elapsedSeconds) seconds")
            one_minute_timer -= elapsedSeconds
            print(output)                }
        return one_minute_timer
    }
}
let _ = User(email: "e@mail.com", password: "mysqlilol")
let x = db.test()
print(String(x))

