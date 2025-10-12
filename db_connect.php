<?php
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "HealthHubDB";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to $dbname\n";
?>