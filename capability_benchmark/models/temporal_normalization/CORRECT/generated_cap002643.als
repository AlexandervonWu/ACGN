sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
trans in State -> some Event -> State
}

pred inv1c {
	all s:State | some s.trans
}

check correct { inv1 <=> inv1c}
pred under { inv1 and !inv1c}
pred over { !inv1 and inv1c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap002643 { not (((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA))) since (((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
pred cap002643c { ((not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and no CapBenchA))) triggered (not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or some capBenchR))) }
assert CapBenchEquivalent_cap002643 { cap002643 iff cap002643c }
check CapBenchEquivalent_cap002643 for 4
