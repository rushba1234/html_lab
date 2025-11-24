php
// login_form.php

// ---- DATABASE CONNECTION ----
$servername = "localhost";
$username = "root";       // Change if needed
$password = "";           // Change if needed
$dbname = "loginform";    // ✅ Your database name

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

session_start();
$message = "";

// ---- LOGOUT ----
if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: login_form.php");
    exit();
}

// ---- LOGIN FORM SUBMISSION ----
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['login'])) {
    $uname = $_POST['username'];
    $pass = $_POST['password'];

    // Check if username exists
    $sql = "SELECT * FROM users WHERE username = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $uname);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();

        if ($row['password'] === $pass) {
            // ✅ Username & password match
            $_SESSION['username'] = $uname;
        } else {
            // ⚠️ Username matches but password doesn’t
            $message = "<p style='color:red;'>Incorrect password.</p>";
        }
    } else {
        // ⚠️ Username doesn’t exist → check if password matches someone else
        $sql2 = "SELECT * FROM users WHERE password = ?";
        $stmt2 = $conn->prepare($sql2);
        $stmt2->bind_param("s", $pass);
        $stmt2->execute();
        $result2 = $stmt2->get_result();

        if ($result2->num_rows > 0) {
            $message = "<p style='color:red;'>Incorrect username.</p>";
        } else {
            $message = "<p style='color:red;'>Invalid username and password.</p>";
        }
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Login System</title>
    <style>
        body { font-family: Arial; margin: 50px; background: #f9f9f9; }
        .container { width: 400px; margin: auto; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        input { width: 100%; padding: 10px; margin: 8px 0; }
        input[type="submit"] { background-color: #4CAF50; color: white; border: none; cursor: pointer; }
        input[type="submit"]:hover { background-color: #45a049; }
        h2 { text-align: center; }
        .message { text-align: center; color: red; }
        .welcome { text-align: center; }
        a { color: #4CAF50; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>

<div class="container">
<?php
// ---- IF USER IS LOGGED IN ----
if (isset($_SESSION['username'])) {
    echo "<div class='welcome'>
            <h2>Welcome, " . htmlspecialchars($_SESSION['username']) . "!</h2>
            <p>You have successfully logged in.</p>
            <a href='?logout=true'>Logout</a>
          </div>";
} else {
    // ---- LOGIN FORM ----
    echo "<h2>User Login</h2>
          <form method='POST' action=''>
              <label>Username:</label><br>
              <input type='text' name='username' required><br>
              <label>Password:</label><br>
              <input type='password' name='password' required><br>
              <input type='submit' name='login' value='Login'>
          </form>
          <div class='message'>$message</div>";
}
?>
</div>

</body>
</html>


