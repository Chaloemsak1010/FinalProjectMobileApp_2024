# FinalProjectMobileApp_2024
1305216 Mobile Application Development (1/2567)

# Asset Borrowing System
Overview
The Asset Borrowing System is designed to facilitate the borrowing and management of assets for students, staff, and lecturers. The system categorizes users into three roles: Borrower (Student), Staff, and Lender (Lecturer), each with specific functionalities. The system ensures proper tracking, approval, and history logging of asset borrowing and returning activities.

Features
Roles and Functionalities
Borrower (Student)
Register / Login
Students can register and log in to access the system.
Note: Student details are stored in the database.

Browse Asset List
View a list of assets with their statuses:

Available
Pending
Borrowed
Disabled
Request to Borrow
Students can request to borrow an asset by specifying:

Borrowing date (must be today)
Return date (must be today or later)
Restrictions: Only one asset can be borrowed per day.
Check Request Status
View the status of borrowing requests (Approved, Pending, or Rejected).

View History
Access personal borrowing and returning history, including:

Asset name
Borrowing and return dates
Approval and returning details
Logout
Exit the system securely.

Staff
Login
Authenticate and access staff-specific functionalities.

Browse Asset List
View and manage a list of assets with their statuses.

Manage Assets
Add, edit, or disable assets.
Note: Only assets with the "Available" status can be disabled.

Dashboard
Monitor asset status at a glance:

Number of borrowed assets
Number of available assets
Number of disabled assets
View History
Access borrowing and returning history for all users, including:

Asset name
Borrowing and return dates
Who borrowed
Approval details
Who returned the asset
Get Returning Asset
Confirm the return of an asset and update its status to "Available."

Logout
Exit the system securely.

Lender (Lecturer)
Login
Authenticate and access lecturer-specific functionalities.

Browse Asset List
View the list of assets and their statuses.

Approve / Reject Borrowing Requests
Manage borrowing requests by:

Approving (changes asset status to "Borrowed")
Rejecting (returns asset status to "Available")
View History
Access personal borrowing and returning history, including:

Asset name
Borrowing and return dates
Approval and returning details
Logout
Exit the system securely.

Remarks
Each asset has a unique ID and is tracked in the system.
Borrowing requests can only be made for "Available" assets.
Asset statuses are automatically updated based on user actions.
