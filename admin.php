<?php
require_once'db.php';
isset($_SESSION) or exit(header('Location: portal.html'));
isset($_SESSION['id']) or exit(header('Location: logout.php'));
db::populate($_SESSION['id']);global $data, $view; $view = getView();
function getView() {
    global $data;
    if (isset($_GET['employees']))     {$data = $_SESSION['employees']; return 'Employee';}
    else if (isset($_GET['products'])) {$data = $_SESSION['products']; return 'Product';}
    else if (isset($_GET['vendors']))  {$data = $_SESSION['vendors']; return 'Vendor';}}?>
<!DOCTYPE html>
<html lang="en">

<head>
	<meta charset="utf-8"><meta content="IE=edge" http-equiv="X-UA-Compatible">
	<meta content="width=device-width, initial-scale=1, shrink-to-fit=no" name="viewport">
	<title>iSnack</title>
	<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.5.0/css/all.css" integrity="sha384-B4dIYHKNBt8Bc12p+WXckhzcICo0wtJAoU8YZTY5qE0Id1GSseTk6S+L3BlXeVIU" crossorigin="anonymous">
	<link href="css/bootstrap.min.css" rel="stylesheet"><link href="css/dataTables.bootstrap4.min.css" rel="stylesheet"><link href="css/jquery.dataTables.min.css" rel="stylesheet">
	<link href="css/isnack.min.css" rel="stylesheet"><link href="css/absolution.css" rel="stylesheet">
	<script src="js/jquery-3.3.1.min.js"></script><script src="js/jquery.dataTables.min.js"></script><script src="js/bootstrap.min.js"></script><script src="js/dataTables.bootstrap4.min.js"></script>
    <script src="js/isnack.min.js"></script><script src="js/fontawesome.min.js"></script>
</head>

<body id="page-top" style="background-image: url(https://rsummerl.create.stedwards.edu/a.jpg); background-repeat: no-repeat; margin: 20px">
    
	<div class="row">
		<div class="col-xl-3 col-sm-6 mb-3">
			<div class="card text-white bg-primary o-hidden h-100" style="<?=isset($_GET['employees']) ? 'border: 2px black solid' : 'border: 0'?>">
				<div class="card-body">
				    <div class="card-body-icon">
						<i class="fas fa-fw fa-comments"></i>
					</div><a href='admin.php?employees'><div class="mr-5">Employees: <?=count($_SESSION['employees'])?></div></a>
				</div>
                <div id="employees" class="card-footer text-white clearfix small z-1" style="color:white"><span id="em" class="float-left">Add Employee</span> 
				<span class="float-right"><i class="fas fa-angle-right"></i></span></div>
			</div>
		</div>
		<div class="col-xl-3 col-sm-6 mb-3">
			<div class="card text-white bg-warning o-hidden h-100" style="<?=isset($_GET['vendors']) ? 'border: 2px black solid' : 'border: 0'?>">
				<div class="card-body">
					<div class="card-body-icon">
						<i class="fas fa-fw fa-list"></i>
					</div><a href='admin.php?vendors'><div class="mr-5">Vendors: <?=count($_SESSION['vendors'])?></div></a>
				</div>
				<div  id="vendors" class="card-footer text-white clearfix small z-1" style="color:white"><span id="ve" class="float-left">Add Vendor</span> 
				<span class="float-right"><i class="fas fa-angle-right"></i></span></div>
			</div>
		</div>
		<div class="col-xl-3 col-sm-6 mb-3">
			<div class="card text-white bg-success o-hidden h-100" style="<?=isset($_GET['products']) ? 'border: 2px black solid' : 'border: 0'?>">
				<div class="card-body">
					<div class="card-body-icon">
						<i class="fas fa-fw fa-shopping-cart"></i>
					</div><a href='admin.php?products'><div class="mr-5">Products: <?=count($_SESSION['products'])?></div></a>
				</div>
				<div id="products"  class="card-footer text-white clearfix small z-1" style="color:white"><span id="pr" class="float-left">Add Product</span> 
				<span class="float-right"><i class="fas fa-angle-right"></i></span></div>
			</div>
		</div>
		<div class="col-xl-3 col-sm-6 mb-3">
			<div class="card text-white bg-danger o-hidden h-100" style="<?=isset($_GET['account']) ? 'border: 2px black solid' : 'border: 0'?>">
				<div class="card-body">
					<div class="card-body-icon">
						<i class="fas fa-fw fa-life-ring"></i>
					</div><a href='admin.php?account'><div class="mr-5">Logged in as: <?=$_SESSION['username']?></div></a>
				</div>
				<a class="card-footer text-white clearfix small z-1" href="logout.php" style="color:white"><span class="float-left">Log Out</span> 
				<span class="float-right"><i class="fas fa-angle-right"></i></span></a>
			</div>
		</div>
	</div>
	
	<div class="container-fluid">
        <div class="card" style="background-color: beige; border: 4px groove black">
        	<div class="card-body"><?=db::table($data ?? [])?><!-- That's the table. the = sign there means go php and echo -->
            	<div class="card-footer small text-muted" id="last">Updated <script>$('#last').html((new Date()))</script></div>
            </div>
        </div>
    </div>
    
    <!--begin "off-camera" forms, aka sliders-->
    <div class="container-fluid" id="employee">
		<div class="card card-login mx-auto mt-5">
			<div class="card-header">New Employee</div>
			<div class="card-body">
				<form action="index.php" method="post">
					<div class="form-group">
						<label for="name">Name</label><input class="form-control" name="name" required="" type="text">
					</div>
					<div class="form-group">
						<label for="email">Email</label><input class="form-control" name="email" required="" type="text">
					</div>
					<div class="form-group">
						<label for="phone">Phone Number</label><input class="form-control" name="phone" required="" type="text">
					</div>
					<div class="form-group">
						<label for="wage">Hourly Wage</label><input class="form-control" name="wage" required="" type="text">
					</div>
					<div class="form-group">
						<label for="vendor">Vendor</label><select name="vendor"><?foreach($_SESSION['vendors'] as $v) echo '<option value="'.$v['id'].'">'.$v['name'].'</option>';?></select>
					</div>
					<button class="btn btn-primary"  style="float: right" type="submit">Submit</button>
 					<button class="btn btn-primary" onclick="cancel()" style = "float: left" type="button">Cancel</button>
				</form>
			</div>
		</div>
	</div>
	<div class="container-fluid" id="vendor">
		<div class="card card-login mx-auto mt-5">
			<div class="card-header">New Vendor</div>
			<div class="card-body">
				<form action="index.php" method="post">
					<div class="form-group">
						<label>Vendor Name</label> <input class="form-control" name="name" required="" type="text">
						<label>Vendor Address</label><input class="form-control" name="address" required="" type="text">
						<label>Vendor Details</label><input class="form-control" name="details" required="" type="text">
					</div>
					<button class="btn btn-primary" style="float: right" type="submit">Submit</button>
 					<button class="btn btn-primary" onclick="cancel()" style = "float: left" type="button">Cancel</button>
				</form>
			</div>
		</div>
	</div>
	<div class="container-fluid" id="product">
		<div class="card card-login mx-auto mt-5">
			<div class="card-header">New Product</div>
			<div class="card-body">
				<form action="index.php" method="post">
					<div class="form-group">
						<label>Product Name</label> <input class="form-control" name="name" required="" type="text">
					</div>
					<div class="form-group">
						<label>Product Cost</label><input class="form-control" name="cost" required="" type="text">
					</div>
					<div class="form-group">
						<label>Product Details</label> <input class="form-control" name="details" required="" type="text">
					</div>
					<div class="form-group">
						<label>Product Vendor</label><select name="vendor"><?foreach($_SESSION['vendors'] as $v) echo '<option value="'.$v['id'].'">'.$v['name'].'</option>';?></select>
					</div>
					<button class="btn btn-primary" style="float: right" type="submit">Submit</button>
 					<button class="btn btn-primary" onclick="cancel()" style = "float: left" type="button">Cancel</button>
				</form>
			</div>
		</div>
	</div>
	<!--end "off-camera" forms, aka sliders-->

	<script src="js/doslocos.js"></script><script>$('#dataTable').DataTable({reponsive: false})</script>
</body></html>