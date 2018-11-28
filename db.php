<?php
isset($_SESSION) or session_start();
//robust database class offering secure logins/signups and persistent connections without a session
class db {
    private static $db; //singleton variable: used to store mysqli connection until php script dies
    public static function &get(): mysqli {
        if (!self::$db) self::mysqliConnect(); //create mysqli unless one is active in at self::$db
        return self::$db;
    }
    private static function mysqliConnect(): void { //assigns new mysqli to private static var self::$db
        self::$db = new mysqli('rsummerl.create.stedwards.edu', 'rsummerl_in', 't5Go+z7aW5wq', 'rsummerl_doslocos');
        if (self::$db->connect_error) exit("db connection failed: " . self::$db->connect_error);
    }
    //prepared sql statement looks for exactly one record with the given email and verifies password
    public static function login(string $email, string $password): bool {
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
                    $_SESSION['id'] = $id; $_SESSION['email'] = $email; $_SESSION['username'] = $username;
                    return true;
                }
            }
        }
        return false;
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
    public static function signup(string $username, string $email, string $password): bool {
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
                return db::login($email, $password);
            }
        }
        return false;
    }
    //executes a line of sql and returns results/records as an encoded json string. note that this
    //method should remain PRIVATE, with more controlled public functions using it as a go-between
    public static function sql(string $query): array {
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
    //attempt to insert the json-encoded Product object passed in as parameter $json. return OK or error
    public static function insertProduct($cost, $name, $details, $vendor) {
        $insert = "INSERT
        INTO`Product`VALUES(0,$cost,\"$name\",\"$details\",0,0,\"\",$vendor);";
        return self::get()->query($insert);
    }
    //simple update for use with live table editing via ajax, e.g. UPDATE $table SET $field=$value $where
    public static function update($table, $field, $value, $where) {
        $update = "UPDATE`$table`SET`$field`='$value'WHERE`id`=$where;";
        return self::get()->query($update);
    }
    //attempt to insert the json-encoded Vendor object passed in as parameter $json. return OK or error
    public static function insertVendor($name, $address, $details, $account): bool {
        $insert = "INSERT
        INTO`Vendor`VALUES(0,\"$name\",\"$address\",\"$details\",0.0,0.0,$account);";
        return self::get()->query($insert);
    }
    //attempt to insert the json-encoded Vendor object passed in as parameter $json. return OK or error
    public static function insertEmployee($name, $email, $phone, $wage, $account, $vendor): bool {
        $insert = "INSERT
        INTO`Employee`VALUES(0,\"$name\",\"$email\",\"$phone\",now(),null,$wage,0,$account, $vendor);";
        return self::get()->query($insert);
    }
    //mass-getter for all vendors currently in the database
    public static function populate($account): bool {
        if (!isset($_SESSION, $_SESSION['id']) || $_SESSION['id'] != $account) return false;
        $_SESSION['employees'] = db::sql("select`Employee`.id,`Employee`.name,`Employee`.email,`Employee`.phone,`Employee`.wage,`Employee`.hours_worked
        as`Hours This Week`,`Vendor`.name
        as`Vendor`from`Employee`,`Vendor`where`Employee`.vendor=`Vendor`.id
        and`Vendor`.account=$account;");
        $_SESSION['products'] = db::sql("select`Product`.id,`Product`.name,`Product`.details,`cost`,`quantity`,`Vendor`.name
        as`Vendor`from`Product`,`Vendor`where`Product`.vendor=`Vendor`.id
        and`Vendor`.account=$account;");
        $_SESSION['vendors'] = db::sql("select`id`,`name`,`address`,`details`from`Vendor`where`Vendor`.account=$account;");
        return true;
    }
    //store a picture file as "text" in the database using base64. postponed until basic functionality
    public static function store(string $source_path): bool {
        $destination_path = __DIR__.'/../'.$id.'/';
        if (!is_dir($destination_path)) mkdir($destination_path);
        $i = time() + microtime();
        $b64 = base64_encode(file_get_contents($source_path));
        $sql = "INSERT
        INTO`Resource`VALUES($id,'$b64');";
        return self::get()->query($sql);
    }
    //draws a table from an associative array
    public function table(array $data): string {
        if (!$data || !$data[0]) return 'No data!';
        $string = '<table class="table responsive" id="dataTable"><thead><tr id="header">';
        foreach ($data[0] as $key => $val) $string .= "<th>".ucwords($key)."</th>";
        $string .= '</tr></thead><tbody>';
        foreach ($data as $row) {
            $string.= '<tr>';
            foreach($row as $key => $val) $string .= "<td id=\"$key\">$val</td>";
            $string .= '</tr>';
        }
        $string .= '</tbody></table>';
        return $string;
    }
    //update all mutable fields of an Employee to match the json-encoded object passed in as $json (mobile)
    public static function updateEmployee(string $json): bool {
        $employee = json_decode($json, false, 4);
        $id = $employee->id;
        $name = $employee->name;
        $email = $employee->email;
        $phone = $employee->phone;
        $join_date = $employee->join_date;
        $left_date = $employee->left_date;
        $wage = $employee->wage;
        $hours_worked = $employee->hours_worked;
        $account = $employee->account;
        $vendor = $employee->vendor;
        $update = "UPDATE`Employee`SET
        `name`=$name,
        `email`=\"$email\",
        `phone`=\"$phone\",
        `join_date`=\"$join_date\",
        `left_date`=\"$left_date\",
        `wage`=$wage,
        `hours_worked`=$hours_worked,
        `account`=$account,
        `vendor`=$vendor,
         WHERE`id`=$id;";
         echo self::get()->query($update);
    }
    //update all mutable fields of a Product to match the json-encoded object passed in as $json (mobile)
    public static function updateProduct(string $json): bool {
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
        echo self::get()->query($update);
    }
    //update all mutable fields of a Vendor to match the json-encoded object passed in as $json (mobile)
    private static function updateVendor(string $json): bool {
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
        echo self::get()->query($update);
    }
}