const fs = require('fs');
const sharp = require('sharp');
const express = require('express');
const getPixels = require('get-pixels');

sharp('armada.png')
    .resize(121,81, sharp.fit.inside)
    .toFile('armada-small.png', (err, info) => {
        if (err) throw err;
    });

const app = express();
app.get('/', (req, res) => {
    res.send(fs.readFileSync('./public/image.lua', 'utf8'));
});
app.get('/test', (req, res) => {
    res.send(fs.readFileSync('./public/test.lua', 'utf8'));
});
app.get('/image', (req, res) => {
    // Iterate through every pixel of the image
    getPixels('armada-small.png', (err, pixels) => {
        if (err) throw err;
        let data = pixels.data;
        let width = pixels.shape[0];
        let height = pixels.shape[1];
        let result = [];
        for (let i = 0; i < data.length; i += 4) {
            let r = data[i];
            let g = data[i + 1];
            let b = data[i + 2];
            let a = data[i + 3];
            result.push(clampColour(r, g, b));
        }
        res.json({ result });
    });
});
app.listen(7270, () => {
    console.log('Server running on port 727');
});

function clampColour(r, g, b) {
    let colours = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768];

    var dec = getDec(r, g, b);

    var min = 0;
    var distance = 0;
    for (var i = 0; i < colours.length; i++) {
        var d = Math.abs(dec - colours[i]);
        if (i == 0 || d < distance) {
            min = i;
            distance = d;
        }
    }

    return colours[min];
}

function getDec(r, g, b) {
    return Math.round(((r << 16) + (g << 8) + b)/255);
}