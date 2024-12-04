# FinalProjectMobileApp_2024
1305216 Mobile Application Development (1/2567)

# Asset Borrowing System
Overview
The Asset Borrowing System is designed to facilitate the borrowing and management of assets for students, staff, and lecturers. The system categorizes users into three roles: Borrower (Student), Staff, and Lender (Lecturer), each with specific functionalities. The system ensures proper tracking, approval, and history logging of asset borrowing and returning activities.

# Front-End-Side
* We use Flutter to create ui app
Library u need to know:
* shared_preferences
* http --> Enables making HTTP requests to interact with APIs or fetch data from the web.
* dart_jsonwebtoken --> Handles JSON Web Tokens (JWT) for authentication and authorization
* image_picker --> Provides functionality for picking images or videos from the device gallery or camera.
* pie_chart --> Used for creating visually appealing pie charts in the app.
* intl --> Formatting dates, numbers, currencies, or implementing multi-language support.


# Back-End-Side
Library u need to know: 
* JWT --> Authentication and Authorization
* Bcrypt --> Hash password
* Multer --> Image System **Note: We convert image to Base64 for send image back to front-end**
