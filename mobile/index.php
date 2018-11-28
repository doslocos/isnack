<?php
require_once'db.php';
if (isset($_POST['menu'])) {
    $vendor = $_POST['menu'];
    echo json_encode(db::getProducts($vendor));
}
else if (isset($_POST['product'])) {
    $json = $_POST['product'];
    if (isset($_POST['insert'])) {
        echo db::insertProduct($json);
    }
    else if (isset($_POST['update'])) {
        echo db::updateProduct($json);
    }
}
else if (isset($_POST['vendor'])) {
    $json = $_POST['vendor'];
    if (isset($_POST['insert'])) {
        echo db::insertVendor($json);
    }
    else if (isset($_POST['update'])) {
        echo db::updateVendor($json);
    }
}
else if (isset($_POST['email'], $_POST['password'])) {
    $em = $_POST['email'];
    $pw = $_POST['password'];
    if (isset($_POST['username'])) {
        $un = $_POST['username'];
        echo db::signup($un, $em, $pw);
    } else if (isset($_POST['sync'])) {
        echo db::sync($em, $pw);
    } else {
        echo db::login($em, $pw);
    }
}
?>
