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

pred cap000171 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchB or some capBenchS) and no CapBenchA))) }
pred cap000171c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((no CapBenchB or some capBenchS) and no CapBenchA))) }
assert CapBenchEquivalent_cap000171 { cap000171 iff cap000171c }
check CapBenchEquivalent_cap000171 for 4
