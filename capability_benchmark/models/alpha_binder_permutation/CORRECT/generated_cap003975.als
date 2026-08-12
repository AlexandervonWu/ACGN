sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv1 {
all s: State | some s.trans
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

pred cap003975 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap003975c { all freshA, freshB: CapBenchA | (freshB->freshA in capBenchR and (inv1 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap003975 { cap003975 iff cap003975c }
check CapBenchEquivalent_cap003975 for 4
