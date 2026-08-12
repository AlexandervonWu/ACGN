sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s : State | some s.trans
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

pred cap003695 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchB))) }
pred cap003695c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((no CapBenchB or some CapBenchA) and no CapBenchB))) }
assert CapBenchEquivalent_cap003695 { cap003695 iff cap003695c }
check CapBenchEquivalent_cap003695 for 4
