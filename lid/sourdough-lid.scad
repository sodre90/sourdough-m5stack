// Smart Sourdough Lid for Weck 580ml (742) Jar
// Single monolithic piece — no screws, no protruding parts
// Sensors recessed flush into the flat bottom surface
//
// Print: PETG, 0.2mm layers, 20% infill
// Orient: print UPSIDE DOWN (flat bottom = print bed)

// ─── JAR PARAMETERS ────────────────────────────────────────
lid_od        = 100;   // Weck glass lid outer diameter
jar_id        = 90;    // jar mouth inner diameter
clip_ledge    = 3;     // radial width the metal clips grip
lid_rim_h     = 4;     // rim height for Weck clips
centering_h   = 3;     // skirt depth below base (fits inside jar, seats on gasket)

// ─── M5STACK CORE INK ──────────────────────────────────────
core_l  = 56;          // X
core_w  = 40;          // Y
core_h  = 16;          // Z (display up)

// ─── M5STACK UNITS ─────────────────────────────────────────
unit_l  = 32;
unit_w  = 24;
tof_h   = 8;
env_h   = 8;
hub_h   = 11;

// ─── DESIGN PARAMETERS ────────────────────────────────────
wall_t      = 2;       // wall thickness
cl          = 0.4;     // clearance per side
tof_bore    = 10;      // ToF beam window diameter
cable_ch_w  = 8;       // cable channel width
cable_ch_d  = 5;       // cable channel depth
lip         = 1.2;     // retaining lip inset
lip_h       = 1.5;     // retaining lip height
snap_t      = 0.8;     // snap tab thickness
$fn         = 80;


// ─── DERIVED ───────────────────────────────────────────────
lid_r  = lid_od / 2;
jar_ir = jar_id / 2;

// Pocket dimensions (with clearance)
cpL = core_l + 2*cl;   cpW = core_w + 2*cl;
hpL = unit_l + 2*cl;   hpW = unit_w + 2*cl;
tpL = unit_l + 2*cl;   tpW = unit_w + 2*cl;
epL = unit_l + 2*cl;   epW = unit_w + 2*cl;

// Base plate thickness: enough to fully recess the sensors
sensor_depth = max(tof_h, env_h) + cl;
base_t = sensor_depth + wall_t;

// Top-side component positions
core_cy = (cpW/2 + wall_t) - (cpW + hpW + 3*wall_t)/2 + cpW/2;
hub_cy  = core_cy - cpW/2 - wall_t - hpW/2;

// Bottom-side sensor positions (flush in base plate)
tof_cx = 0;     tof_cy = 10;
env_cx = 0;     env_cy = -15;

// Top housing height above base plate
top_h = wall_t + core_h + lip_h + 0.5;

// Housing footprint
fp_top   = core_cy + cpW/2 + wall_t;
fp_bot   = hub_cy  - hpW/2 - wall_t;
fp_left  = -(cpL/2 + wall_t);
fp_right =  (cpL/2 + wall_t);

// ═══════════════════════════════════════════════════════════
//  RENDER SELECTOR
// ═══════════════════════════════════════════════════════════
//assembled();
print_orientation();

module print_orientation() {
    // Right-side up: skirt on bed, walls print upward
    // Sensor pocket roofs bridge over ~32x24mm (easy at 0.2mm layers)
    translate([0, 0, centering_h])
        sourdough_lid();
}

module assembled() {
    color("SteelBlue", 0.8) sourdough_lid();

    // Ghost components
    %translate([0, core_cy, base_t + wall_t + core_h/2])
        cube([core_l, core_w, core_h], center=true);
    %translate([0, hub_cy, base_t + wall_t + hub_h/2])
        cube([unit_l, unit_w, hub_h], center=true);
    %translate([tof_cx, tof_cy, sensor_depth/2 - cl/2])
        cube([unit_l, unit_w, tof_h], center=true);
    %translate([env_cx, env_cy, sensor_depth/2 - cl/2])
        cube([unit_l, unit_w, env_h], center=true);
}

// ═══════════════════════════════════════════════════════════
//  MAIN MODEL
// ═══════════════════════════════════════════════════════════
module sourdough_lid() {
    difference() {
        union() {
            // ── Thick base disc (sensors recess into this) ──
            cylinder(h=base_t, r=lid_r);

            // ── Rim for Weck clip grip ──
            difference() {
                cylinder(h=max(base_t, lid_rim_h), r=lid_r);
                translate([0, 0, -0.1])
                    cylinder(h=max(base_t, lid_rim_h) + 0.2,
                             r=lid_r - clip_ledge);
            }

            // ── Centering skirt (fits inside jar mouth, seats on rubber gasket) ──
            translate([0, 0, -centering_h])
                difference() {
                    cylinder(h=centering_h, r=jar_ir - 0.3);
                    translate([0, 0, -0.1])
                        cylinder(h=centering_h + 0.2, r=jar_ir - 0.3 - wall_t);
                }

            // ── Top housing walls ──
            intersection() {
                cylinder(h=base_t + top_h, r=lid_r);
                translate([0, (fp_top+fp_bot)/2, (base_t + top_h)/2])
                    cube([fp_right - fp_left,
                          fp_top - fp_bot,
                          base_t + top_h], center=true);
            }
        }

        // ══════════ TOP POCKETS (from above) ══════════

        // Core Ink pocket
        translate([-cpL/2, core_cy - cpW/2, base_t + wall_t])
            cube([cpL, cpW, top_h]);

        // HUB pocket
        translate([-hpL/2, hub_cy - hpW/2, base_t + wall_t])
            cube([hpL, hpW, top_h]);

        // Cable channel between Core Ink and HUB
        translate([-cable_ch_w/2, hub_cy + hpW/2 - 0.1, base_t + wall_t])
            cube([cable_ch_w, wall_t + 0.2, cable_ch_d + wall_t]);

        // ══════════ BOTTOM POCKETS (from below, flush) ══════════

        // ToF sensor pocket
        translate([tof_cx - tpL/2, tof_cy - tpW/2, -0.1])
            cube([tpL, tpW, sensor_depth + 0.1]);

        // ToF beam hole through remaining wall into jar
        // (not needed — sensor face is flush with bottom)
        // But we need the bore through the wall_t above the sensor
        // so it can see through to the top cable area
        // Actually: ToF looks DOWN, and it IS at the bottom. No extra hole needed.

        // ENV III sensor pocket
        translate([env_cx - epL/2, env_cy - epW/2, -0.1])
            cube([epL, epW, sensor_depth + 0.1]);

        // ══════════ CABLE ROUTING (bottom to top) ══════════

        // Vertical cable channel from ToF pocket to top surface
        translate([tof_cx + tpL/2 - cable_ch_w, tof_cy - cable_ch_w/2, -0.1])
            cube([cable_ch_w, cable_ch_w, base_t + wall_t + cable_ch_d + 0.1]);

        // Vertical cable channel from ENV III pocket to top surface
        translate([env_cx + epL/2 - cable_ch_w, env_cy - cable_ch_w/2, -0.1])
            cube([cable_ch_w, cable_ch_w, base_t + wall_t + cable_ch_d + 0.1]);
    }

    // ── Retaining lips for Core Ink ──
    for (ym = [-1, 1])
        translate([-cpL*0.15,
                   core_cy + ym*(cpW/2 - lip/2),
                   base_t + top_h - lip_h])
            cube([cpL*0.3, lip, lip_h]);

    // ── Snap tabs to hold sensors from below ──
    // ToF
    for (ym = [-1, 1])
        translate([tof_cx, tof_cy + ym*(tpW/2 - snap_t/2), snap_t/2])
            cube([tpL*0.3, snap_t, snap_t], center=true);
    // ENV III
    for (ym = [-1, 1])
        translate([env_cx, env_cy + ym*(epW/2 - snap_t/2), snap_t/2])
            cube([epL*0.3, snap_t, snap_t], center=true);
}
