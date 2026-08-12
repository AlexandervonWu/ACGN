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

pred cap001542 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((no CapBenchA and some capBenchS) and some CapBenchA))) }
pred cap001542c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((no CapBenchA and some capBenchS) and some CapBenchA)))) }
assert CapBenchEquivalent_cap001542 { cap001542 iff cap001542c }
check CapBenchEquivalent_cap001542 for 4
