let drillZ = -5.1;
let drillSafeZ = 8;
let numHoles = [ 7, 7 ];
let holeSpacing = [ 15, 15 ];
let firstHolePos = [ 0, 0 ];

let drillFeed = 80;
let zUpFeed = 120;

let peckDrill = true;
let peckDrillDepth = 1.8;
let peckDrillDwellSecs = 0;

console.log('M3');
console.log('G4 P5');

function drillHole() {
	if (peckDrill) {
		for (let z = -peckDrillDepth; z > drillZ - peckDrillDepth; z -= peckDrillDepth) {
			if (z < drillZ) z = drillZ;
			console.log(`G1 Z${z} F${drillFeed}`);
			console.log(`G1 Z0 F${zUpFeed}`);
			if (peckDrillDwellSecs) console.log(`G4 P${peckDrillDwellSecs}`);
		}
	} else {
		console.log(`G1 Z${drillZ} F${drillFeed}`);
		console.log(`G1 Z0 F${zUpFeed}`);
	}
}

for (holeNumX = 0; holeNumX < numHoles[0]; holeNumX++) {
	for (holeNumY = 0; holeNumY < numHoles[1]; holeNumY++) {
		let holeX = firstHolePos[0] + holeNumX * holeSpacing[0];
		let holeY = firstHolePos[1] + holeNumY * holeSpacing[1];
		console.log(`G0 Z${drillSafeZ}`);
		console.log(`G0 X${holeX} Y${holeY}`);
		console.log(`G0 Z0`);
		drillHole();
	}
}

console.log(`G0 Z${drillSafeZ}`);
console.log(`G0 X0 Y0`);
console.log('M5');

