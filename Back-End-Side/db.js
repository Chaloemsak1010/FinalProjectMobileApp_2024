const mysql = require('mysql2');
const connection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'final-mobile' ,
    multipleStatements: true // Enable multiple statements for multiple sql cmd in 1 time
});

// catch errors
connection.connect((err) => {
    if(err){
        console.error('Error connecting to the database AT db.js :', err);
        return;
    }
    console.log('Connected to the database.');

})

module.exports = connection;
