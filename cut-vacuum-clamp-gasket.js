let squareHoleSize = 12;
let holeSpacing = [ 15, 15 ];
let numHoles = [ 7, 7 ];
let size = [ 110, 110 ];
let cutterDiameter = 1.5;
let totalCutDepth = (1/4) * 25.4 + 0.5;
let passCutDepth = 0.5;
let safeZ = 5;
let cutFeedRate = 400;


let holeOffset = [
	(size[0] - holeSpacing[0] * (numHoles[0] - 1)) / 2,
	(size[1] - holeSpacing[1] * (numHoles[1] - 1)) / 2
];
let cutterRadius = cutterDiameter / 2;


console.log('M3');
console.log('M8');
console.log('G4 P5');

// Work offset should be Z->surface of the gasket, X,Y->centered on the front-left origin

for (let holeNumX = 0; holeNumX < numHoles[0]; holeNumX++) {
	for (let holeNumY = 0; holeNumY < numHoles[1]; holeNumY++) {
		let holeCenterX = holeOffset[0] + holeNumX * holeSpacing[0];
		let holeCenterY = holeOffset[1] + holeNumY * holeSpacing[1];
		go(null, null, safeZ);
		go(holeCenterX - squareHoleSize / 2 + cutterRadius, holeCenterY - squareHoleSize / 2 + cutterRadius, null);
		go(null, null, 0);

		for (let z = -passCutDepth; z > -totalCutDepth - passCutDepth; z -= passCutDepth) {
			if (z < -totalCutDepth) z = -totalCutDepth;
			go(null, null, z, cutFeedRate);
			go(null, holeCenterY + squareHoleSize / 2 - cutterRadius, null, cutFeedRate);
			go(holeCenterX + squareHoleSize / 2 - cutterRadius, null, null, cutFeedRate);
			go(null, holeCenterY - squareHoleSize / 2 + cutterRadius, null, cutFeedRate);
			go(holeCenterX - squareHoleSize / 2 + cutterRadius, null, null, cutFeedRate);
		}
	}
}

go(null, null, safeZ);
go(-cutterRadius, -cutterRadius, null);
go(null, null, 0);
for (let z = -passCutDepth; z > -totalCutDepth - passCutDepth; z -= passCutDepth) {
	if (z < -totalCutDepth) z = -totalCutDepth;
	go(null, null, z, cutFeedRate);
	go(-cutterRadius, size[1] + cutterRadius, null, cutFeedRate);
	go(size[0] + cutterRadius, size[1] + cutterRadius, null, cutFeedRate);
	go(size[0] + cutterRadius, -cutterRadius, null, cutFeedRate);
	go(-cutterRadius, -cutterRadius, null, cutFeedRate);
}

go(null, null, safeZ);
go(0, 0, null);


function go(x, y, z, f) {
	console.log(
		(f ? 'G1' : 'G0') +
		(typeof x === 'number' ? ` X${x}` : '') +
		(typeof y === 'number' ? ` Y${y}` : '') +
		(typeof z === 'number' ? ` Z${z}` : '') +
		(f ? ` F${f}` : '')
	);
}

console.log('M5');
console.log('M9');

