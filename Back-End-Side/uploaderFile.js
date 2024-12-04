// MIT License Copyright (c) 2024 Chaloemsak Arsung

// <--------------------  Image Upload System  -------------------->
const multer = require("multer");
const path = require("path");

// Storage for assets
const storage_Assets = multer.diskStorage({
  destination: function (req, file, callback) {
    callback(null, `./images/assets`);
  },
  filename: function (req, file, callback) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const extension = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, extension);
    callback(null, `${baseName}-${uniqueSuffix}${extension}`);
  },
});

// Storage for user profiles
const storage_Profiles = multer.diskStorage({
  destination: function (req, file, callback) {
    callback(null, `./images/profiles`);
  },
  filename: function (req, file, callback) {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const extension = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, extension);
    callback(null, `${baseName}-${uniqueSuffix}${extension}`);
  },
});

// Export multer configurations
const uploadAssets = multer({ storage: storage_Assets });
const uploadProfiles = multer({ storage: storage_Profiles });

module.exports = { uploadAssets, uploadProfiles };
