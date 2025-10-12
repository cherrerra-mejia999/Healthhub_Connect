<?php
/* register.php
     Provides both the registration form (GET) and form handling (POST).
     - Validates inputs
     - Checks duplicate username/email
     - Inserts into Users and Profiles
     - Regenerates session ID and logs user in
     - Redirects to index.php on success
*/

include 'db_connect.php';

// Helper to sanitize output for HTML
function e($v) {
        return htmlspecialchars($v ?? '', ENT_QUOTES, 'UTF-8');
}

$errors = [];
$values = [
        'first_name' => '',
        'last_name' => '',
        'email' => '',
        'phone' => '',
        'date_of_birth' => '',
        'username' => ''
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Collect and trim
        $values['first_name'] = trim($_POST['first_name'] ?? '');
        $values['last_name'] = trim($_POST['last_name'] ?? '');
        $values['email'] = trim($_POST['email'] ?? '');
        $values['phone'] = trim($_POST['phone'] ?? '');
        $values['date_of_birth'] = trim($_POST['date_of_birth'] ?? '');
        $values['username'] = trim($_POST['username'] ?? '');
        $password = $_POST['password'] ?? '';

        // Basic validation
        if ($values['first_name'] === '') $errors[] = 'First name is required.';
        if ($values['last_name'] === '') $errors[] = 'Last name is required.';
        if ($values['email'] === '' || !filter_var($values['email'], FILTER_VALIDATE_EMAIL)) $errors[] = 'A valid email is required.';
        if ($values['username'] === '') $errors[] = 'Username is required.';
        if (strlen($password) < 6) $errors[] = 'Password must be at least 6 characters.';

        // Check duplicates only if no validation errors yet
        if (empty($errors)) {
                // Check username
                $check = $conn->prepare('SELECT id FROM Users WHERE username = ? LIMIT 1');
                $check->bind_param('s', $values['username']);
                $check->execute();
                $check->store_result();
                if ($check->num_rows > 0) {
                        $errors[] = 'That username is already taken.';
                }
                $check->close();

                // Check email
                $check = $conn->prepare('SELECT id FROM Users WHERE email = ? LIMIT 1');
                $check->bind_param('s', $values['email']);
                $check->execute();
                $check->store_result();
                if ($check->num_rows > 0) {
                        $errors[] = 'An account with that email already exists.';
                }
                $check->close();
        }

        // If still no errors, insert user and profile
        if (empty($errors)) {
                $hashed_password = password_hash($password, PASSWORD_BCRYPT);

                $user_sql = "INSERT INTO Users (username, password_hash, email, phone, date_of_birth)
                                         VALUES (?, ?, ?, ?, ?)";
                $stmt = $conn->prepare($user_sql);
                if (!$stmt) {
                        $errors[] = 'Database error (prepare failed).';
                } else {
                        $stmt->bind_param('sssss', $values['username'], $hashed_password, $values['email'], $values['phone'], $values['date_of_birth']);
                        if ($stmt->execute()) {
                                $user_id = $stmt->insert_id;

                                // Insert profile
                                $profile_sql = "INSERT INTO Profiles (user_id, first_name, last_name, gender) VALUES (?, ?, ?, 'other')";
                                $stmt2 = $conn->prepare($profile_sql);
                                if ($stmt2) {
                                        $stmt2->bind_param('iss', $user_id, $values['first_name'], $values['last_name']);
                                        $stmt2->execute();
                                        $stmt2->close();
                                }

                                $stmt->close();

                                // Start session, regenerate id and store user info
                                if (session_status() !== PHP_SESSION_ACTIVE) session_start();
                                session_regenerate_id(true);
                                $_SESSION['user_id'] = $user_id;
                                $_SESSION['username'] = $values['username'];
                                $_SESSION['first_name'] = $values['first_name'];
                                $_SESSION['last_name'] = $values['last_name'];

                                // Redirect to homepage
                                header('Location: index.php');
                                exit();
                        } else {
                                $errors[] = 'Database error: ' . $stmt->error;
                                $stmt->close();
                        }
                }
        }
}

$conn->close();
?>
<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Register - Healthub Connect</title>
        <style>
            body {
                background: #f2f2f2;
                margin: 0;
                height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
            }

            .box {
                width: 70%;
                background: #fff;
                padding: 20px;
                border: 1px solid #ccc;
                box-sizing: border-box;
            }

            h2 {
                text-align: center;
                margin-top: 0;
            }

            input,
            button {
                width: 100%;
                padding: 8px;
                margin-bottom: 10px;
                border-radius: 4px;
                box-sizing: border-box;
            }

            input {
                border: 1px solid #aaa;
            }

            button {
                background: #5b63b7;
                color: #fff;
                border: none;
                font-weight: bold;
                cursor: pointer;
            }

            p {
                text-align: center;
                font-size: 14px;
            }

            .errors { background:#ffe6e6; border:1px solid #ff9b9b; padding:10px; margin-bottom:10px; }
        </style>
    </head>

    <body>
        <div class="box">
            <h2>Create Healthub Account</h2>

            <?php if (!empty($errors)): ?>
                <div class="errors">
                    <ul>
                        <?php foreach ($errors as $err): ?>
                            <li><?php echo e($err); ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>
            <?php endif; ?>

            <form action="register.php" method="POST">
                <label>First Name</label>
                <input type="text" name="first_name" required value="<?php echo e($values['first_name']); ?>">

                <label>Last Name</label>
                <input type="text" name="last_name" required value="<?php echo e($values['last_name']); ?>">

                <label>Email</label>
                <input type="email" name="email" required value="<?php echo e($values['email']); ?>">

                <label>Phone Number</label>
                <input type="text" name="phone" value="<?php echo e($values['phone']); ?>">

                <label>Date Of Birth</label>
                <input type="date" name="date_of_birth" value="<?php echo e($values['date_of_birth']); ?>">

                <label>Create Username</label>
                <input type="text" name="username" required value="<?php echo e($values['username']); ?>">

                <label>Create Password</label>
                <input type="password" name="password" required>

                <button type="submit">Register</button>
                <p>Already have an account? <a href="signin.html">Sign in here</a></p>
            </form>
        </div>
    </body>
</html>
