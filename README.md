# collection-manager
A full-stack application for a video game collection database manager using Node.js and JQuery with XAMPP. It is designed to help keep track of a video game memorabilia collection and all adjacent items. While current iteration provides features like searching, editing, adding, and deleting records of physical copies of video games and consoles, the underlying database offers a wider range of relations that will be implemented in future versions.

### Requirements: 
- XAMPP
- Node.js
- npm

### Set-up:
1) Start Apache and MySQL in XAMPP Control Panel
2) Import game_collection.sql in phpMyAdmin: use credentials "testuser" and "mypassword" or adjust the ones in config.js
3) Install dependencies in project folder: npm install express mysql cors body-parser

### Running Instructions: 
1) Run command - npm start
2) Open viewGames.html (recommended starting point)
