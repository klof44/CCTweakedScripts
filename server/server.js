const fs = require('fs');
const sharp = require('sharp');
const express = require('express');
const getPixels = require('get-pixels');
const getColors = require('get-image-colors');
const { Worker } = require('worker_threads');
const dfpwm = require('dfpwm');

process.chdir(__dirname);

if (!fs.existsSync('./images')) {
	fs.mkdirSync('./images');
}
if (!fs.existsSync('./images-resized')) {
	fs.mkdirSync('./images-resized');
}

parseVideo();
const app = express();

app.use(express.static('./public'));

app.get('/', (req, res) => {
	res.send(fs.readFileSync('./public/image.lua'));
});

app.get('/image', (req, res) => {
	
	let width = Number(req.query.width);
	let height = Number(req.query.height);
	if (!width || !height) {
		res.json({ error: 'Missing width or height' });
		return;
	}

	let largeImage = "./images/" + req.query.image;
	let imgPath = `./images-resized/${largeImage.split('/').pop()}`;

	if (!fs.existsSync(largeImage)) {
		res.json({ error: 'Image not found' });
		return;
	}

	console.log(`Using image: ${largeImage}`);

	sharp(largeImage)
		.resize(width, height, { fit: sharp.fit.contain })
		.toFile(imgPath, (err, info) => {
			getPixels(imgPath, (err, pixels) => {
				if (err) throw err;
				let data = pixels.data;
				let result = [];
				getPalette(imgPath).then(palette => {
					for (let i = 0; i < data.length; i += 4) {
						let r = data[i];
						let g = data[i + 1];
						let b = data[i + 2];
						let a = data[i + 3];
						result.push(clampColour(r, g, b, palette));
					}
					result = result.map(c => numToBlit(c).toString());
					res.json({ data: result, palette });
				});
			});
		});
});

app.listen(7270, () => {
	console.log('Server running on port 727');
});

async function getPalette(imgPath) {
	let colors = await getColors(imgPath, { count: 16 });
	let palette = colors.map(color => Math.min(Math.max(parseInt(color.hex('rgb').replace('#', "0x"), 16), 0x111111), 0xF0F0F0));
	return palette;
}

function clampColour(r, g, b, palette) {
	var dec = getDec(r, g, b);

	var min = 0;
	var distance = 0;
	for (var i = 0; i < palette.length; i++) {
		var d = Math.abs(dec - palette[i]);
		if (i == 0 || d < distance) {
			min = i;
			distance = d;
		}
	}

	return min;
}

function getDec(r, g, b) {
	return ((r << 16) + (g << 8) + b);
}

function numToBlit(num) {
	if (num < 10) {
		return num.toString();
	}
	switch (num) {
		case 10:
			return 'a';
		case 11:
			return 'b';
		case 12:
			return 'c';
		case 13:
			return 'd';
		case 14:
			return 'e';
		case 15:
			return 'f';
	}
}

async function parseVideo() {
	let width = 143;
	let height = 81;
	if (!width || !height) {
		res.json({ error: 'Missing width or height' });
		return;
	}
	
	let promises = [];
	
	let files = fs.readdirSync('./videos/out/');
	let payload = [];
	files.forEach(file => {
		promises.push(new Promise((resolve, reject) => {
			let imgPath = `./videos/out-resized/${file}`;
			sharp(`./videos/out/${file}`)
				.resize(width, height, { fit: sharp.fit.contain })
				.toFile(imgPath, (err, info) => {
					getPixels(imgPath, (err, pixels) => {
						if (err) throw err;
						let data = pixels.data;
						let result = [];
						getPalette(imgPath).then(palette => {
							for (let i = 0; i < data.length; i += 4) {
								let r = data[i];
								let g = data[i + 1];
								let b = data[i + 2];
								let a = data[i + 3]; // transparency
								result.push(clampColour(r, g, b, palette));
							}
							result = result.map(c => numToBlit(c).toString());
			
							payload[Number(file.split('.')[0]) - 1] = { data: result, palette };
							resolve();
						});
					});
				});
		}));
	});

	let encoder = new dfpwm.Encoder();
	let audio = fs.readFileSync('./videos/output.pcm');
	let encoded = encoder.encode(audio);
	fs.writeFileSync('./videos/audio.dfpwm', encoded);

	Promise.allSettled(promises).then(() => {
		fs.writeFileSync('./videos/vid.json', JSON.stringify({ payload }));
		
		new Worker('./websocket.js');
	});
}