use <threads.scad>;

$fa = 5;
$fs = 1;

module VacuumClamp(
    part = "base",
    size = [ 110, 110 ],
    totalHoleArea = 8,
    holeSpacing = [ 15, 15 ],
    minHoleDiameter = 0.3,
    baseWallThick = 3, // amount of material between sections under vacuum and the outside
    mountHoleDiameter = 8,
    rotateMountWings = true,
    gasketThick = 6.35,
    gasketWallThick = 3, // space between each of the square cells in the gasket
    exactHoleDiameter = 0.1, // set low, for drilling after printing; set to undef to actual print the calculated hole size
    gasketCutoutToolDiameter = 1.5, // kerf/diameter of tool used to cut gasket, used so offcuts form a decent seal
    locatingPins = true,
    locatingHoleDiameter = 3.1,
    locatingHolePositions = [ -50, -20, 20, 50 ],
    gasketCompression = 0.75 // Compressed thickness of gasket is gasketCompression * gasketThick
) {
    
    // Small vacuum choke holes on surface of base, parameters
    numHolesX = floor((size[0] - gasketWallThick) / holeSpacing[0]);
    numHolesY = floor((size[1] - gasketWallThick) / holeSpacing[1]);
    holesStartX = (size[0] - (numHolesX - 1) * holeSpacing[0]) / 2;
    holesStartY = (size[1] - (numHolesY - 1) * holeSpacing[1]) / 2;
    holesEndX = size[0] - holesStartX;
    holesEndY = size[1] - holesStartY;
    numHoles = numHolesX * numHolesY;
    calcHoleDiameter = 2 * sqrt(totalHoleArea / numHoles / PI);
    drillHoleDiameter = (calcHoleDiameter >= minHoleDiameter) ? calcHoleDiameter : minHoleDiameter;
    holeDiameter = (exactHoleDiameter != undef) ? exactHoleDiameter : drillHoleDiameter;
    if (calcHoleDiameter < minHoleDiameter) {
        echo("Calculated hole diameter", calcHoleDiameter, "is smaller than min hole diameter", minHoleDiameter);
    }
    
    // Gasket parameters
    gasketHoleClearance = gasketWallThick;
    gasketHoleSize = min(holeSpacing[0], holeSpacing[1]) - gasketHoleClearance;
    echo("Gasket hole size", gasketHoleSize);
    
    // Base Z spacing
    // Base Z sections are: Bottom, Internal Tube, Connecting (lower) Taper, Constriction Hole, Drill Positioning (upper) Taper, Counterbore
    // Also, on top of base (but not part of baseThick) are the positioning rings
    baseBottomThick = baseWallThick;
    internalTubeDiameter = min(holeSpacing[0] * 0.75, holeSpacing[1] * 0.75, 11);
    lowerTaperHeight = internalTubeDiameter/2 + internalTubeDiameter * 0.2; // the height of this taper starts at the centerline of the internal tubes
    constrictionHoleHeight = max(baseWallThick - (lowerTaperHeight - internalTubeDiameter/2), 1);
    upperTaperHeight = 0.4;
    counterboreHeight = 1.5;
    
    baseThick = baseBottomThick + internalTubeDiameter + max(baseWallThick, lowerTaperHeight - internalTubeDiameter/2 + constrictionHoleHeight) + upperTaperHeight + counterboreHeight;
    
    internalTubeCenterZ = baseBottomThick + internalTubeDiameter/2;
    upperTaperStartZ = baseThick - counterboreHeight - upperTaperHeight;
    counterboreStartZ = baseThick - counterboreHeight;
    
    posRingThick = max(gasketCutoutToolDiameter * 1.1, 1);
    posRingHeight = gasketThick * gasketCompression;
    
    // Drill pass parameters, for drilling holes after printing
    // Parameters are based on an origin of the drill on top of the first hole, tip at the surface of the base inside the counterbore
    drillHeightClearance = 1.5; // added depth, and added safety height, to account for surface level variations
    // This is the depth to drill downwards in a drilling pass, from the drill resting on the surface of the base, inside the counterbore
    echo("Drill depth", upperTaperHeight + constrictionHoleHeight + (lowerTaperHeight - internalTubeDiameter/2) + drillHeightClearance);
    echo("Drill safe height", counterboreHeight + posRingHeight + drillHeightClearance);
    echo("Drill diameter", drillHoleDiameter);
    echo("Drill num holes x,y", numHolesX, numHolesY);
    echo("Drill spacing x,y", holeSpacing[0], holeSpacing[1]);
    echo("Start edge offset x,y", holesStartX, holesStartY);
    
    upperTaperDiameter = max(holeDiameter * 2, 1);
    counterboreDiameter = min(9, min(holeSpacing[0], holeSpacing[1]) - gasketWallThick - 2*posRingThick);
    
    module VacuumClampBase() {
        // 1/8" npt (values in imperial)
        nptDia = 0.405;
        nptTpi = 27;
        nptLength = 3/8;
        
        threadHoleDepth = nptLength * 25.4 - 0.5; // metric
        threadHolePosX = rotateMountWings ? size[0] * 0.25 : size[0] / 2;
        
        difference() {
            // Base block
            cube([ size[0], size[1], baseThick ]);
            
            // Pipe thread
            translate([ threadHolePosX, -0.5, internalTubeCenterZ ])
                rotate([ -90, 0, 0 ])
                    english_thread(diameter=0.405, threads_per_inch=27, length=3/8, taper=1/16, internal=true);
            
            // Holes
            for (x = [ holesStartX : holeSpacing[0] : holesEndX ])
                for (y = [ holesStartY : holeSpacing[1] : holesEndY ])
                    translate([ x, y, internalTubeCenterZ ])
                        cylinder(r=holeDiameter/2, h=1000, $fn=10);
            
            // Internal tapers for easier hole printing
            for (x = [ holesStartX : holeSpacing[0] : holesEndX ])
                for (y = [ holesStartY : holeSpacing[1] : holesEndY ])
                    translate([ x, y, internalTubeCenterZ ])
                        cylinder(r1=internalTubeDiameter/2, r2=holeDiameter/2, h=lowerTaperHeight, $fn=10);
            
            // Counterbores
            for (x = [ holesStartX : holeSpacing[0] : holesEndX ])
                for (y = [ holesStartY : holeSpacing[1] : holesEndY ])
                    translate([ x, y, counterboreStartZ ])
                        cylinder(r=counterboreDiameter/2, h=1000);
                
            // Upper taper
            for (x = [ holesStartX : holeSpacing[0] : holesEndX ])
                for (y = [ holesStartY : holeSpacing[1] : holesEndY ])
                    translate([ x, y, upperTaperStartZ ])
                        cylinder(r1=holeDiameter/2, r2=upperTaperDiameter/2, h=upperTaperHeight, $fn=10);
            
            // Internal tubes parallel to X axis
            for (y = [ holesStartY : holeSpacing[1] : holesEndY ])
                translate([ holesStartX - holeDiameter/2, y, internalTubeCenterZ ])
                    rotate([ 0, 90, 0 ])
                        cylinder(r=internalTubeDiameter/2, h=(numHolesX - 1) * holeSpacing[0] + holeDiameter);
            
            // Central manifold internal tube
            translate([ size[0] / 2, holesStartY - holeDiameter/2, internalTubeCenterZ ])
                rotate([ -90, 0, 0 ])
                    cylinder(r=internalTubeDiameter/2, h=(numHolesY - 1) * holeSpacing[1] + holeDiameter);
            
            // Connection from pipe thread to central tube
            nptConnLen = holesStartY - threadHoleDepth + 0.25;
            if (nptConnLen > 0) {
                translate([ threadHolePosX, threadHoleDepth - 0.25, internalTubeCenterZ ])
                    rotate([ -90, 0, 0 ])
                        cylinder(r=max(nptDia*25.4/2, internalTubeDiameter/2), h=nptConnLen);
            }
        };
        
        // Positioning rings that fit into gasket
        for (x = [ holesStartX : holeSpacing[0] : holesEndX ])
                for (y = [ holesStartY : holeSpacing[1] : holesEndY ])
                    translate([ x, y, baseThick ])
                        linear_extrude(posRingHeight)
                            difference() {
                                square([ gasketHoleSize, gasketHoleSize ], center=true);
                                square([ gasketHoleSize - posRingThick*2, gasketHoleSize - posRingThick*2 ], center=true);
                            };
        
        module MountHoleWing() {
            holeClearance = mountHoleDiameter;
            wingThick = baseThick / 2;
            difference() {
                union() {
                    translate([ -mountHoleDiameter/2 - holeClearance,  -(mountHoleDiameter + 2 * holeClearance)/2, 0 ])
                        cube([ mountHoleDiameter/2 + holeClearance, mountHoleDiameter + 2 * holeClearance, wingThick ]);
                    translate([ -mountHoleDiameter/2 - holeClearance, 0, 0 ])
                        cylinder(r=mountHoleDiameter/2 + holeClearance, h=wingThick);
                };
                translate([ -mountHoleDiameter/2 - holeClearance, 0, 0 ])
                        cylinder(r=mountHoleDiameter/2, h=wingThick);
            };
        }
        if (rotateMountWings) {
            translate([ size[0] / 2, 0, 0 ])
                rotate([ 0, 0, 90 ])
                    MountHoleWing();
            translate([ size[0] / 2, size[1], 0 ])
                rotate([ 0, 0, -90 ])
                    MountHoleWing();
        } else {
            translate([ 0, size[1]/2, 0 ])
                MountHoleWing();
            translate([ size[0], size[1]/2, 0 ])
                mirror([ 1, 0, 0 ])
                    MountHoleWing();
        }
        
        // Locating pin holes
        locatingHoleWallThick = 3;
        locatingHoleBottomThick = 1;
        locatingHoleOD = locatingHoleDiameter + locatingHoleWallThick*2;
        module LocatingPinHole() {
            difference() {
                linear_extrude(baseThick)
                    union() {
                        circle(r=locatingHoleOD/2);
                        translate([ -locatingHoleOD/2, -locatingHoleOD/2 ])
                            square([ locatingHoleOD, locatingHoleOD/2 ]);
                    };
                translate([ 0, 0, locatingHoleBottomThick ])
                    cylinder(r=locatingHoleDiameter/2, h=1000, $fn=30);
            };
        }
        locatingPinY = size[1] + locatingHoleOD / 2;
        echo("First vacuum hole to locating pin center offset", [ size[0] / 2 - holesStartX, locatingPinY - holesStartY ]);
        if (locatingPins) {
            for (x = locatingHolePositions)
                translate([ x + size[0] / 2, locatingPinY, 0 ])
                    LocatingPinHole();
        }
    }
    
    module VacuumClampGasket2D() {
        difference() {
            square([ size[0], size[1] ]);
            for (x = [ holesStartX : holeSpacing[0] : holesEndX ])
                for (y = [ holesStartY : holeSpacing[1] : holesEndY ])
                    translate([ x, y ])
                        square([ gasketHoleSize, gasketHoleSize ], center=true);
        };
    }
    
    module VacuumClampGasket() {
        linear_extrude(gasketThick)
            VacuumClampGasket2D();
    }
    
    if (part == "base") {
        VacuumClampBase();
    } else if (part == "gasket") {
        VacuumClampGasket();
    } else if (part == "gasket2d") {
        VacuumClampGasket2D();
    }
}


VacuumClamp(part = "base", size = [ 110, 110 ], totalHoleArea = 8, holeSpacing = [ 15, 15 ]);
//VacuumClamp(part = "base", size = [ 150, 200 ], totalHoleArea = 8, holeSpacing = [ 15, 15 ]);

