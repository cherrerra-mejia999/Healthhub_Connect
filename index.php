<?php
// Basic MySQLi setup — replace with your real credentials
$servername = "localhost";
$username = "root"; // <-- change to your DB user
$password = "";     // <-- change to your DB password
$dbname = "healthhub"; // database to create/use

// Create connection (connect to server first)
$conn = new mysqli($servername, $username, $password);

// Check connection
if ($conn->connect_error) {
  die("Connection failed: " . $conn->connect_error);
}
echo "Connected to MySQL server successfully\n";

// Create the database if it doesn't exist
$sql = "CREATE DATABASE IF NOT EXISTS `" . $conn->real_escape_string($dbname) . "` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
if ($conn->query($sql) === TRUE) {
  echo "Database checked/created successfully\n";
} else {
  die("Error creating database: " . $conn->error);
}

// Select the database
if (!$conn->select_db($dbname)) {
  die("Error selecting database: " . $conn->error);
}

// Create USERS table with correct SQL syntax
$sql = "CREATE TABLE IF NOT EXISTS `USERS` (
  `FirstName` VARCHAR(30) NOT NULL,
  `LastName` VARCHAR(30) NOT NULL,
  `Email` VARCHAR(100) NOT NULL,
  `DOB` DATE NOT NULL,
  `Username` VARCHAR(50) NOT NULL,
  `PasswordHash` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";

if ($conn->query($sql) === TRUE) {
  echo "Table USERS created or already exists\n";
} else {
  echo "Error creating table: " . $conn->error . "\n";
}

$conn->close();
?>