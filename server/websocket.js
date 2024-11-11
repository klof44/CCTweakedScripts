const fs = require('fs');
const { WebSocketServer } = require('ws');

const payload = JSON.parse(fs.readFileSync('./videos/vid.json'));
const CHUNK_SIZE = 32;
const wss = new WebSocketServer({ port: 7280 });
wss.on('connection', (ws, req) => {
	console.log(`Connected: ${req.connection.remoteAddress}`);
	ws.on('message', msg => {
		if (msg === 'INFO') {
			ws.send(JSON.stringify({ info: { chunks: Math.ceil(payload.payload.length / CHUNK_SIZE) } }));
		}

		if (msg.startsWith('CHUNK')) {
			let chunk = Number(msg.split(' ')[1]);
			let data = [];

			if (chunk * CHUNK_SIZE >= payload.payload.length) {
				data = payload.payload.slice(chunk * CHUNK_SIZE);
			}
			else {
				data = payload.payload.slice(chunk * CHUNK_SIZE, chunk * CHUNK_SIZE + CHUNK_SIZE);
			}
			
			ws.send(JSON.stringify({ chunk: data }));
		}
	});
});