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

pred cap000169 { all x: CapBenchA | some y: CapBenchA | (x->y in capBenchR and (inv1 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
pred cap000169c { all y: CapBenchA | some x: CapBenchA | (y->x in capBenchR and (inv1 and ((some CapBenchB or some capBenchS) or no CapBenchA))) }
assert CapBenchEquivalent_cap000169 { cap000169 iff cap000169c }
check CapBenchEquivalent_cap000169 for 4
