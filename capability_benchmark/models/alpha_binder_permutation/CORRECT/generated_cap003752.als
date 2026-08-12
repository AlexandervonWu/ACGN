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

pred cap003752 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
pred cap003752c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB))) }
assert CapBenchEquivalent_cap003752 { cap003752 iff cap003752c }
check CapBenchEquivalent_cap003752 for 4
