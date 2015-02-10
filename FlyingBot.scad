//  TriDPrinting.com Flying SkyDelta 3d Printer


// Vertex Parameters:
// Important Note:  The shape and angles in the vertex depends
// on the length of the pieces.
// Here are the parameters that need to be adjusted:
sidelength=600;
vertlength=1000;
separation = 5; // May need to edit when adjusting above values
// look at the tips of the Misumi Bars
lift = 4; // Adjust to make the part lay flat on the origin.


eps = 0.01;
extrusionsize=15;
roundedradius=3;

baseradius=sidelength/2/cos(30);
zheight=sqrt(vertlength*vertlength - baseradius*baseradius);
sideangle=atan(zheight/baseradius);

echo("br=",baseradius," zheight=",zheight, " sideangle=",sideangle);


////   LIBRARY FUNCTIONS

module Ring(od,id,w,ofs=0) {
  translate([0,0,ofs])
  difference() {
    cylinder(r=od/2,h=w,$fs=0.1);
    translate([0,0,-eps]) cylinder(r=id/2,h=w+eps+eps,$fs=0.1);
  }
}

module Bearing(od=22, id=8, w=7) {
  difference() {
    Ring(od, id, w, 0);
    //Ring(od-2,id+2,1,-eps);
    //Ring(od-2,id+2,1,w-1+eps);
  }
}

module WhiteBearing() {
  od=33.4; id=7.9; w=12.64; 
  WhiteSides=6; InnerRingDepth=2.8;

  translate([0,0,-InnerRingDepth]) difference() {
    Ring(od, id, w, 0);
    Ring(od-2*WhiteSides,0.2,InnerRingDepth,-eps);
    Ring(od-2*WhiteSides,0.2,InnerRingDepth,w-InnerRingDepth+eps);
    Ring(od-2*WhiteSides-2,id+4,1,InnerRingDepth-eps-eps);
    Ring(od-2*WhiteSides-2,id+4,1,w-InnerRingDepth-1+eps+eps);
  }
}

module WhiteBearingMold() {
  extrawidth=2;
  od=34; id=7.8; w=12.64;
  InnerRingDepth=2.8;
  translate([0,0,-InnerRingDepth]) difference() {
    Ring(od, id, w+extrawidth, -extrawidth/2);
    Ring(id+8,0.2,InnerRingDepth+extrawidth/2,-extrawidth/2-eps);
    Ring(id+8,0.2,InnerRingDepth+extrawidth/2,w-InnerRingDepth+eps);
  }
}


module vBearing() {
  od=12.0; id=3.0; w=4.0; 

//  translate([0,0,ofs])
  difference() {
    union() {
      cylinder(r1=od/2, r2=od/2-w, h=w, $fs=0.1);
      cylinder(r2=od/2, r1=od/2-w, h=w, $fs=0.1);
    }
    translate([0,0,-eps]) cylinder(r=id/2,h=w+eps+eps,$fs=0.1);
  }
}

module vBearingMold(od=12) {
  id=3.0; w=4.0; 
  extradiameter = 4.0;
  extrawidth = 1.0;
  Ring(od+extradiameter, id, w+extrawidth, -extrawidth/2);
  translate([0,0,-13]) cylinder(r=id/2+0.3,h=30,$fn=36);
}


module BoltMold(d=3, h=10, faces=32) {
  cylinder(r=d/2,h=h,$fs=0.1);
  largeRadius = (faces == 6) ? 1.16*d : d;
  translate([0,0,-30+eps]) cylinder(r=largeRadius,h=30,$fn=faces);
}

// Make an Object Flat Bottomed so it can be more easily printed without support material.
module FlatBottomed() {
   hull()  {
    linear_extrude(height=0.1) projection(cut=false) child(0);
    child(0);
//  Newer versions suggest using children(0), but child(0) still works
  }
}


module MisumiMold(h, ex=0, endboltlength=0, grooves=true) {

  translate([0,0,h/2]) {
    difference() {
      cube([extrusionsize+ex, extrusionsize+ex, h], center=true);
      if (grooves) {
        for (a = [0:90:359]) rotate([0, 0, a]) translate([(extrusionsize+ex)/2.1, 0, 0]) cylinder(r=1.3, h=h+eps, center=true, $fn=10);
      }
    }
  }
  if (endboltlength > 0) {
	translate([0, 0, -endboltlength-eps]) {
     cylinder(r=1.7, h=endboltlength+eps+eps, center=false, $fn=16);
    }
	translate([0, 0, -20-endboltlength]) {
     cylinder(r=4.5, h=20+eps+eps, center=false, $fn=16);
    }
  }
}

//////  Main Part


module apVertex(length, endboltlength, grooves=true) {
  translate([15,0,0]) rotate([0,90,0]) MisumiMold(length,0.4,endboltlength,grooves);
  rotate([0,0,60]) translate([15,0,0]) rotate([0,90,0]) MisumiMold(length,0.4,endboltlength,grooves);
  rotate([0,-sideangle,-30]) translate([20,0,-separation]) rotate([0,90,0]) MisumiMold(length,0.4,endboltlength,grooves);
  rotate([0,-sideangle,90]) translate([20,0,-separation]) rotate([0,90,0]) MisumiMold(length,0.4,endboltlength,grooves);
}


module AntiPrismVertex(PrintOnBack=true) {
  if (PrintOnBack) {  // Print Flat on Back
    translate([0,0,roundedradius]) difference() {

      minkowski() {
          difference() { //Make a flat bottomed "foot"
          FlatBottomed() translate([0,0,-lift]) rotate([46.328,-51.403,0]) apVertex(1,0,false);
            translate([0,0,-lift]) rotate([46.328,-51.403,0]) translate([-10,-15,-67.5]) cube(60);
          }
        sphere(r=roundedradius);
        }
      translate([0,0,-5.064]) rotate([46.328,-51.403,0]) apVertex(30,3.5);
    }
  } else { // Normal Orientation
    translate([-9,-6,extrusionsize/2+roundedradius]) difference() {
      minkowski() {
        hull() apVertex(1,0,false);
        sphere(r=roundedradius);
        }
      apVertex(30,3.5);
    }
  }
}


module BigBearing30(IncludeGrooves=false) {
  rotate([-120,0,0]) translate([0,-13.85,0]) {
    difference() { 
      union() {
		  if (IncludeGrooves) {
          translate([0,8,-1]) rotate([30,0,0]) cube([15-eps,16,22],center=true);
          } else {
          translate([0,8,-1]) rotate([30,0,0]) translate([0,0,-5])  cube([15-eps,13.4,32],center=true);
        }

        translate([0,18-7,0]) rotate([90,0,0]) cylinder(r=4,h=17.5,$fs=0.1);
        translate([0,8,0]) rotate([90,0,0]) cylinder(r=6,h=10,$fs=0.1);

        // See
        //%translate([0,0,0]) rotate([90,0,0]) WhiteBearing();
        %translate([0,34,-20]) rotate([30,0,0]) MisumiMold(50);
      } // end union

      // Reversed Bearing Nut Mount Hole  (Using Screw)
      translate([0,4,0]) rotate([90,0,0]) BoltMold(d=4.2, h=20, faces=6); 

      if (!IncludeGrooves) {
        //  Bottom Bolt
        translate([0,10,3]) rotate([30,0,0]) translate([0,-5,-18]) rotate([-90,0,0]) BoltMold(h=15);
      }

      // Top Bolt
      translate([0,10,1]) rotate([30,0,0]) translate([0,-5,-6]) rotate([-90,0,0]) BoltMold(h=15); 

      //  Big Topped White Bearing
      translate([0,0,0]) rotate([90,0,0]) WhiteBearingMold();

      // Misumi Mold
      translate([0,34,-20]) rotate([30,0,0]) MisumiMold(50, 0, 0, IncludeGrooves);
    }
  }
}


module AnchorBearing(IncludeGrooves=false) {
  rotate([-120,0,0]) translate([0,-13.85,0]) {
    difference() { 
      union() {
        translate([-2,-4.5+eps,4.4]) rotate([0,60,0]) cube([10,10,6]); // String Anchor
        translate([-5,17,0]) rotate([90,0,0]) cylinder(r=6,h=17);
		  if (IncludeGrooves) {
          translate([0,8,-1]) rotate([30,0,0]) cube([15-eps,16,22],center=true);
          } else {
          translate([0,8,-1]) rotate([30,0,0]) translate([0,0,-5])  cube([15-eps,13.4,32],center=true);
        }

        // See
        %translate([-5,0,0]) rotate([90,0,0]) vBearing();
        //%translate([0,34,-20]) rotate([30,0,0]) MisumiMold(50);
      } // end union

      // Reversed Bearing Nut Mount Hole  (Using Screw)
      translate([-5,7,0]) rotate([90,0,0]) BoltMold(d=3, h=20, faces=6); 

      if (!IncludeGrooves) {
        //  Bottom Bolt
        translate([0,10,3]) rotate([30,0,0]) translate([0,-5,-18]) rotate([-90,0,0]) BoltMold(h=15);
      }

      // Top Bolt
      translate([0,10,1]) rotate([30,0,0]) translate([0,-6,-6]) rotate([-90,0,0]) BoltMold(h=15); 

      //  V Bearing
      translate([-5,0,0]) rotate([90,0,0]) vBearingMold();
      translate([1,-2,-2]) rotate([0,60,0]) cylinder(r=1,h=20, $fn=8);
      //Recessed Positioning of Washer
      //translate([1,-2,-2]) rotate([0,60,0]) translate([0,0,5.5]) cylinder(r=3.3,h=1, $fn=36);

      // Clean Sides
      translate([-2.1,-8.5,15]) rotate([0,60,0]) cube([30,30,30]); // String Anchor
      translate([-15,-15,-4]) rotate([30,0,0]) cube([30,30,30]); // End
      rotate([30,0,0]) translate([-35,12,-30]) cube([30,30,30]); // End

      // Misumi Mold
      translate([0,34,-20]) rotate([30,0,0]) MisumiMold(50, 0, 0, IncludeGrooves);
    }
  }
}


module AnchorBearingPair(ExtrusionGroove=true) {

 if (ExtrusionGroove) {
   translate([-10,-8,11]) rotate([-90,0,0]) AnchorBearing(true); // Include Extrusion Groove 
   translate([10,-8,11]) rotate([-90,0,0]) mirror() AnchorBearing(true);
  } else {
   translate([-10,0,0]) AnchorBearing(false); 
   translate([10,0,0]) mirror(x) AnchorBearing(false);
 }
}



module Bearing90() {
axleoffset = 18;

  intersection() {
    translate([0,0,25]) cube([50,50,50],center=true);
    translate([-3, 0, 18.1]) rotate([0, 49.43, 0]) difference() {
      union() {
        // Main Base
      //  translate([-2,7.5,-1]) rotate([180,0,0]) cube([8,15,16]);

        // 
        translate([axleoffset,0,1.5]) rotate([0,0,0]) cylinder(r=7.8/2,h=4,$fs=0.1);
        translate([axleoffset,0,-1]) rotate([0,0,0]) cylinder(r=6,h=4.4,$fs=0.1);


        hull() {
          translate([-2,7.5,-1]) rotate([180,0,0]) cube([8,15,20]);
          difference() {
            translate([axleoffset,0,-2]) rotate([0,0,0]) cylinder(r=6,h=1,$fs=0.1);
            translate([22,-6,-7]) rotate([0,-50,0]) cube([8,12,3]);
          }
        }



      // SEE Big Topped White Bearing
      %translate([axleoffset,0,3.5]) rotate([0,0,0]) WhiteBearing();
//      %translate([axleoffset,0,3.5]) rotate([0,0,0]) WhiteBearingMold();
      } // end union

    // Bolt
    translate([3,0,-14]) rotate([0,-90,0]) BoltMold(h=15); 

    // Bearing Bolt
    translate([axleoffset,0,-3]) rotate([0,0,0]) BoltMold(h=15, d=4.3); 

    // Misumi Mold
    translate([-7.5,0,-35]) rotate([0,0,0]) MisumiMold(50,eps);
    }
  }
}

module Effector() {
  split=100;
  thickness=8;

  difference() {
    union() {
     minkowski() {
        cylinder(r=50,h=eps,$fn=3);  // NEEDS ADJUSTING!
        cylinder(r=15,h=thickness-eps,$fn=32); //sphere(r=3);
        }
    } // End Union

    for (a=[90:120:359]) {
      rotate([0,0,a]) {
        translate([split/2,0.32*split,0]) cylinder(r=0.6,h=3*thickness,center=true, $fn=8);
        translate([-split/2,0.32*split,0]) cylinder(r=0.6,h=3*thickness,center=true, $fn=8);
      }
    }

    if (true) {
      intersection() {
        translate([0,0,-eps]) minkowski() {
          cylinder(r=48,h=eps+eps,$fn=3);  // NEEDS ADJUSTING!
          cylinder(r=10,h=thickness,$fn=32); //sphere(r=3);
        }
      }
    } // End Cutouts
  }

  difference() {
    union() {
      // Radii Vertex Corners
      for (a=[0:120:359]) {
        rotate([0,0,a]) {
          translate([53,-10,0]) cube([5,20,8]);
        }
      }

      cylinder(r=8,h=8);
      translate([-15,0,0]) cylinder(r=18,h=8);
      translate([-38,-10,0]) cube([10,20,8]);

      //translate([0,-5,0]) cube([60,10,8]);
      //translate([-10,-45,0]) cube([8,90,8]);
      // Big Support Legs
      for (a=[0:120:359]) {
        rotate([0,0,a]) {
          translate([0,-5,0]) cube([55,10,8]);
        }
      }
      // Little Support Legs
      //for (a=[45,315]) {
      for (a=[60:120:359]) {
        rotate([0,0,a]) {
          translate([0,-4,0]) cube([40,8,8]);
        }
      }
    } // End Union

    translate([-15,0,0]) {  // Jhead Offset

      translate([0,0,-eps]) cylinder(r=5, h=2*thickness,$fn=12);
      translate([0,0,thickness-4+eps]) cylinder(r=8.2, h=4, $fn=36);

#      for (a=[-30:60:239]) {
        rotate([0, 0, a]) 
          translate([0, 12.5, 0])
            cylinder(r=1.8, h=3*thickness, center=true, $fn=12);
      }
    } // Jhead Offset

    // Rotational Divit
    translate([0,0,-1.5]) sphere(r=5,$fn=36);
 
    // Cutouts
    if (false) {
      intersection() {
        translate([0,0,-eps]) minkowski() {
          cylinder(r=45,h=eps+eps,$fn=3);  // NEEDS ADJUSTING!
          cylinder(r=15,h=thickness,$fn=32); //sphere(r=3);
        }

        for (a=[90:120:359]) {
          rotate([0,0,a]) {  // NEEDS ADJUSTMENT
            translate([0,0.8*split,0]) minkowski() {
              cube(thickness,center=true);
              cylinder(r=0.6*split,h=3*thickness,center=true,$fn=72);
            }
          }
        }
      }
    } // End Cutouts
  }
}


module PoleEnds(type,innerdia) {
  difference() {
    union() {
      translate([-2,-10,0]) cube([4,20,0.3]);
      translate([-10,-2,0]) cube([20,4,0.3]);
      cylinder(r=(innerdia*0.5+2), h=12, $fn=36);

      if (type == 1) {
        translate([0,0,11]) sphere(r=4.5, $fn=36);

      } else if (type==2) {
        //  Catch

        translate([-1.5,0,18]) rotate([0,90,0]) intersection() {
           difference() {
             translate([0,0,0]) cylinder(r=9,h=3, $fn=36);
             translate([2,0,-eps]) cylinder(r=5,h=3+eps+eps, $fn=36);
           }
           translate([3,-6,0]) cube([6,12,3]);
        }
     }


    } // end Union
    translate([0,0,-eps]) cylinder(r=innerdia*0.5,h=8, $fn=36);
  }
}


module CenterBearing() {
  difference() {
    translate([-25,-7,0]) cube([28,14,8]);
    translate([0,0,4]) rotate([0, -145, 0]) translate([0,0,-5]) {
      translate([17,2,16.5]) rotate([90,0,0]) vBearingMold(od=16);
      translate([8,0,0]) cylinder(r1=7, r2=2.7,h=17);
      translate([-1,0,0]) {
        translate([1,0,7]) rotate([45,60,0]) translate([0,0,-5]) cylinder(r=1, h=20, $fn=8);
        translate([1,0,7]) rotate([-45,60,0]) translate([0,0,-5]) cylinder(r=1, h=20, $fn=8);
      }
      translate([-20,-10,-5]) cube([20,20,20]);
    }
  }
}


//WhiteBearing();
//WhiteBearingMold();
//vBearing();
//vBearingMold();
//MisumiMold(50);
AntiPrismVertex(true);

//Anchor Bearings
//AnchorBearing(false);//Single. Need mirror or AnchorBearingPair
//AnchorBearingPair(true);
//AnchorBearingPair(false);

//BigBearing30(true);  //  Uses large white Bearing
//BigBearing30(false); // Not suggested at the moment


//Bearing90();
//Effector();
//for (x=[1:2]) for (y=[0:1]) translate([x*15,y*15,0]) PoleEnds(x, 4.2);
//CenterBearing();


