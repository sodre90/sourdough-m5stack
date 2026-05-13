// Smart Sourdough Lid for Weck 580ml (742) Jar
// Separate pockets for Core Ink + HUB with Grove cable clearance
// Sensors recessed into bottom face with through-base cable channels
//
// Print: PETG, 0.2mm layers, 20% infill
// Orient: skirt on bed, housing walls print upward

// ─── JAR PARAMETERS ────────────────────────────────────────
lid_od        = 100;   // Weck glass lid outer diameter
jar_id        = 90;    // jar mouth inner diameter
clip_ledge    = 3;     // radial width the metal clips grip
lid_rim_h     = 4;     // rim height for Weck clips
centering_h   = 3;     // skirt depth below base

// ─── M5STACK CORE INK ──────────────────────────────────────
core_l  = 56;          // X
core_w  = 40;          // Y (Grove port on -Y short edge)
core_h  = 16;          // Z

// ─── M5STACK UNITS ─────────────────────────────────────────
unit_l  = 32;          // X
unit_w  = 24;          // Y (Grove ports on short/Y edges)
tof_h   = 8;
env_h   = 8;
hub_h   = 11;

// ─── DESIGN PARAMETERS ────────────────────────────────────
wall_t      = 2;       // wall thickness
cl          = 0.4;     // clearance per side
grove_cl    = 6;       // Grove connector + cable bend clearance
cable_ch_w  = 10;      // cable channel width
cable_ch_d  = 5;       // cable channel floor depth in cavty
lip         = 1.2;     // retaining lip inset
lip_h       = 1.5;     // retaining lip height
snap_t      = 0.8;     // snap tab thickness
$fn         = 80;

// ─── DERIVED ───────────────────────────────────────────────
lid_r  = lid_od / 2;
jar_ir = jar_id / 2;

cpL = core_l + 2*cl;   cpW = core_w + 2*cl;
hpL = unit_l + 2*cl;   hpW = unit_w + 2*cl;
tpL = unit_l + 2*cl;   tpW = unit_w + 2*cl;
epL = unit_l + 2*cl;   epW = unit_w + 2*cl;

sensor_depth = max(tof_h, env_h) + cl;
base_t = sensor_depth + wall_t;

// ── Top-side component positions ──
core_cy = 17;          // Core Ink center Y — Grove port faces -Y
hub_cy  = -28;         // HUB center Y — input +Y, outputs -Y

// ── Bottom-side sensor positions ──
tof_cx = 0;   tof_cy = -5;    // ToF near center, Grove port faces +Y
env_cx = 0;   env_cy = -25;   // ENV III lower, Grove port faces +Y

// ── Housing geometry ──
top_h = wall_t + core_h + lip_h + 0.5;

cav_top = core_cy + cpW/2;
cav_bot = hub_cy  - hpW/2;
cav_w   = cpL;

fp_top   = cav_top + wall_t;
fp_bot   = cav_bot - wall_t;
fp_left  = -(cav_w/2 + wall_t);
fp_right =  (cav_w/2 + wall_t);


// ═══════════════════════════════════════════════════════════
//  RENDER SELECTOR
// ═══════════════════════════════════════════════════════════
//assembled();
print_orientation();

module print_orientation() {
    translate([0, lid_r, centering_h])
        sourdough_lid();
}

module assembled() {
    translate([0, lid_r, 0]) {
        color("SteelBlue", 0.8) sourdough_lid();

        %translate([0, core_cy, base_t + wall_t + core_h/2])
            cube([core_l, core_w, core_h], center=true);
        %translate([0, hub_cy, base_t + wall_t + hub_h/2])
            cube([unit_l, unit_w, hub_h], center=true);
        %translate([tof_cx, tof_cy, sensor_depth/2 - cl/2])
            cube([unit_l, unit_w, tof_h], center=true);
        %translate([env_cx, env_cy, sensor_depth/2 - cl/2])
            cube([unit_l, unit_w, env_h], center=true);
    }
}


// ═══════════════════════════════════════════════════════════
//  MAIN MODEL
// ═══════════════════════════════════════════════════════════
module sourdough_lid() {
    difference() {
        union() {
            // ── Base disc ──
            cylinder(h=base_t, r=lid_r);

            // ── Weck clip rim ──
            difference() {
                cylinder(h=max(base_t, lid_rim_h), r=lid_r);
                translate([0, 0, -0.1])
                    cylinder(h=max(base_t, lid_rim_h) + 0.2,
                             r=lid_r - clip_ledge);
            }

            // ── Centering skirt ──
            translate([0, 0, -centering_h])
                difference() {
                    cylinder(h=centering_h, r=jar_ir - 0.3);
                    translate([0, 0, -0.1])
                        cylinder(h=centering_h + 0.2, r=jar_ir - 0.3 - wall_t);
                }

            // ── Top housing walls ──
            intersection() {
                cylinder(h=base_t + top_h, r=lid_r);
                translate([0, (fp_top + fp_bot)/2, (base_t + top_h)/2])
                    cube([fp_right - fp_left,
                          fp_top - fp_bot,
                          base_t + top_h], center=true);
            }
        }

        // ══════════ TOP: CORE INK POCKET ══════════
        translate([-cpL/2, core_cy - cpW/2, base_t + wall_t])
            cube([cpL, cpW, top_h]);

        // ══════════ TOP: HUB POCKET ══════════
        translate([-hpL/2, hub_cy - hpW/2, base_t + wall_t])
            cube([hpL, hpW, top_h]);

        // ══════════ TOP: CABLE CHANNEL BETWEEN POCKETS ══════════
        translate([-cable_ch_w/2, hub_cy + hpW/2 - 0.1, base_t + wall_t])
            cube([cable_ch_w,
                  (core_cy - cpW/2) - (hub_cy + hpW/2) + 0.2,
                  cable_ch_d + wall_t]);

        // ══════════ TOP: HUB CABLE ENTRY (through-base) ══════════
        translate([-cable_ch_w/2, hub_cy + hpW/2 - grove_cl, -0.1])
            cube([cable_ch_w, grove_cl, base_t + wall_t + 0.2]);

        // ══════════ BOTTOM: ToF POCKET ══════════
        translate([tof_cx - tpL/2, tof_cy - tpW/2, -0.1])
            cube([tpL, tpW, sensor_depth + 0.1]);

        // ToF Grove clearance (+Y) and through-base cable channel
        translate([tof_cx - cable_ch_w/2, tof_cy + tpW/2 - 1, -0.1])
            cube([cable_ch_w, grove_cl + 1,
                  base_t + wall_t + cable_ch_d + 0.2]);

        // ══════════ BOTTOM: ENV III POCKET ══════════
        translate([env_cx - epL/2, env_cy - epW/2, -0.1])
            cube([epL, epW, sensor_depth + 0.1]);

        // ENV III Grove clearance (+Y) and through-base cable channel
        translate([env_cx - cable_ch_w/2, env_cy + epW/2 - 1, -0.1])
            cube([cable_ch_w, grove_cl + 1,
                  base_t + wall_t + cable_ch_d + 0.2]);
    }

    // ── Core Ink retaining lips (±Y edges) ──
    for (ym = [-1, 1])
        translate([-cpL*0.15,
                   core_cy + ym*(cpW/2 - lip/2),
                   base_t + top_h - lip_h])
            cube([cpL*0.3, lip, lip_h]);

    // ── ToF snap tabs (-Y and ±X, +Y clear for cable) ──
    translate([tof_cx, tof_cy - (tpW/2 - snap_t/2), snap_t/2])
        cube([tpL*0.3, snap_t, snap_t], center=true);
    for (xm = [-1, 1])
        translate([tof_cx + xm*(tpL/2 - snap_t/2), tof_cy, snap_t/2])
            cube([snap_t, tpW*0.3, snap_t], center=true);

    // ── ENV III snap tabs (-Y and ±X, +Y clear for cable) ──
    translate([env_cx, env_cy - (epW/2 - snap_t/2), snap_t/2])
        cube([epL*0.3, snap_t, snap_t], center=true);
    for (xm = [-1, 1])
        translate([env_cx + xm*(epL/2 - snap_t/2), env_cy, snap_t/2])
            cube([snap_t, epW*0.3, snap_t], center=true);
}
