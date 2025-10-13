<?php
/* signin.php
     Handles user login
     - Shows login form on GET
     - Validates credentials on POST
     - Creates session
     - Redirects to index.php on success
*/

$error = '';
$username = '';

// Only process login if it's a POST request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    include 'db_connect.php';
    
    $username = trim($_POST['username'] ?? '');
    $password = $_POST['password'] ?? '';

    if ($username === '' || $password === '') {
        $error = 'Please enter both username and password.';
    } else {
        // Query user
        $stmt = $conn->prepare('SELECT id, username, password_hash FROM Users WHERE username = ? LIMIT 1');
        $stmt->bind_param('s', $username);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows === 1) {
            $user = $result->fetch_assoc();
            
            // Verify password
            if (password_verify($password, $user['password_hash'])) {
                // Get profile info
                $profile_stmt = $conn->prepare('SELECT first_name, last_name FROM Profiles WHERE user_id = ? LIMIT 1');
                $profile_stmt->bind_param('i', $user['id']);
                $profile_stmt->execute();
                $profile_result = $profile_stmt->get_result();
                $profile = $profile_result->fetch_assoc();
                $profile_stmt->close();

                // Start session
                if (session_status() !== PHP_SESSION_ACTIVE) session_start();
                session_regenerate_id(true);
                
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['username'] = $user['username'];
                $_SESSION['first_name'] = $profile['first_name'] ?? '';
                $_SESSION['last_name'] = $profile['last_name'] ?? '';

                // Redirect to homepage
                header('Location: index.php');
                exit();
            } else {
                $error = 'Invalid username or password.';
            }
        } else {
            $error = 'Invalid username or password.';
        }
        $stmt->close();
    }
    
    $conn->close();
}

// Helper to sanitize output for HTML
function e($v) {
    return htmlspecialchars($v ?? '', ENT_QUOTES, 'UTF-8');
}
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign In - Healthub Connect</title>
    <style>
        body {
            background: #f2f2f2;
            margin: 0;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .box {
            width: 100%;
            max-width: 400px;
            background: #fff;
            padding: 30px;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-sizing: border-box;
        }

        h2 {
            text-align: center;
            margin-top: 0;
            color: #4b3fa6;
        }

        label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
            color: #333;
        }

        input,
        button {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }

        input {
            border: 1px solid #aaa;
        }

        input:focus {
            outline: none;
            border-color: #4b3fa6;
        }

        button {
            background: #4b3fa6;
            color: #fff;
            border: none;
            font-weight: bold;
            cursor: pointer;
            transition: 0.25s ease;
        }

        button:hover {
            background: #3a2f88;
        }

        p {
            text-align: center;
            font-size: 14px;
            margin-top: 20px;
        }

        p a {
            color: #4b3fa6;
            text-decoration: none;
        }

        p a:hover {
            text-decoration: underline;
        }

        .error {
            background: #ffe6e6;
            border: 1px solid #ff9b9b;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 4px;
            color: #c00;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="box">
        <h2>Sign Into Healthub Connect</h2>
        
        <?php if (!empty($error)): ?>
            <div class="error"><?php echo e($error); ?></div>
        <?php endif; ?>

        <form action="signin.php" method="POST">
            <label>Username</label>
            <input type="text" name="username" required value="<?php echo e($username); ?>">
            
            <label>Password</label>
            <input type="password" name="password" required>
            
            <button type="submit">Sign In</button>
            <p>Don't have an account? <a href="register.php">Register here</a></p>
        </form>
    </div>
</body>
</html>