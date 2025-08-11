const express = require("express");
const router = express.Router();
const dbConnection = require("../config");


/**
 * @api {get} /options/gamenames Get all game names
 * @apiName GetGameNames
 * @apiGroup Options
 *
 * @apiSuccess {String[]} gameNames List of distinct game names.
 */
router.get('/gamenames', (req, res) => {
    dbConnection.query('SELECT DISTINCT GameName FROM Game_Names ORDER BY GameName ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.GameName));
    });
});

/**
 * @api {get} /options/regions Get all regions
 * @apiName GetRegions
 * @apiGroup Options
 *
 * @apiSuccess {String[]} regions List of distinct regions.
 */
router.get('/regions', (req, res) => {
    dbConnection.query('SELECT DISTINCT Region FROM Regions ORDER BY Region ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.Region));
    });
});

/**
 * @api {get} /options/conditions Get all conditions
 * @apiName GetConditions
 * @apiGroup Options
 *
 * @apiSuccess {String[]} conditions List of distinct conditions.
 */
router.get('/conditions', (req, res) => {
    dbConnection.query('SELECT DISTINCT `Condition` FROM `Condition` ORDER BY `Condition` ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.Condition));
    });
});

/**
 * @api {get} /options/sealorcibs Get all SealOrCIB values
 * @apiName GetSealOrCIB
 * @apiGroup Options
 *
 * @apiSuccess {String[]} sealOrCIB List of SealOrCIB values.
 */
router.get('/sealorcibs', (req, res) => {
    dbConnection.query('SELECT DISTINCT SealOrCIB FROM SealOrCIB ORDER BY SealOrCIB ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.SealOrCIB));
    });
});

/**
 * @api {get} /options/consoles Get all console models
 * @apiName GetConsoles
 * @apiGroup Options
 *
 * @apiSuccess {String[]} modelNames List of distinct console model names.
 */
router.get('/consoles', (req, res) => {
    dbConnection.query('SELECT DISTINCT ModelName FROM Console_Models ORDER BY ModelName ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.ModelName));
    });
});

/**
 * @api {get} /options/series Get all game series
 * @apiName GetSeries
 * @apiGroup Options
 *
 * @apiSuccess {String[]} series List of distinct game series.
 */
router.get('/series', (req, res) => {
    dbConnection.query('SELECT DISTINCT Series FROM Series ORDER BY Series ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.Series));
    });
});

/**
 * @api {get} /options/genres Get all game genres
 * @apiName GetGenres
 * @apiGroup Options
 *
 * @apiSuccess {String[]} genres List of distinct game genres.
 */
router.get('/genres', (req, res) => {
    dbConnection.query('SELECT DISTINCT Genre FROM Genres ORDER BY Genre ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.Genre));
    });
});

/**
 * @api {get} /options/peripherals Get all peripheral names
 * @apiName GetPeripherals
 * @apiGroup Options
 *
 * @apiSuccess {String[]} peripherals List of distinct peripheral names.
 */
router.get('/peripherals', (req, res) => {
    dbConnection.query('SELECT DISTINCT PeripheralName FROM Peripheral_Names ORDER BY PeripheralName ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.PeripheralName));
    });
});

/**
 * @api {get} /options/ratings Get all ESRB ratings
 * @apiName GetRatings
 * @apiGroup Options
 *
 * @apiSuccess {String[]} ratings List of distinct ESRB ratings.
 */
router.get('/ratings', (req, res) => {
    dbConnection.query('SELECT DISTINCT Rating FROM ESRB_Ratings ORDER BY Rating ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.Rating));
    });
});

/**
 * @api {get} /options/consolepublishers Get all console publishers
 * @apiName GetConsolePublishers
 * @apiGroup Options
 *
 * @apiSuccess {String[]} publishers List of distinct console publishers.
 */
router.get('/consolepublishers', (req, res) => {
    dbConnection.query('SELECT DISTINCT ConsolePublisher FROM Console_Publishers ORDER BY ConsolePublisher ASC;', (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json(result.map(r => r.ConsolePublisher));
    });
});

module.exports = router;
