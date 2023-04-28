$fn=100;

// Fin & Body dimensions
FIN_HEIGHT = 51.4;
FIN_WIDTH = 3.35;
TUBE_DIAM = 80;

// Size for Bolts (e.g. M4 -> 4mm)
BOLT_DIAM = 4;

// Distance from base plate to upper plate
PLANE_OFFSET = 40;
// Distance from edge of pieces to holes
HOLE_OFFSET = 10;
// Material thickness (e.g. 3mm laser ply)
MATERIAL = 3;
// Width of the supporting plates
PLATE_WIDTH = 60;
// Width of the tabs for the pillars
TAB_WIDTH = 20;

// Creates a horizontal slot with semicircular ends
module Slot(diam, width){
    translate([diam/2 - width/2, 0]) union(){
        circle(d=diam);
        translate([0, -diam/2]) square([width-diam, diam]);
        translate([width-diam,0]) circle(d=diam);
    }
}

// Rectangular piece with 2 slots for sliding along bolts
// Pushes the fin into the tube
// Offset is the distance from the edge of the piece to the center of the hole
module Pusher(width = TAB_WIDTH + 10){
    difference(){
        // Main Piece
        square([width, PLANE_OFFSET]);
        // Upper Slot
        translate([width/2, HOLE_OFFSET]) Slot(BOLT_DIAM, width/2);
        // Lower Slot
        translate([width/2, PLANE_OFFSET-HOLE_OFFSET]) Slot(BOLT_DIAM, width/2);
    }
}

// Supporting piece that surrounds the pusher, holding it and the fin straight
module Pillar(width=FIN_HEIGHT, tab_width=TAB_WIDTH){
    union(){
        difference(){
            square([width, PLANE_OFFSET]);
            
            translate([5, HOLE_OFFSET]) circle(d=BOLT_DIAM);
            translate([5, PLANE_OFFSET-HOLE_OFFSET]) circle(d=BOLT_DIAM);
        }
        // Tabs
        translate([5, -MATERIAL]) square([tab_width, MATERIAL]);
        translate([5, PLANE_OFFSET]) square([tab_width, MATERIAL]);
    }
}

module Plate(){
    union(){
        // Main Piece
        square([PLATE_WIDTH, PLANE_OFFSET]);
        //  Tabs
        translate([5, -MATERIAL]) square([PLATE_WIDTH-10, MATERIAL]);
        translate([5, PLANE_OFFSET]) square([PLATE_WIDTH-10, MATERIAL]);
    }
}

// Represents the top down geometry of the fins
// For reference only
module Fins(){
    // Body Tube
    circle(d=TUBE_DIAM);
    for(i = [0:90:360])
        rotate(i) translate([TUBE_DIAM/2, -MATERIAL/2]) square([FIN_HEIGHT, FIN_WIDTH]);
}

// For the top and bottom base plates - as identical as possible with variation only for fin slots
module Base(tab_width=TAB_WIDTH, top=true){    
    difference(){
        // General shape (Rounded square, rotated 45degs)
        intersection(){
            rotate(45) square(200, center=true);
            circle(r = TUBE_DIAM/2 + FIN_HEIGHT + TAB_WIDTH + 12);
        }
        
        for(i = [0:90:360]){
            rotate(i){
                // Slot for structural Plate
                rotate(45) translate([0,80]) square([PLATE_WIDTH-10, MATERIAL], center=true);
                
                // Slot to allow fin through (Shouldn't _really_ retain fin itself)
                // Comment this line for top / bottom piece
                if(top){
                    W = FIN_WIDTH + 1;
                    translate([-W*0.5 , TUBE_DIAM/2]) square([W, FIN_HEIGHT + 4], center=false);
                }
                
                // Slots for pillars
                translate([FIN_WIDTH*0.5 , TUBE_DIAM/2 + FIN_HEIGHT + 8]) square([MATERIAL, TAB_WIDTH], center=false);
                translate([-MATERIAL - FIN_WIDTH*0.5,TUBE_DIAM/2 + FIN_HEIGHT + 8]) square([MATERIAL, TAB_WIDTH], center=false);
                
                // Margin to allow access to fins
                translate([0, TUBE_DIAM/2]) circle(20);
            }
        }
        circle(d=TUBE_DIAM);
    }
}  


// ---=== FULL BoM ===---

// Wooden parts
*Base(top=true);
*Base(top=false);
*Plate(); // x4
*Pillar(); // x8

// Acrylic parts
*Pusher(); // x4

// Other Parts:
// 8x Bolts of your choice (set size with BOLT_DIAM)