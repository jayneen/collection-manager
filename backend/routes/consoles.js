const express = require("express");
const router = express.Router();
const dbConnection = require("../config");


/**
 * @api {get} /consoles Retrieve all console records
 * @apiName GetAllConsoles
 * @apiGroup Consoles
 *
 * @apiSuccess {Object[]} consoles List of all consoles.
 * @apiSuccessExample {json} Success-Response:
 *  HTTP/1.1 200 OK
 *  [
 *    {
 *      "UID": 1,
 *      "ModelName": "Nintendo 64",
 *      "Region": "USA",
 *      ...
 *    }
 *  ]
 */
router.get('/', (request, response) => {
    const sqlQuery = "SELECT * FROM Consoles;";
    dbConnection.query(sqlQuery, (err, result) => {
        if (err) {
            return response.status(400).json({ Error: "Error in the SQL statement. Please check." });
        }
        response.setHeader('SQLQuery', sqlQuery); // send a custom header attribute
        return response.status(200).json(result);
    });
});

/**
 * @api {get} /consoles/:uid Retrieve console by UID
 * @apiName GetConsoleByUID
 * @apiGroup Consoles
 *
 * @apiParam {Number} uid Console's unique ID.
 *
 * @apiSuccess {Object} console Console data with peripherals.
 * @apiSuccessExample {json} Success-Response:
 *  HTTP/1.1 200 OK
 *  [
 *    {
 *      "UID": 1,
 *      "ModelName": "Super NES",
 *      "Region": "USA",
 *      "PeripheralName": "Controller",
 *      ...
 *    }
 *  ]
 */
router.get('/:uid', (request, response) => {
    const uid = request.params.uid;
    const sqlQuery = `
  SELECT 
    Consoles.UID,
    Consoles.ModelName,
    Consoles.Region, 
    Console_Has_a_Peripheral.PeripheralName,
    Consoles.\`Condition\`,
    Consoles.SealOrCIB,
    Consoles.Notes
  FROM Consoles
  LEFT JOIN Console_Has_a_Peripheral ON Consoles.ModelName = Console_Has_a_Peripheral.ModelName
  WHERE Consoles.UID = ?
  GROUP BY 
    Consoles.UID,
    Consoles.ModelName,
    Consoles.Region,
    Console_Has_a_Peripheral.PeripheralName, 
    Consoles.\`Condition\`, 
    Consoles.SealOrCIB, 
    Consoles.Notes;
`;

    dbConnection.query(sqlQuery, [uid], (err, result) => {
        if (err) {
            console.error("Error: " + err);
            return response.status(400).json({ Error: "Error in the SQL statement. Please check." });
        }
        response.setHeader('UID', uid); // send a custom
        return response.status(200).json(result);
    });
});

/**
 * @api {post} /consoles Add a new console copy
 * @apiName AddConsoleCopy
 * @apiGroup Consoles
 *
 * @apiBody {String} modelName Name of the console model.
 * @apiBody {String} [notes] Optional notes.
 * @apiBody {String} condition Console condition.
 * @apiBody {String} [sealOrCIB] Optional seal/CIB info.
 * @apiBody {String} region Console region.
 *
 * @apiSuccess {String} Success Message.
 */
router.post('/', (req, res) => {
    const { modelName, notes, condition, sealOrCIB, region } = req.body;

    // Build the insert dynamically
    const columns = ['ModelName', '\`Condition\`', 'Region'];
    const values = [modelName, condition, region];

    if (notes && notes.trim() !== '') {
        columns.push('Notes');
        values.push(notes.trim());
    }

    if (sealOrCIB && sealOrCIB.trim() !== '') {
        columns.push('SealOrCIB');
        values.push(sealOrCIB.trim());
    }

    const placeholders = columns.map(() => '?').join(', ');
    const sqlQuery = `INSERT INTO Consoles (${columns.join(', ')}) VALUES (${placeholders});`;

    dbConnection.query(sqlQuery, values, (err, result) => {
        if (err) {
            console.error("Insert error:", err);
            return res.status(400).json({ Error: "Failed to add record." });
        }
        return res.status(200).json({ Success: "Console added successfully!" });
    });
});

/**
 * @api {post} /consoles/consolemodels Add a new console model
 * @apiName AddConsoleModel
 * @apiGroup Consoles
 *
 * @apiBody {String} modelName Model name.
 * @apiBody {String} modelNumber Model number.
 * @apiBody {String} consolePublisher Console publisher name.
 *
 * @apiSuccess {String} Success Message.
 */
router.post('/consolemodels', (req, res) => {
    const { modelName, modelNumber, consolePublisher } = req.body;

    const columns = ['ModelName', 'ModelNumber', 'ConsolePublisher'];
    const values = [modelName, modelNumber, consolePublisher];
    const placeholders = columns.map(() => '?').join(', ');

    const query = (sql, params) => new Promise((resolve, reject) => {
        dbConnection.query(sql, params, (err, result) => err ? reject(err) : resolve(result));
    });

    (async () => {
        const conn = dbConnection;

        // Start a manual transaction
        conn.beginTransaction(async (err) => {
            if (err) {
                console.error("Transaction start error:", err);
                return res.status(500).json({ Error: "Failed to start transaction." });
            }
            try {
                // Insert into Console_Models
                await query(`INSERT IGNORE INTO Console_Publishers (ConsolePublisher) VALUES (?)`, [consolePublisher]);
                await query(`INSERT INTO Console_Models (${columns.join(', ')}) VALUES (${placeholders})`, values);
                
                // If everything succeeded, commit
                conn.commit((err) => {
                    if (err) {
                        conn.rollback(() => {
                            console.error("Commit failed, rolled back:", err);
                            return res.status(500).json({ Error: "Failed to commit transaction." });
                        });
                    } else {
                        res.status(200).json({ Success: "Console model added successfully!" });
                    }
                });
            } catch (err) {
                // On any error, rollback everything
                conn.rollback(() => {
                    console.error("Transaction rolled back due to error:", err);
                    res.status(400).json({ Error: "Failed to add record. Transaction cancelled." });
                });
            }
        });
    })();
});

/**
 * @api {put} /consoles Update a console record
 * @apiName UpdateConsole
 * @apiGroup Consoles
 *
 * @apiBody {Number} uid UID of the console.
 * @apiBody {String} condition New condition value.
 * @apiBody {String} sealOrCIB New seal/CIB value.
 * @apiBody {String} notes New notes value.
 *
 * @apiSuccess {String} Success Message.
 * @apiError {String} Error Message.
 */
router.put('/', (request, response) => {
    const { uid, condition, sealOrCIB, notes } = request.body;
    if (!uid) {
        return response.status(400).json({ Error: "UID is required for update." });
    }
    const sqlQuery = `
        UPDATE Consoles 
        SET \`Condition\` = ?, SealOrCIB = ?, Notes = ?
        WHERE UID = ?;
    `;
    const values = [condition, sealOrCIB, notes, uid];
    dbConnection.query(sqlQuery, values, (err, result) => {
        if (err) {
            console.error("SQL Error:", err);
            return response.status(400).json({ Error: "Failed to update record." });
        }
        if (result.affectedRows === 0) {
            return response.status(404).json({ Error: "No record found with that UID." });
        }
        return response.status(200).json({ Success: "Record successfully updated." });
    });
});

/**
 * @api {delete} /consoles/:uid Delete a console by UID
 * @apiName DeleteConsole
 * @apiGroup Consoles
 *
 * @apiParam {Number} uid Console's UID.
 *
 * @apiSuccess {String} Success Message.
 * @apiError {String} Error Message.
 */
router.delete('/:uid', (request, response) => {
    const uid = request.params.uid;
    const sqlQuery = "DELETE FROM Consoles WHERE UID = ? ; ";
    dbConnection.query(sqlQuery, uid, (err, result) => {
        if (err) {
            return response.status(400).json({ Error: "Failed: Record was not deleted" });
        }
        return response.status(200).json({ Success: "Succcessful: Record was deleted!" });
    });
});


module.exports = router;
