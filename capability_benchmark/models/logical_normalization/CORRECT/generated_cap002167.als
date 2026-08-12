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

pred cap002167 { no x: CapBenchA | (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
pred cap002167c { all x: CapBenchA | not (x->x in capBenchR and (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and no CapBenchA))) }
assert CapBenchEquivalent_cap002167 { cap002167 iff cap002167c }
check CapBenchEquivalent_cap002167 for 4
