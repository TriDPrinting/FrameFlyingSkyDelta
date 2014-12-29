//  TriDPrinting.com Flying SkyDelta 3d Printer


// Important Note:  The shape and angles in the vertex depends
// on the length of the pieces.
// Here are the parameters that need to be adjusted:
sidelength=400;
vertlength=490;


eps = 0.01;
extrusionsize=15;
roundedradius=3;

baseradius=sidelength/2/cos(30);
zheight=sqrt(vertlength*vertlength - baseradius*baseradius);
sideangle=atan(zheight/baseradius);

echo("br=",baseradius," zheight=",zheight, " sideangle=",sideangle);


////   LIBRARY FUNCTIONS

module ring(od,id,w,ofs=0) {
  translate([0,0,ofs])
  difference() {
echo (r=od/2,h=w,$fs=0.1,w);
    cylinder(r=od/2,h=w,$fs=0.1);
    translate([0,0,-eps]) cylinder(r=id/2,h=w+eps+eps,$fs=0.1);
  }
}

module bearing(od=22, id=8, w=7) {
  difference() {
    ring(od, id, w, 0);
    ring(od-2,id+2,1,-eps);
    ring(od-2,id+2,1,w-1+eps);
  }
}

module whitebearing() {
  od=33.4; id=7.9; w=12.64; 
  WhiteSides=6; InnerRingDepth=2.8;

  translate([0,0,-InnerRingDepth]) difference() {
    ring(od, id, w, 0);
    ring(od-2*WhiteSides,0.2,InnerRingDepth,-eps);
    ring(od-2*WhiteSides,0.2,InnerRingDepth,w-InnerRingDepth+eps);
    ring(od-2*WhiteSides-2,id+4,1,InnerRingDepth-eps-eps);
    ring(od-2*WhiteSides-2,id+4,1,w-InnerRingDepth-1+eps+eps);
  }
}

module whitebearingmold() {
  extrawidth=2;
  od=34; id=7.8; w=12.64;
  InnerRingDepth=2.8;
  translate([0,0,-InnerRingDepth]) difference() {
    ring(od, id, w+extrawidth, -extrawidth/2);
    ring(id+8,0.2,InnerRingDepth+extrawidth/2,-extrawidth/2-eps);
    ring(id+8,0.2,InnerRingDepth+extrawidth/2,w-InnerRingDepth+eps);
  }
}


module boltmold(d=3, h=10, faces=32) {
  cylinder(r=d/2,h=h,$fs=0.1);
  translate([0,0,-30+eps]) cylinder(r=d,h=30,$fn=faces);
}

// Make an Object Flat Bottomed so it can be more easily printed without support material.
module flatbottomed() {
   hull()  {
    linear_extrude(height=0.1) projection(cut=false) child(0);
    child(0);
//  Newer versions suggest using children(0), but child(0) still works
  }
}


module misumimold(h, ex=0, endboltlength=0, grooves=true) {

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


module apvertex(length, endboltlength, grooves=true) {
  translate([15,0,0]) rotate([0,90,0]) misumimold(length,0.4,endboltlength,grooves);
  rotate([0,0,60]) translate([15,0,0]) rotate([0,90,0]) misumimold(length,0.4,endboltlength,grooves);
  rotate([0,-sideangle,-30]) translate([20,0,-3]) rotate([0,90,0]) misumimold(length,0.4,endboltlength,grooves);
  rotate([0,-sideangle,90]) translate([20,0,-3]) rotate([0,90,0]) misumimold(length,0.4,endboltlength,grooves);
}


module antiprismvertex(PrintOnBack=true) {
  if (PrintOnBack) {  // Print Flat on Back
    translate([0,0,roundedradius]) difference() {

      minkowski() {
          difference() { //Make a flat bottomed "foot"
          flatbottomed() translate([0,0,-5.064]) rotate([46.328,-51.403,0]) apvertex(1,0,false);
            translate([0,0,-5.064]) rotate([46.328,-51.403,0]) translate([-10,-15,-67.5]) cube(60);
          }
        sphere(r=roundedradius);
        }
      translate([0,0,-5.064]) rotate([46.328,-51.403,0]) apvertex(30,3.5);
    }
  } else { // Normal Orientation
    translate([-9,-6,extrusionsize/2+roundedradius]) difference() {
      minkowski() {
        hull() apvertex(1,0,false);
        sphere(r=roundedradius);
        }
      apvertex(30,3.5);
    }
  }
}


module bearing30(IncludeGrooves=false) {
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
        //%translate([0,0,0]) rotate([90,0,0]) whitebearing();
        %translate([0,34,-20]) rotate([30,0,0]) misumimold(50);
      } // end union

      // Reversed bearing Nut Mount Hole  (Using Screw)
      translate([0,4,0]) rotate([90,0,0]) boltmold(d=4.2, h=20, faces=6); 

      if (!IncludeGrooves) {
        //  Bottom Bolt
        translate([0,10,3]) rotate([30,0,0]) translate([0,-5,-18]) rotate([-90,0,0]) boltmold(h=15);
      }

      // Top Bolt
      translate([0,10,1]) rotate([30,0,0]) translate([0,-5,-6]) rotate([-90,0,0]) boltmold(h=15); 

      //  Big Topped White bearing
      translate([0,0,0]) rotate([90,0,0]) whitebearingmold();

      // Misumi Mold
      translate([0,34,-20]) rotate([30,0,0]) misumimold(50, 0, 0, IncludeGrooves);
    }
  }
}


module bearing90() {
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
      %translate([axleoffset,0,3.5]) rotate([0,0,0]) whitebearing();
//      %translate([axleoffset,0,3.5]) rotate([0,0,0]) whitebearingmold();
      } // end union

    // Bolt
    translate([3,0,-14]) rotate([0,-90,0]) boltmold(h=15); 

    // Bearing Bolt
    translate([axleoffset,0,-3]) rotate([0,0,0]) boltmold(h=15, d=4.3); 

    // Misumi Mold
    translate([-7.5,0,-35]) rotate([0,0,0]) misumimold(50,eps);
    }
  }
}

module effector() {
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


module oldeffector() {
  split=100;
  thickness=8;

  difference() {
    union() {
      minkowski() {
        cylinder(r=50,h=eps,$fn=3);  // NEEDS ADJUSTING!
        cylinder(r=15,h=thickness-eps,$fn=32); //sphere(r=3);
        }
    } // End Union

    translate([0,0,-eps]) cylinder(r=4.8/2, h=2*thickness,$fn=12);
    translate([0,0,thickness-4+eps]) cylinder(r=8, h=4, $fn=36);

    for (a=[0:60:359]) {
      rotate([0, 0, a]) 
        translate([0, 12.5, 0])
          cylinder(r=1.8, h=3*thickness, center=true, $fn=12);
    }

    for (a=[90:120:359]) {
      rotate([0,0,a]) {
        translate([split/2,0.32*split,0]) cylinder(r=0.6,h=3*thickness,center=true, $fn=8);
        translate([-split/2,0.32*split,0]) cylinder(r=0.6,h=3*thickness,center=true, $fn=8);
      }
    }

    // Cutouts
    if (true) {
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

module oldmidloop() {
  difference() {
    union() {
      translate([0,0,2]) rotate_extrude(convexity = 10) {
        translate([6.5, 0, 0])
        scale([1,0.7,1])
        circle(r=4, $fn = 36);
      } // end rotate
    } // end union
    translate([0,0,-10]) cube([20,20,20],center=true);
    for (a=[0:60:359]) {
      rotate([0, 0, a]) 
        translate([0, 7, 0])
          cylinder(r=1, h=20, center=true, $fn=12);
    }

  } // end diff
}

module poleends(type,innerdia) {
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

module centerbearing() {
axleoffset = 19;

    difference() {
      union() {
        difference() {
          cylinder(r=23, h=4, $fn=36);
          translate([0,-2.5,-1]) cube([20,30,10]);
          translate([0,0,-eps]) cylinder(r=12,h=4+eps+eps, $fn=36);
          translate([25,0,-eps]) cylinder(r=12,h=6+eps+eps, $fn=36);
        }
        difference() {
          translate([25, 0, 0]) cylinder(r=23, h=4, $fn=36);
          translate([4,-2.5,-1]) cube([20,30,10]);
          translate([0,0,-eps]) cylinder(r=12,h=4+eps+eps, $fn=36);
          translate([25,0,-eps]) cylinder(r=12,h=6+eps+eps, $fn=36);
        }


         translate([0,17.5,-eps]) cylinder(r=5.5,h=4,$fn=36);
         translate([25,17.5,-eps]) cylinder(r=5.5,h=4,$fn=36);

        translate([ axleoffset-5, -5.5, 16]) rotate([0, 90,90]) cylinder(r=7.8/2, h=8.5, $fs=0.1);
        translate([axleoffset-5, -17, 16]) rotate([0, 90,90]) cylinder(r=6, h=14.4, $fs=0.1);
        translate([axleoffset-9, -17, 0]) cube([8, 14.4, 12]);

        } // end union

       for (a=[0:30:209]) {
         rotate([0, 0, a])
           translate([0, 18, 4])
             cylinder(r=0.8, h=10, center=true, $fn=12);
         translate([25, 0, 0]) rotate([0, 0, -a])
           translate([0, 18, 4])
             cylinder(r=0.8, h=10, center=true, $fn=12);
       }
//#       translate([19, -9, 4]) cylinder(r=0.8, h=10, center=true, $fn=12);


        // Flat Bottom
        translate([0,-30,-10]) cube([30,60,10]);
     




      // SEE Big Topped White Bearing
//      %translate([ axleoffset-5, -3.5, 16]) rotate([ 0, 90, 90]) whitebearing();
      %translate([ axleoffset-5, -3.5, 16]) rotate([ 0, 90,90]) whitebearingmold();

      // Bearing Bolt
      translate([axleoffset-5,-17, 16]) rotate([0,90,90]) boltmold(h=25, d=4.3); 
      } // end union
    }




//whitebearing();
//whitebearingmold();
//misumimold(50);
//antiprismvertex(true);
//bearing30(true);  //  Include Extrusion Groove (requires support)
//bearing30(false);
//bearing90();
//effector();
//for (x=[1:2]) for (y=[0:1]) translate([x*15,y*15,0]) poleends(x, 4.2);
centerbearing();



