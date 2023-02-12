/*

*/

include<hex plug library.scad>;

/* [Plate dimensions and configuration] */
Plate_length = 52;
Plate_width = 35;
Plate_thickness = 5;
Plate_shape = 0; // [0:Oval, 1:Rectangle, 2:Rounded rectangle]

/* [Magnet dimensions and configuration] */
Magnet_width = 10;
Magnet_thickness = 2;
Magnet_Length = 20;
Distance_magnet_under_plate_surface = 0.4;
Magnet_shape = 0; // [0:Rectangle, 1:Circle - use width, 2:Oval, 3:None]

/* [Mount to wall configuration] */
Wall_mount_thickness = 3;
HSW_attach_type = 0; // [0:Insert, 1:Hexagon, 2:M3, 3:M4 ]

/* [Debug magent mode on/off] */
Debug_magnet_mode = false;

module __Customizer_Limit__ () {}  // end of parameters section
$fn = 256; // render quality

PLATE_SHAPE_OVAL = 0;
PLATE_SHAPE_RECTANGLE = 1;
PLATE_SHAPE_ROUNDED_RECTANGLE = 2;

plateLength = Plate_length;
plateWidth = Plate_width;
plateThickness = Plate_thickness;

RECTANGLE_MAGNET = 0;
CIRCLE_MAGNET = 1;
OVAL_MAGNET = 2;

magnetWidth = Magnet_width;
magnetThickness = Magnet_thickness;
magnetLength = Magnet_Length;
magnetUnderPlateSurface = Distance_magnet_under_plate_surface;

HSW_INSERT = 0;
HSW_HEXAGON = 1;
HSW_M3 = 2;
HSW_M4 = 3;

wallMountThickness = Wall_mount_thickness;
wallMountAttachType = HSW_attach_type;

// Render starts here
if ( !Debug_magnet_mode ) {
    difference() {
        plateWithMount();
        magnet();
    }    
}else{
    // debug mode here
    difference() {
        plate();
        scale([0.95, 0.95, 1.1]) plate();
    }    
    magnet();
}

module plate() {
    if (Plate_shape == PLATE_SHAPE_OVAL) {
        resize([plateLength, plateWidth]) 
            cylinder(plateThickness, plateWidth, plateWidth, true);
    } 
    if (Plate_shape == PLATE_SHAPE_RECTANGLE) {
        cube([plateLength, plateWidth, plateThickness], true);
    } 
    if (Plate_shape == PLATE_SHAPE_ROUNDED_RECTANGLE) {
        roundedRadius = min(plateLength / 4, plateWidth / 4);
        union() {
            cube([plateLength, plateWidth - roundedRadius * 2, plateThickness], true);
            cube([plateLength - roundedRadius * 2, plateWidth, plateThickness], true);
            moveX = plateLength / 2 - roundedRadius;
            moveY = plateWidth / 2 - roundedRadius;
            moveZ = -plateThickness / 2;
            translate([moveX, moveY, moveZ])
                cylinder(plateThickness, r = roundedRadius, true);
            translate([-moveX, moveY, moveZ])
                cylinder(plateThickness, r = roundedRadius, true);
            translate([moveX, -moveY, moveZ])
                cylinder(plateThickness, r = roundedRadius, true);
            translate([-moveX, -moveY, moveZ])
                cylinder(plateThickness, r = roundedRadius, true);
        }
    }
}

module wallMount() {
    insertMaxWidth = 25.98;
    spacer = 0.5;
    wallMountWidth = max( plateWidth / 2, insertMaxWidth + spacer * 2);
    wallMountHeight = wallMountWidth;
    
    translate([wallMountThickness / 2, 0, wallMountHeight / 2 - plateThickness / 2]) {
        difference() {
            verticalWallMount(wallMountWidth, wallMountHeight);
            if ( wallMountAttachType == HSW_M3 ) {
                rotate([0, 0, 90])
                    rotate([90, 0, 0])
                        cylinder(h = wallMountThickness * 2, d = 3.1, center = true);
            }
            if ( wallMountAttachType == HSW_M4 ) {
                rotate([0, 0, 90])
                    rotate([90, 0, 0])
                        cylinder( h = wallMountThickness * 2, d = 4.1, center = true);
            }
        }
        plateToWallMountConnector(wallMountWidth, wallMountHeight);
        hswAttach();        
    }
}

module verticalWallMount(wallMountWidth, wallMountHeight) {
    union() {
        translate([-wallMountThickness / 2, 0, 0]) {
            translate([0, -wallMountWidth / 2, -wallMountHeight / 2]) 
                cube([wallMountThickness, wallMountWidth, wallMountHeight * 3 / 4], false);
            translate([0, -wallMountWidth / 4, wallMountHeight / 4]) 
                cube([wallMountThickness, wallMountWidth / 2, wallMountHeight * 1 / 4], false);
            translate([0, -wallMountWidth / 4, wallMountHeight / 4]) 
                rotate([0, 90, 0])
                    cylinder(wallMountThickness, wallMountWidth / 4, wallMountWidth / 4);
            translate([0, wallMountWidth / 4, wallMountHeight / 4]) 
                rotate([0, 90, 0])
                    cylinder(wallMountThickness, wallMountWidth / 4, wallMountWidth / 4);
        }
    }    
}

module plateToWallMountConnector(wallMountWidth, wallMountHeight) {
    wallMountToPlateLength = plateLength / 2;
    translate([
        -wallMountToPlateLength / 2, 
        0, 
        -wallMountHeight / 2 + plateThickness / 2
    ]) 
        cube([wallMountToPlateLength, wallMountWidth, plateThickness], true);
}

module hswAttach() {
    translate([wallMountThickness / 2 - 2.5, 0, 0]) {
        if ( wallMountAttachType == HSW_HEXAGON ) {
            rotate([0, 0, 90])
                rotate([90, 0, 0])
                    hexagon_plug();            
        }
        if ( wallMountAttachType == HSW_INSERT ) {
            rotate([0, 0, 90])
                rotate([90, 0, 0])
                    insert_with_plate();            
        }
    }
}

module plateWithMount(){
    plate();
    translate([plateLength / 2, 0, 0]) wallMount();
}

module magnet() {
    magnetMoveZ = (plateThickness - magnetThickness) / 2 - magnetUnderPlateSurface;
    
    if (Magnet_shape == RECTANGLE_MAGNET) {
        translate([0, 0, magnetMoveZ])
            cube([magnetWidth,magnetLength,magnetThickness], true);
    }
    if (Magnet_shape == CIRCLE_MAGNET) {
        translate([0, 0, magnetMoveZ])
            cylinder(h = magnetThickness, d = magnetWidth, center = true);
    }
    if (Magnet_shape == OVAL_MAGNET) {
        translate([0, 0, magnetMoveZ])
            resize([magnetWidth, magnetLength])
                cylinder(h = magnetThickness, d = magnetWidth, center = true);
    }
}

