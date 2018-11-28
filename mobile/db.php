<?php
//robust database class offering secure logins/signups and persistent connections without a session
class db {
    private static $db; //singleton variable: used to store mysqli connection until php script dies
    public static function &get(): mysqli {
        if (!self::$db) self::mysqliConnect(); //create mysqli unless one is active in at self::$db
        return self::$db;
    }
    private static function mysqliConnect(): void { //assigned new mysqli to private var self::$db
        self::$db = new mysqli('localhost', 'rsummerl_x', 'zh6x%Ji_9Efl', 'rsummerl_doslocos');
        if (self::$db->connect_error) exit("db connection failed: " . self::$db->connect_error);
    }
    //prepared sql statement looks for exactly one record with the given email and verifies password
    public static function login(string $email, string $password): string {
        if ($prep = self::get()->prepare('SELECT`id`,`username`,`password`FROM`Account`WHERE`email`=?
        LIMIT
        1')) {
            $prep->bind_param('s', $email);
            $prep->execute();
            $prep->store_result();
            if ($prep->num_rows === 1) {
                $prep->bind_result($id, $username, $db_pass); 
                $prep->fetch();
                if (password_verify($password, $db_pass)) { //hashes match
                    return "{\"id\":\"$id\",\"username\":\"$username\"}";
                }
            }
            return "Invalid login!";
        }
        exit(self::get()->error);
    }
    //used by the listener over in public_html to ensure no special characters were injected
    public static function scrub(string $url): string {
        if ('' == $url) return $url;
        $url = preg_replace('|[^a-z0-9-~+_.?#=!&;,/:%@$\|*\'()\\x80-\\xff]|i', '', $url);
        $strip = array('%0d', '%0a', '%0D', '%0A');
        $url = (string) $url;
        $count = 1;
        while ($count) $url = str_replace($strip, '', $url, $count);
        $url = str_replace(';//', '://', $url);
        $url = htmlentities($url);
        $url = str_replace('&amp;', '&#038;', $url);
        $url = str_replace("'", '&#039;', $url);
        if ($url[0] !== '/') return '';
        return $url;
    }
    //attempt to create new account; if successful, return vendor list, otherwise err message
    public static function signup(string $username, string $email, string $password): string {
        if ($prep = self::get()->prepare('SELECT`email`FROM`Account`WHERE`email`=?
        LIMIT
        1')) {
            $prep->bind_param('s', $email);
            $prep->execute();
            $prep->store_result();
            if ($prep->num_rows === 0) {
                $hash = password_hash($password, CRYPT_BLOWFISH);
                $sql = "INSERT
                INTO`Account`VALUES(0,'$username','$email','$hash');";
                if (!(self::get()->query($sql))) exit(self::get()->error);
                return json_encode(db::sql("SELECT`id`FROM`Account`WHERE`email`='$email';"));
            }
            return 'Email is Taken!';
        }
        exit(self::get()->error);
    }
    //executes a line of sql and returns results/records as an associative array. note that this
    //method should remain PRIVATE, with more controlled public functions using it as a go-between
    private static function sql(string $query): array {
        $results = self::get()->query($query);
        if (!$results) exit(self::get()->error);
        $records = array();
        while ($row = $results->fetch_assoc()) $records[] = $row;
        return $records;
    }
    //example of a public method that uses the sql() method above in a controlled, limited way
    public static function getProducts(string $vendor): array {
        return db::sql("select*from`Product`where`vendor`=$vendor;");
    }
    //update all mutable fields of a Product to match the json-encoded object passed in as $json
    public static function updateProduct(string $json): string {
        $product = json_decode($json, false, 4);
        $id = $product->id;
        $cost = $product->cost;
        $name = $product->name;
        $details = $product->details;
        $available = $product->available;
        $quantity = $product->quantity;
        $picture = $product->picture;
        $vendor = $product->vendor;
        $update = "UPDATE`Product`SET
        `cost`=$cost,
        `name`=\"$name\",
        `details`=\"$details\",
        `available`=$available,
        `quantity`=$quantity,
        `picture`=\"$picture\",
        `vendor`=$vendor
        WHERE`id`=$id;";
        return self::get()->query($update) ? 'OK' : self::get()->error;
    }
    //attempt to insert the json-encoded Product object passed in as parameter $json. return OK or error
    public static function insertProduct(string $json): string {
        $product = json_decode($json, false, 4);
        $cost = $product->cost;
        $name = $product->name;
        $details = $product->details;
        $available = $product->available;
        $quantity = $product->quantity;
        $picture = $product->picture;
        $vendor = $product->vendor;
        $insert = "INSERT
        INTO`Product`VALUES(0,$cost,\"$name\",\"$details\",$available,$quantity,\"$picture\",$vendor);";
        return self::get()->query($insert) ? 'OK' : self::get()->error;
    }
    //update all mutable fields of a Vendor to match the json-encoded object passed in as $json
    private static function updateVendor(string $json): string {
        $vendor = json_decode($json, false, 4);
        $id = $vendor->id;
        $name = $vendor->name;
        $address = $vendor->address;
        $latitude = $vendor->latitude;
        $longitude = $vendor->longitude;
        $account = $vendor->account;
        $update = "UPDATE`Vendor`SET
        `name`=\"$name\",
        `address`=\"$address\",
        `latitude`=$latitude,
        `longitude`=$longitude,
        `account`=$account
        WHERE`id`=$id;";
        return self::get()->query($update) ? 'OK' : self::get()->error;
    }
    //attempt to insert the json-encoded Vendor object passed in as parameter $json. return OK or error
    private static function insertVendor(string $json): string {
        $vendor = json_decode($json, false, 4);
        $name = $vendor->name;
        $address = $vendor->address;
        $latitude = $vendor->latitude;
        $longitude = $vendor->longitude;
        $account = $vendor->account;
        $insert = "INSERT
        INTO`Vendor`VALUES(0,\"$name\",\"$address\",$latitude,$longitude,$account);";
        return self::get()->query($insert) ? 'OK' : self::get()->error;
    }
    //mass-getter for all vendors currently in the database
    public static function getVendors(): array {
        return db::sql('select*from`Vendor`');
    }
    //store a picture file as "text" in the database using base64. postponed until basic functionality
    private static function store(string $source_path): void {
        $destination_path = __DIR__.'/../'.$id.'/';
        if (!is_dir($destination_path)) mkdir($destination_path);
        $i = time() + microtime();
        $b64 = base64_encode(file_get_contents($source_path));
        $sql = "INSERT
        INTO`Resource`VALUES($id,'$b64');";
        if (!(self::get()->query($sql))) exit(self::get()->error);
        file_put_contents($destination_path.$source_path, $data);
    }
    //like login or signup but does not return a free list of vendors, only confirms id and username
    public static function sync(string $email, string $password): string {
        if ($prep = self::get()->prepare('SELECT`password`FROM`Account`WHERE`email`=?
        LIMIT
        1')) {
            $prep->bind_param('s', $email);
            $prep->execute();
            $prep->store_result();
            if ($prep->num_rows === 1) {
                $prep->bind_result($db_pass); 
                $prep->fetch();
                if (password_verify($password, $db_pass)) {
                    return json_encode(db::getVendors());
                }
            }
        }
        exit(self::get()->error);
    }
}
