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

pred cap001410 { all x, y: CapBenchA | (x->y in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001410c { all a, b: CapBenchA | (b->a in capBenchR and (inv1 and ((no CapBenchA and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001410 { cap001410 iff cap001410c }
check CapBenchEquivalent_cap001410 for 4
