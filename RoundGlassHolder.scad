//  TriDPrinting.com Flying SkyDelta 3d Printer

tabWidth=40;
tabDepth=22;
tabRadius=10;
mountRadius=5;  // Software adjusts if larger that 1/2 tabWidth


glassDepth=7.7;
glassDiameter=300;

glassCatchHeight = 3;  // Don't make the height much less than the Lip
glassCatchLip = 4;


boltWasher=7;
boltSize=3.3;  // Note, must add actual size. A clearance size is not automatically added.
boltCountersink=5;

slotLength=4;
slotClearance=3;


tabHeight=4;
eps=0.01;
$fn=72;


height=tabHeight+glassDepth+glassCatchHeight;


module body() {
	mr = (mountRadius > tabWidth/2) ? tabWidth/2 : mountRadius;
	linear_extrude(height=height) hull() {
		// place 4 circles in the corners, with the given radius
		translate([-boltWasher-slotLength-2*slotClearance+mr, mr, 0])
circle(r=mr);
		translate([-boltWasher-slotLength-2*slotClearance+mr, tabWidth-mr, 0])
circle(r=mr);
		translate([tabDepth-tabRadius, tabRadius, 0]) circle(r=tabRadius);
		translate([tabDepth-tabRadius, tabWidth-tabRadius, 0])
circle(r=tabRadius);
	}
}


module slot() {
	union() {
		hull() {
			translate([-boltWasher/2-slotClearance, tabWidth/2,
height-boltCountersink])
cylinder(r=boltWasher/2,h=height-boltCountersink+eps);
			translate([-boltWasher/2-slotClearance-slotLength, tabWidth/2,
height-boltCountersink])
cylinder(r=boltWasher/2,h=height-boltCountersink+eps);
	}
		hull() {
			translate([-boltWasher/2-slotClearance, tabWidth/2, -eps])
cylinder(r=boltSize/2,h=height);
			translate([-boltWasher/2-slotClearance-slotLength, tabWidth/2, -eps])
cylinder(r=boltSize/2,h=height);
		}
	}
}


module glass() {
	translate([glassDiameter/2, tabWidth/2, height-glassDepth-glassCatchHeight])
cylinder(r=glassDiameter/2,h=glassDepth, $fn=300);
}


module glassCatch() {
	translate([glassDiameter/2, tabWidth/2, height-glassCatchHeight-eps])
// For Flat Printing cylinder(r1=glassDiameter/2, r2=glassDiameter/2-glassCatchLip,h=glassCatchHeight+eps+eps, $fn=300);
cylinder(r=glassDiameter/2-glassCatchLip,h=glassCatchHeight+eps+eps, $fn=300);
}


//roundedRect(tabWidth,tabDepth,height,10);
module glassholder() {
  difference () { 
    body();
    slot();
    glass();
    glassCatch();
  }
}

translate([0,0,tabDepth-5]) rotate([0,-90,0]) glassholder();

//translate([0,-tabWidth-5,0]) glassholder();
//translate([0,tabWidth+5,0]) glassholder();
//translate([tabDepth*2+5,0,0]) glassholder();
//translate([tabDepth*2+5,-tabWidth-5,0]) glassholder();
//translate([tabDepth*2+5,tabWidth+5,0]) glassholder();

