//  TriDPrinting.com Flying SkyDelta 3d Printer

tabWidth=30;
tabDepth=22;
tabRadius=10;
mountRadius=15;  // Software adjusts if larger that 1/2 tabWidth


glassDepth=5;
glassDiameter=300;


boltWasher=6;
boltSize=3.2;  // Note, must add actual size. A clearance size is not automatically added.
boltCountersink=4;

slotLength=10;
slotClearance=2;


height=9;
eps=0.01;
$fn=72;

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
	translate([glassDiameter/2, tabWidth/2, height-glassDepth])
cylinder(r=glassDiameter/2,h=height, $fn=300);
}


//roundedRect(tabWidth,tabDepth,height,10);
module glassholder() {
  difference () { 
    body();
    slot();
    glass();
  }
}

translate([0,0,0]) glassholder();
translate([0,-tabWidth-5,0]) glassholder();
translate([0,tabWidth+5,0]) glassholder();
translate([tabDepth*2+5,0,0]) glassholder();
translate([tabDepth*2+5,-tabWidth-5,0]) glassholder();
translate([tabDepth*2+5,tabWidth+5,0]) glassholder();

