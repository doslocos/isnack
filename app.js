const express = require('express');
const momo = require('mongoose-morgan')
const path = require('path')
const app = express()
app.use(momo({
    autoReconnect: true,
    connectionString: 'mongodb://localhost:27017/debug',
    useNewUrlParser: true
}))
app.use(express.json())
app.use(express.urlencoded({extended: false}))
app.use(express.static(path.join(__dirname, 'public')))
const mongoose = require('mongoose')
mongoose.connect('mongodb://localhost:27017/world', {
  useNewUrlParser: true
}).then(() => {
    console.log(mongoose.connection)}, e => {console.log(e.stack)})
const record = mongoose.model('record', {
    name: {type: String, required: true},
    data: {type: Buffer, required: true},
    time: {type: Number, required: true},
    user: {type: String, required: true}
})
const router = require('express').Router({})
router.all('/', (req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Headers", "X-Requested-With")
    next()
})
router.get('/', (req, res) => {
    record.find({}, (err, result) => {
        if (err) console.log(err.stack)
        else res.json(result)
    })
})
router.get('/:name', (req, res) => {
    const filepath = __dirname + '/' + req.params.name
    record.findOne(req.params, (err, result) => {
        if (err) console.log(err.stack)
        else {
            res.header("Content-Type", "application/ubjson")
            res.header("Content-Length", result.data.buffer.length)
            res.send(result.data)
        }
    })
})
router.post('/', (req, res) => {
    const filename = req.body.name
    if (!filename) res.status(422).json({missing: 'name'})
    else {
        const filepath = __dirname + '/' + filename
        let binary = new Buffer(req.body.data)
        let insert = {name: filename, data: binary, time: (+new Date()), user: 'any'}
        let x = new record(insert).save().then((x) => {
          res.status(201).json(x)
        }, err => {console.log(err.stack); res.json(err)})
    }
})
router.delete('/:confirm', (req, res) => {
    if (req.params.confirm === 'ok') {
        record.deleteMany({}, (err, result) => {
            if (err) console.log(err.stack)
            else res.status(200).json(result)
        })
    }
})
router.patch('/', (req, res) => {if (req.params.confirm === 'ok') process.exit()})
router.options('/', (req, res) => {
    res.header('Allow', 'GET, HEAD, POST, PATCH, DELETE, OPTIONS').status(204).send()
})
app.use('/', router); app.listen(3000); module.exports = app
