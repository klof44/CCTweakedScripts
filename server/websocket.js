const fs = require('fs');
const { WebSocketServer } = require('ws');
const zlib = require('zlib');

// 10 FPS is the best looking framerate I was able to achieve
const RATE = 10;
// For some reason, advanced computers get exponentially slower with larger messages
// Messages can be chunked to decrease the size of each message, but video may freeze
const CHUNK_SIZE = 1;

let registered = 0;
let completedFrame = 0;

const payload = JSON.parse(fs.readFileSync('./videos/vid.json'));
const wss = new WebSocketServer({ port: 7280 });
wss.on('connection', (ws, req) => {
	console.log(`Connected: ${req.connection.remoteAddress}`);
	ws.on('message', msg => {
		console.log(msg.toString());

		if (msg.toString() === 'INFO') {
			ws.send(JSON.stringify({ info: { chunks: Math.ceil(payload.payload.length / CHUNK_SIZE), rate: RATE } }));
		}

		if (msg.toString() === 'AUDIO') {
			fs.readFile('./videos/audio.dfpwm', (err, data) => {
				if (err) throw err;
				zlib.deflateRaw(data, (err, buffer) => {
					if (err) throw err;
					ws.send(buffer);
				});
			});
		}

		if (!isNaN(msg.toString())) {
			let i = Number(msg.toString());
			if (i >= 0 && i < Math.ceil(payload.payload.length / CHUNK_SIZE)) {
				data = []
				for (let j = 0; j < CHUNK_SIZE; j++) {
					data.push(payload.payload[i * CHUNK_SIZE + j]);
				}
				zlib.deflateRaw(JSON.stringify(data), (err, buffer) => {
					if (err) throw err;
					ws.send(buffer);
				});
			}
			else {
				zlib.deflateRaw(JSON.stringify({ error: 'Invalid chunk' }), (err, buffer) => {
					ws.send(buffer);
				});
			}
		}
	});
});