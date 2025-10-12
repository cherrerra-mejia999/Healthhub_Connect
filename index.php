<?php
session_start();
$loggedIn = isset($_SESSION['user_id']);
$firstName = $loggedIn && !empty($_SESSION['first_name']) ? htmlspecialchars($_SESSION['first_name']) : null;
?>
<!doctype html>
<html>
  <head>
    <!--Basic setups for flexibility-->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1"> 
    <title>Healthub Connect</title>
    <!--CSS-->
    <link rel="stylesheet" href="index_styles.css">
  </head>
  <body>
    <div class="Title">
      <h1>
        Welcome to Healthub Connect!
      </h1>
      <?php if ($loggedIn): ?>
        <p style="margin:0;">Hello, <?php echo $firstName; ?> — <a href="signout.php">Sign Out</a></p>
      <?php endif; ?>
    </div>
    <div class="top-bar">
      <?php if (!$loggedIn): ?>
        <button class="signin-btn" onclick="location.href='signin.html'">Sign In</button>
      <?php endif; ?>
    </div>
    <hr>
    <h2 class="Navigations">
      <!--Hyper links to other pages-->
      <a href="documents.html">Documents</a>
      <a href="tracker.html">Trackers</a>
      <a href="tracker.html">AI Health Assistant</a>
      <a href="tracker.html">Appointments</a>
      <a href="tracker.html">Insurance Hub</a>
      <a href="tracker.html">Visit Summaries</a>
      <a href="tracker.html">Family Access</a>
      <a href="tracker.html">Payments</a>
      <a href="tracker.html">Support Call Center</a>
      <a href="tracker.html">Helpful Links</a>
      <a href="tracker.html">About</a>
    </h2>
    <hr>
    <section>
      <h2>About Healthub Connect</h2>
      <p>
        Healthub Connect is a modern health platform that helps users manage
        their personal and medical data efficiently. From tracking your daily
        vitals to managing appointments, our mission is to keep you connected to
        your health.
      </p>
    </section>
    
    <section>
      <h2>Core Features</h2>
      <ul>
        <li>Upload and access health documents anytime</li>
        <li>Track your heart rate and blood sugar daily</li>
        <li>Set reminders for medication and appointments</li>
        <li>Communicate directly with a medical AI chatbot </li>
        <li>Securely manage insurance and payment details</li>
        <li>And more</li>  
      </ul>
    </section>
    <img src="health_placeholder.jpeg" alt="Healthub Connect" style="width:100%;max-width:600px;">
  </body>
</html>
