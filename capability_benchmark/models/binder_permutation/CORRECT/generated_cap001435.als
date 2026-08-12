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

pred cap001435 { some x, y, z: CapBenchA | (x->y in capBenchR and y->z in capBenchR and (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001435c { some a, b, c: CapBenchA | (c->b in capBenchR and b->a in capBenchR and (inv1 and ((no CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap001435 { cap001435 iff cap001435c }
check CapBenchEquivalent_cap001435 for 4
