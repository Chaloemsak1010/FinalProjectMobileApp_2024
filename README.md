# Final Project Mobile App _2024  
**Course: 1305216 Mobile Application Development (1/2567) at MFU**  

## Asset Borrowing System  

### Overview  
The **Asset Borrowing System** is a comprehensive solution designed to streamline the borrowing and management of assets for students, staff, and lecturers. The system classifies users into three distinct roles:  

- **Borrower**: Represents students who can browse and request assets.  
- **Staff**: Manages asset availability and processes borrowing requests.  
- **Lender**: Represents lecturers who provide and approve assets for borrowing.  

The system includes functionalities for tracking, approving, and logging the history of asset borrowing and returning activities.  

---

## Front-End  

### Technology Stack  
We use **Flutter** to develop the user interface of the mobile app.  

### Libraries  
Below are the essential libraries utilized in the front-end:  

- **shared_preferences**: Stores data locally for maintaining user sessions and preferences.  
- **http**: Enables making HTTP requests to interact with APIs or fetch data from the web.  
- **dart_jsonwebtoken**: Handles JSON Web Tokens (JWT) for authentication and authorization.  
- **image_picker**: Provides functionality for picking images or videos from the device gallery or camera.  
- **pie_chart**: Used for creating visually appealing pie charts in the app.  
- **intl**: Formats dates, numbers, currencies, and supports multi-language features.  

---

## Back-End  

### Technology Stack  
We use **Node.js** with **Express.js** to build the backend API.  

### Libraries  
Below are the essential libraries utilized in the back-end:  

- **jsonwebtoken (JWT)**: Manages authentication and authorization through tokens.  
- **bcrypt**: Encrypts user passwords to enhance security.  
- **multer**: Handles image uploads. Images are converted to Base64 format for communication with the front-end.  

### Back-End File Structure 
- **app.js**: The core file where the Express app is initialized and routes are set up.  
- **authentication.js**: Includes functionality for JWT-based authentication and password hashing using Bcrypt.  
- **db.js**: Contains the configuration and queries for connecting to the MySQL database.  
- **final-mobile_database.sql**: SQL file that contains the database schema and sample data for initializing the application.  
- **uploaderFile.js**: Implements image uploading using Multer and converts images to Base64 for communication with the front-end.  
- **DataBase_Design.png**: A visual representation of the database schema to aid in understanding the database structure.
- **Image folder**: Use with multer to store image file
  
---
