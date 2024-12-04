// MIT License Copyright (c) 2024 Chaloemsak Arsung

const jwt = require('jsonwebtoken');
const JWT_SECRET_KEY = "MIKE016_LOL";

// <--------------------  AUTHENTICATION AND AUTHORIZATION  -------------------->
// ***TOKENs KEEP --> ID , USERNAME , ROLE
// ROLE in DB: Student , Staff , Lender
class Authentication {
  
  // =============== STUDENTs =================
  student_VERIFY(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (!token) {
      return res.status(400).send('No token');
    }
    if (req.headers.authorization) { // bearer ssdsdsd,dsfsd
      const tokenRaw = token.split(' ');
      if (tokenRaw[0] === 'Bearer') {
        token = tokenRaw[1];
      }
    }

    // Verify the token
    jwt.verify(token, JWT_SECRET_KEY, (err, decoded) => {
      if (err) {
        return res.status(401).send('Incorrect token');
      } else if (decoded.role !== 'Student') {
        return res.status(403).send('Forbidden to access this route');
      } else {
        req.decoded = decoded;
        next();
      }
    });
  }

  // =============== LENDERs =================
  lender_VERIFY(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (!token) {
      return res.status(400).send('No token');
    }
    if (req.headers.authorization) {
      const tokenRaw = token.split(' ');
      if (tokenRaw[0] === 'Bearer') {
        token = tokenRaw[1];
      }
    }

    // Verify the token
    jwt.verify(token, JWT_SECRET_KEY, (err, decoded) => {
      if (err) {
        return res.status(401).send('Incorrect token');
      } else if (decoded.role !== 'Lender') {
        return res.status(403).send('Forbidden to access this route');
      } else {
        req.decoded = decoded;
        next();
      }
    });
  }

  // =============== STAFFs =================
  staff_VERIFY(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (!token) {
      return res.status(400).send('No token');
    }
    if (req.headers.authorization) {
      const tokenRaw = token.split(' ');
      if (tokenRaw[0] === 'Bearer') {
        token = tokenRaw[1];
      }
    }

    // Verify the token
    jwt.verify(token, JWT_SECRET_KEY, (err, decoded) => {
      if (err) {
        return res.status(401).send('Incorrect token');
      } else if (decoded.role !== 'Staff') {
        return res.status(403).send('Forbidden to access this route');
      } else {
        req.decoded = decoded;
        next();
      }
    });
  }

  // =============== LENDERs AND STAFFs =================
  lenderAndStaff_VERIFY(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (!token) {
      return res.status(400).send('No token');
    }
    if (req.headers.authorization) {
      const tokenRaw = token.split(' ');
      if (tokenRaw[0] === 'Bearer') {
        token = tokenRaw[1];
      }
    }

    // Verify the token
    jwt.verify(token, JWT_SECRET_KEY, (err, decoded) => {
      if (err) {
        return res.status(401).send('Incorrect token');
      } else if (decoded.role !== 'Lender' && decoded.role !== 'Staff') {
        return res.status(403).send('Forbidden to access this route');
      } else {
        req.decoded = decoded;
        next();
      }
    });
  }

  // =============== ALL ROLE =================
  allROLE_VERIFY(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (!token) {
      return res.status(400).send('No token');
    }
    if (req.headers.authorization) {
      const tokenRaw = token.split(' ');
      if (tokenRaw[0] === 'Bearer') {
        token = tokenRaw[1];
      }
    }

    // Verify the token
    jwt.verify(token, JWT_SECRET_KEY, (err, decoded) => {
      if (err) {
        return res.status(401).send('Incorrect token');
        //                                          *** 1 and 1 and 1 == 1 : not lender not staff not student --> 403 Forbidden to access this route 
      } else if (decoded.role !== 'Lender' && decoded.role !== 'Staff' && decoded.role !== 'Student') {
        return res.status(403).send('Forbidden to access this route');
      } else {
        req.decoded = decoded;
        next();
      }
    });
  }
}

module.exports = new Authentication();
