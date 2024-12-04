// Author: Chaloemsak Arsung
const express = require("express");
const connection = require("./db");
const bcrypt = require("bcrypt");
const bodyParser = require("body-parser");
const jwt = require("jsonwebtoken");
// Manage files
const fs = require("fs");
// Manage paths
const path = require("path");

// <----------------------  MODULE CUSTOMs  ------------------------->
// Multer : To upload image file and store it at the back-end side.
const { uploadAssets, uploadProfiles } = require("./uploaderFile");
// AUTHENTICATION AND AUTHORIZATION custom by Mike016.
const authentication = require("./authentication");

const app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.json());

// <------------------------  VARIABLEs  ------------------------------>
// FOR HASH
const SALT_ROUNDS = 10;
const JWT_SECRET_KEY = "MIKE016_LOL";

// <------------------------  Helper Function  ------------------------>
// single file: image to Base64
function imageToBase64(type, imagePath) {
  // asset --> book etc.  profile --> image profile of users
  let fullImagePath = "";
  // Use path.join() to properly join the directories and the filename
  if (path.isAbsolute(imagePath)) {
    // means: C:\Users\chaloemsak\Downloads\backend-project-mobile\images\assets\1-1731087718854-174115118.png
    // If the image path is absolute, just use it
    fullImagePath = imagePath;
  } else {
    // If it's a relative path, construct the full path
    if (type === "asset") {
      fullImagePath = path.join(__dirname, "images", "assets", imagePath);
    } else if (type === "profile") {
      fullImagePath = path.join(__dirname, "images", "profiles", imagePath);
    }
  }

  try {
    // Read image file and convert it to Base64 format
    const imageBuffer = fs.readFileSync(fullImagePath);
    const imageBase64 = imageBuffer.toString("base64");
    return imageBase64;
  } catch (error) {
    console.error(`Error reading image ${imagePath}:`, error);
    return null; // Return null if there is an error
  }
}

//Multiple image change results from data base from image --> base64
function convertAssetsToBase64(results) {
  return results.map((asset) => {
      const imagePath = path.join(__dirname, "images", "assets", asset.image);
      try {
          return {
              ...asset,
              image: imageToBase64("asset",imagePath), // Add the Base64 encoded image to the response
          };
      } catch (err) {
          console.error(`Error reading image ${asset.image}:`, err);
          return {
              ...asset,
              image: null, // If there's an error, return null for the image
          };
      }
  });
}

// <------------------------ ALL Routes  ------------------------------------->

/////////////////////////////////////////////////////////////////////////////
// ======================= STUDENTs Routes ==================================
/////////////////////////////////////////////////////////////////////////////

// send request to borrow
app.post(
  "/student/request",
  authentication.student_VERIFY,
  async (req, res) => {
    // console.log("decoded" , req.decoded); // to access data is decoded from token(payload) ;
    try {
      // Retrieve the date from the request body
      const { asset_id, user_id, borrow_date, return_date } = req.body;
      console.log(asset_id , user_id , borrow_date , return_date);

      // Check the asset's status first
      const [assetRows] = await connection
        .promise()
        .query("SELECT status FROM assets WHERE id = ?", [asset_id]);

      // Check if the asset exists and if its status is "Available"
      if (assetRows.length === 0) {
        return res.status(404).json({ message: "Asset not found" });
      }

      const assetStatus = assetRows[0].status;

      if (assetStatus !== "Available") {
        return res.status(400).json({ message: "Asset is not available" });
      }

      // Continue with your code here if the asset is available

      // Validate the date format (optional, assuming "YYYY-MM-DD" format)
      const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
      if (!dateRegex.test(borrow_date) || !dateRegex.test(return_date)) {
        return res
          .status(400)
          .json({ error: "Invalid date format. Use 'YYYY-MM-DD'." });
      }
      const sql = `INSERT INTO borrowing (asset_id , user_id , borrow_date , return_date , creationDate) VALUES (? , ? , ? ,? , DATE(NOW()) )`;
      // Store the date in the database
      const [result] = await connection
        .promise()
        .query(sql, [asset_id, user_id, borrow_date, return_date]);

      // console.log("insert at:", result.insertId);
      // change status in assets table to pending
      connection.query(
        "UPDATE assets SET status = 'Pending' WHERE id = ?",
        [asset_id],
        (err, result) => {
          if (err) {
            return res
              .status(400)
              .json({ error: "Bad Request: Invalid input data" });
          }
          if (result.affectedRows === 0) {
            return res
              .status(400)
              .json({ error: "Bad Request: Didn't update status to Pending" });
          }
        }
      );

      res.json({
        message: "Date saved successfully",
        borrowingID: result.insertId,
      });
    } catch (err) {
      console.error("Error saving date:", err);
      res.status(500).json({ error: "Failed to save date" });
    }
  }
);

// check request status
// *** problem: image path
app.post(
  "/student/check_request",
  authentication.student_VERIFY,
  (req, res) => {
    // check by borrowing id ** need to save borrowingID at localstorage
    const { borrowingID , userID } = req.body;
    const sql = `
        SELECT  
        assets.asset_name, 
        borrowing.status,
        DATE_FORMAT(borrowing.return_date, '%Y-%m-%d') AS return_date,
        assets.image
        FROM borrowing
        JOIN assets ON borrowing.asset_id = assets.id
        WHERE borrowing.id = ? AND borrowing.user_id = ?;
    `;
    connection.query(sql, [borrowingID , userID ], (err, results) => {
      // console.log("results:" , results);
      if (!err) {
        if (results.length === 0) {
          return res
            .status(400)
            .json({ error: "borrowID is not match or undefined!!!" });
        }
        let data = results[0];
        const fileName = data.image;
        // set data.image to imageBase64
        data.image = imageToBase64("asset", fileName);

        return res.status(200).json( data );
      } else {
        return res.status(500).json({ error: err });
      }
    });
  }
);

// Problem: A student can borrow only one asset a day.
// fetch data from borrowing when  creationDate = today and id = userID
// if res.lengh == 0 mean user can book another but if != 0 user will can not book that time
// when student request need to insert creationDate
app.post('/student/checkBorrowing' , authentication.student_VERIFY , (req , res) => {
  const {userID} = req.body;
  console.log("check event:" , userID);
  const sql  = `SELECT id AS borowingID FROM borrowing WHERE user_id = ? AND creationDate = DATE(NOW())`;
  connection.query(sql, [userID], (err, results) => {
    if (!err) {
      if (results.length == 0) {
        return res
          .status(400)
          .json({ msg: "don't have data or user maybe don't have history" });
      }
      console.log(results);
      res.status(200).json(results[0]); // map
    } else {
      // console.log("error ", err);
      res.status(500).send(err);
    }
  });
});

// History for students
app.get(
  "/student/history/:user_id",
  authentication.student_VERIFY,
  (req, res) => {
    // console.log(req.originalUrl);
    // url: http://localhost:3000/example/123    // use params
    let user_id = req.params.user_id;
    
    // ***Knowlegde
    // let s = req.query.s; // http://localhost:3000/student/history/1?s=dfdsf *** use Qury params
    // console.log(s); // --> dfdsf

    // check userID from token and userID send from user is match or not: *** IF IDs NOT MATCH MEANS USER TRY TO SEE OTHER PEOPLE HISTORY.
    if (user_id != req.decoded.id) {
      return res
        .status(403)
        .send(`${user_id} is not your ID Pls,don't hack my api LOL`);
    }
    // console.log("user_id: " , user_id);
    const sql = `
        SELECT borrowing.id AS borrow_id,
        assets.asset_name, 
        borrower.username AS Borrower,
        lender.username AS Lender,
        DATE_FORMAT(borrowing.borrow_date, '%Y-%m-%d') AS borrow_date,
        DATE_FORMAT(borrowing.return_date, '%Y-%m-%d') AS return_date,
        borrowing.status,
        borrowing.staff_name AS Receiver ,
        assets.image
        FROM borrowing
        JOIN assets ON borrowing.asset_id = assets.id
        JOIN users AS borrower ON borrowing.user_id = borrower.id
        LEFT JOIN users AS lender ON borrowing.lender_id = lender.id
        WHERE borrowing.user_id = ? AND borrowing.status != "Pending" ;

    `;

    connection.query(sql, [user_id], (err, results) => {
      if (!err) {
        if (results.length == 0) {
          return res
            .status(400)
            .json({ msg: "don't have data or user maybe don't have history" });
        }
        res.status(200).json(convertAssetsToBase64(results));
      } else {
        console.log("error ", err);
        res.status(500).send(err);
      }
    });
  }
);


/////////////////////////////////////////////////////////////////////////////
// ====================== LENDERs Routes ====================================
/////////////////////////////////////////////////////////////////////////////

// see the requesting from user
app.get("/lender/seeRequest", authentication.lender_VERIFY, (req, res) => {
  
  // borrow return date nameuser asset name image
  const sql = `SELECT
        borrowing.id AS borrowing_id , 
        assets.id AS asset_id,
        users.username,
        assets.asset_name, 
        DATE_FORMAT(borrowing.borrow_date, '%Y-%m-%d') AS borrow_date,
        DATE_FORMAT(borrowing.return_date, '%Y-%m-%d') AS return_date,
       
        assets.image
        FROM borrowing
        JOIN assets ON borrowing.asset_id = assets.id
        JOIN users ON borrowing.user_id = users.id
        where borrowing.status = 'Pending'
  `;
  connection.query(sql, (err, results) => {
    if (!err) {
        if (results.length == 0) {
          return res
            .status(400)
            .json({ msg: "don't have data as status is Pending" });
        }
        res.status(200).json(convertAssetsToBase64(results));
    } else {
      console.log("error ", err.message);
      res.status(500).send(err);
    }
  });
});

// ALLOW OR Disallow for borrowing: change status returned to False and asset status to Borrowed
app.post("/lender/approve", authentication.lender_VERIFY, (req, res) => {
  const { asset_id, borrowID, approved , lenderID } = req.body; // `approved` should be either "Approved" or "Disapproved"

  if (approved !== "Approved" && approved !== "Disapproved") {
    return res.status(400).json({
      msg: "The 'approved' field must be 'Approved' or 'Disapproved'.",
    });
  }

  let sql = "";
  if (approved === "Approved") {
    // Set up the query to update both `assets` and `borrowing` tables for an approval
    sql = `
        UPDATE assets SET status = 'Borrowed' WHERE id = ?;
        UPDATE borrowing SET status = 'Approved', returned = 'FALSE', lender_id = ? WHERE id = ?;
      `;

    // Execute the query with necessary placeholders
    connection.query(sql, [asset_id, lenderID, borrowID], (err, results) => {
      if (err) {
        console.error("Error:", err.message);
        return res
          .status(500)
          .json({ error: "Failed to approve the borrowing request." });
      }
      res.status(200).json({ msg: "Approved" });
    });
  } else if (approved === "Disapproved") {
    // Set up the query to update both `assets` and `borrowing` tables for disapproval
    sql = `
        UPDATE assets SET status = 'Available' WHERE id = ?;
        UPDATE borrowing SET status = 'Disapproved', lender_id = ? WHERE id = ?;
      `;

    connection.query(sql, [asset_id, lenderID, borrowID], (err, results) => {
      if (err) {
        console.error("Error:", err.message);
        return res
          .status(500)
          .json({ error: "Failed to disapprove the borrowing request." });
      }
      res.status(200).json({ msg: "Disapproved" });
    });
  }
});

// History for lenders
app.get(
  "/lender/history/:lender_id",
  authentication.lender_VERIFY,
  (req, res) => {
    let lender_id = req.params.lender_id;

    const sql = `
        SELECT borrowing.id AS borrow_id,
        assets.asset_name, 
        borrower.username AS Borrower, 
        lender.username AS Lender,
        borrowing.staff_name AS Receiver,
        DATE_FORMAT(borrowing.borrow_date, '%Y-%m-%d') AS borrow_date,
        DATE_FORMAT(borrowing.return_date, '%Y-%m-%d') AS return_date,
        assets.image
        FROM borrowing
        JOIN assets ON borrowing.asset_id = assets.id
        JOIN users AS borrower ON borrowing.user_id = borrower.id
        JOIN users AS lender ON borrowing.lender_id = lender.id
        WHERE lender_id = ?
    `;

    connection.query(sql, [lender_id], (err, results) => {
      if (!err) {
        if (results.length == 0) {
          return res.status(201).json({ msg: "don't have data" });
        }

        res.status(200).json(convertAssetsToBase64(results));
      } else {
        console.log("error", err);
        res.status(500).send(err);
      }
    });
  }
);


/////////////////////////////////////////////////////////////////////////////
// ====================== STAFFs Routes =====================================
/////////////////////////////////////////////////////////////////////////////

// Edit assets : Update name status image
app.post(
  "/staff/edit",
  authentication.staff_VERIFY,
  uploadAssets.single("asset"),
  async (req, res) => {
    const { asset_id, newName, newStatus } = req.body;
    // image: file name
    const image = req.file ? req.file.filename : null;
    if (image == null) {
      return res.status(401).json({ error: "can not get the file name" });
    }

    if (!asset_id || !newStatus || !newName) {
      return res
        .status(401)
        .send("Please send asset_id, newName , newStatus , newImage .");
    }

    // check asset is in database or not first
    const [assetRows] = await connection
      .promise()
      .query("SELECT * FROM assets WHERE id = ?", [asset_id]);

    if (assetRows.length === 0) {
      return res.status(404).json({ message: "Asset not found" });
    }

    const sql =
      "UPDATE assets SET asset_name = ? , status = ? , image = ? WHERE id = ?";
    connection.query(
      sql,
      [newName, newStatus, image, asset_id],
      (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        if (results.affectedRows === 0) {
          return res.status(404).json({ error: "Asset not found" });
        }
        res.status(200).send(`Status updated to ${newStatus}`);
      }
    );
  }
);

// add new asset
app.post(
  "/staff/add",
  authentication.staff_VERIFY,
  uploadAssets.single("asset"),
  (req, res) => {
    const { asset_name } = req.body;
    const image = req.file ? req.file.filename : null;
    if (image == null) {
      return res.status(401).json({ error: "can not get the file name" });
    }

    if (!asset_name) {
      return res.status(400).json({ error: "No asset name" });
    }

    const sql = "INSERT INTO assets ( asset_name, image) VALUES (?, ?)";
    connection.query(sql, [asset_name, image], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.status(200).json({
        message: "New asset added successfully",
        newAsset: { insertATid: results.insertId },
      });
    });
  }
);
//for BUTTON --> Disable asset : change status to disable or available
app.post("/staff/disable", authentication.staff_VERIFY, async (req, res) => {
  const { asset_id, newStatus } = req.body;
  
  // Check the asset's status first
  const [assetRows] = await connection
    .promise()
    .query("SELECT status FROM assets WHERE id = ?", [asset_id]);

  // Check if the asset exists and if its status is "Available"
  if (assetRows.length === 0) {
    return res.status(404).json({ message: "Asset not found" });
  }

  const assetStatus = assetRows[0].status;

  if (assetStatus !== "Available" && assetStatus !== "Disable") {
    // console.log("LOL");
    return res.status(400).json({ message: "can not edit status this assset" });
  }
  // update status
  const sql = "UPDATE assets SET status = ? WHERE id = ?";
  connection.query(sql, [newStatus, asset_id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    
    res.status(200).json({
      message: `Update status asset successfully to ${newStatus}`,
    });
  });
});

// SHOW assets need to return by today , another day
app.get("/staff/showReturn", authentication.staff_VERIFY, (req, res) => {  
  
  const sql = `SELECT 
  borrowing.id AS borrowingID,
  borrowing.asset_id,
  borrowing.user_id,
  DATE_FORMAT(borrowing.borrow_date, '%Y-%m-%d') AS borrow_date,
  DATE_FORMAT(borrowing.return_date, '%Y-%m-%d') AS return_date,
  lender.username AS lender,
  user.username AS borrower,
  assets.asset_name,
  assets.image
  FROM borrowing
  JOIN users AS lender ON borrowing.lender_id = lender.id
  JOIN users AS user ON borrowing.user_id = user.id
  LEFT JOIN assets ON borrowing.asset_id = assets.id
  WHERE borrowing.returned = 'False' AND borrowing.status = 'Approved';

  `;
  connection.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0 ) return res.status(200).json({msg : "Now don't have asset need to return"});

    res.status(200).json(convertAssetsToBase64(results));
  });
});

// Recieve asset back
app.post("/staff/recieve", authentication.staff_VERIFY, async (req, res) => {
  
  // ***add authorization
  const { staff_name ,asset_id, borrowingID } = req.body;
  
  // Check the asset is in database or not first
  const [assetRows] = await connection
    .promise()
    .query("SELECT * FROM assets WHERE id = ?", [asset_id]);

  // Check if the asset don't exists
  if (assetRows.length === 0) {
    return res.status(404).json({ message: "Asset not found" });
  }

  const sql =
    "UPDATE `assets` SET `status` = 'Available' WHERE `assets`.`id` = ? ; UPDATE `borrowing` SET `returned` = 'True' , `staff_name` = ? WHERE `borrowing`.`id` = ? ";
  connection.query(sql, [asset_id, staff_name ,borrowingID], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.affectedRows === 0) {
      return res
        .status(500)
        .json({ msg: `can not recive asset ID = ${asset_id} ` });
    }
    res.status(200).json({ msg: "Recieve asset successfuly" });
  });
});

// History for staff (ALL)
app.get("/staff/history", authentication.staff_VERIFY, (req, res) => {
  // (product name, borrowed date, returned date, who borrowed, who approved, who got asset back)
  console.log("Staff event");
  const sql = `
        SELECT borrowing.id AS borrow_id,
        assets.asset_name, 
        borrower.username AS Borrower, 
        lender.username AS Lender,
        DATE_FORMAT(borrowing.borrow_date, '%Y-%m-%d') AS borrow_date,
        DATE_FORMAT(borrowing.return_date, '%Y-%m-%d') AS return_date,
        borrowing.staff_name AS Receiver,
        assets.image 
        FROM borrowing
        JOIN assets ON borrowing.asset_id = assets.id
        JOIN users AS borrower ON borrowing.user_id = borrower.id
        JOIN users AS lender ON borrowing.lender_id = lender.id
        ORDER BY borrowing.id DESC;
    `;

  connection.query(sql, (err, results) => {
    if (!err) {
      if (results.length == 0) {
        return res.status(201).json({ msg: "don't have data , story not found" });
      }
      res.status(200).json(convertAssetsToBase64(results)); // Corrected line
    } else {
      console.log("error", err);
      res.status(500).send(err);
    }
  });
});


/////////////////////////////////////////////////////////////////////////////
//=================== LENDERs AND STAFFs Routes =============================
/////////////////////////////////////////////////////////////////////////////

// Dashboard Route: lender and staff can use together
app.get(
  "/dashboard",
  authentication.lenderAndStaff_VERIFY,
  async (req, res) => {
    try {
      // Query for user role counts
      const [userCounts] = await connection
        .promise()
        .query(`SELECT role, COUNT(*) AS count FROM users GROUP BY role`);

      // Query for asset status counts
      const [statusCounts] = await connection
        .promise()
        .query(`SELECT status, COUNT(*) AS count FROM assets GROUP BY status`);

      // Check if user counts are empty
      if (userCounts.length === 0 || statusCounts.length === 0) {
        return res.status(404).json({ message: "No user counts found" });
      }
      // Return the results
      res.status(200).json({
        user_count: userCounts,
        status_count: statusCounts,
      });
    } catch (err) {
      console.error("Error fetching user and status counts:", err);
      return res.status(500).json({ error: "Error fetching data" });
    }
  }
);


/////////////////////////////////////////////////////////////////////////////
//================== All Roles (Authentication Required) ====================
/////////////////////////////////////////////////////////////////////////////

// User profile: Get user data
app.get("/userData/:userID", authentication.allROLE_VERIFY, (req, res) => {
  
  // http://localhost:3000/userData/1 path to use this
  const userID = req.params.userID;
  const sql = "SELECT * FROM users WHERE id = ?";
  connection.query(sql, [userID], (err, results) => {
    if (err) {
      return res.status(500).json({ errors: err });
    }
    // if user not found
    if (results.length === 0) {
      return res.status(404).json({ msg: "user not found" });
    }
    const userInfo = results[0];
    // console.log(results);
    /* structure of result from DB:
        [
          {
            id: 1,
            username: 'alice',
            email: 'student@gmail.com',
            password: '$2b$10$c6p273pHlNG4kS/ty1xJDuM2.bweaIhaQULJHbILuz0M0D6y4yRNS',
            role: 'Student',
            image: 'student.jpg'
          }
        ]
    */
    // single file.
    const data = {
      name: userInfo.username,
      email: userInfo.email,
      image: imageToBase64("profile", userInfo.image),
    };
    

    return res.status(200).json(data);
  });
});

// Edit profile
app.post(
  "/userEdit",
  authentication.allROLE_VERIFY,
  uploadProfiles.single("profile"),
  async (req, res) => {
    // console.log("Edit event");
    try {
      const { userID, NewUsername, NewEmail, NewPassword } = req.body;
      const image = req.file ? req.file.filename : null;

      // Protect New Email already exists
      connection.query(
        "SELECT * FROM users WHERE email = ?",
        [NewEmail],
        async (err, results) => {
          if (err) {
            console.error("Error checking user existence:", err);
            return res.status(500).json({ message: "Database error" });
          }

          if (results.length > 0) {
            return res.status(400).json({ message: "User already exists" });
          }

          // Construct SQL query
          let sql = "UPDATE users SET username = ?, email = ? ";
          const values = [NewUsername, NewEmail];

          if (NewPassword) {
            const hashedPassword = await bcrypt.hash(NewPassword, SALT_ROUNDS);
            sql += ", password = ?";
            values.push(hashedPassword);
          }

          if (image) {
            sql += ", image = ?";
            values.push(image);
          }

          sql += " WHERE id = ?";
          values.push(userID);

          connection.query(sql, values, (err, result) => {
            if (err) {
              console.error("Error updating user profile:", err);
              return res.status(500).json({ message: "Database error" });
            }

            if (result.affectedRows === 0) {
              console.log("User not found or no changes");
              return res
                .status(404)
                .json({ message: "User not found or no changes" });
            }

            res.status(200).json({ message: "Profile updated successfully" });
          });
        }
      );
    } catch (error) {
      console.error("Error updating user profile:", error);
      res.status(500).json({ message: "Server error" });
    }
  }
);

// browse asset list : All role can use this
app.get("/browseAsset", authentication.allROLE_VERIFY, (req, res) => {

  const sql = "SELECT id , asset_name AS name, status , image FROM assets";

  connection.query(sql, (err, results) => {
    if (err) {
      return res.status(500).json({ errors: err });
    }

    res.status(200).json(convertAssetsToBase64(results));
  });
});


/////////////////////////////////////////////////////////////////////////////
//=============== Public Routes (No Authentication Required) ================
/////////////////////////////////////////////////////////////////////////////
// Login
app.post("/login", (req, res) => {
  // console.log("login event");
  // console.log("login come");
  const { email, password } = req.body;

  connection.query(
    "SELECT * FROM users WHERE email = ?",
    [email],
    (err, results) => {
      if (err) {
        console.error("Error while querying the database:", err);
        return res
          .status(500)
          .json({ message: "Error while querying the database" });
      }

      if (results.length === 0) {
        return res
          .status(401)
          .json({ message: "Invalid username or password" });
      }

      const user = results[0];
      bcrypt.compare(password, user.password, (compareErr, isMatch) => {
        if (compareErr) {
          console.error("Error while comparing passwords:", compareErr);
          return res
            .status(500)
            .json({ message: "Error while comparing passwords" });
        }

        if (!isMatch) {
          return res
            .status(401)
            .json({ message: "Invalid username or password" });
        }
        // SEND TOKEN TO USER
        const payload = {
          id: user.id,
          username: user.username,
          role: user.role,
        };
        const token = jwt.sign(payload, JWT_SECRET_KEY, { expiresIn: "30d" });
        return res.status(200).json({
          message: "Login successful",
          id: user.id,
          username: user.username,
          role: user.role,
          token: token,
          image: imageToBase64("profile", user.image),
        });
      });
    }
  );
});

// Registration API
app.post("/signup", (req, res) => {
  const { username, email, password } = req.body;

  // Check if user already exists
  connection.query(
    "SELECT * FROM users WHERE email = ?",
    [email],
    (err, results) => {
      if (err) {
        console.error("Error checking user existence:", err);
        return res.status(500).json({ msg: "Database error" });
      }

      if (results.length > 0) {
        // Changed to > 0 for better clarity
        return res.status(400).json({ msg: "User already exists" });
      }

      // Hash the password
      bcrypt.hash(password, SALT_ROUNDS, (err, hash) => {
        if (err) {
          console.error("Hashing error:", err);
          return res.status(500).json({ msg: "Error hashing password" });
        }

        // Insert the new user into the database
        const sql =
          "INSERT INTO users (username, email, password , image) VALUES (?, ?, ? , ?)";
        // image by default is student.jpg when new user register.
        connection.query(
          sql,
          [username, email, hash, "student.jpg"],
          (err, results) => {
            if (err) {
              console.error("Error inserting user:", err);
              return res.status(500).json({ msg: "Database error" });
            }

            // Check if the insertion was successful
            if (results.affectedRows === 1) {
              return res.status(201).json({ msg: "Registration successful" }); // 201 Created
            } else {
              return res.status(500).json({ msg: "Registration failed" });
            }
          }
        );
      });
    }
  );
});
app.listen(3000, () => console.log("Server is running on port 3000"));

