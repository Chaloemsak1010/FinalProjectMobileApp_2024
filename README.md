# FinalProjectMobileApp_2024  
**1305216 Mobile Application Development (1/2567)**  

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

---
