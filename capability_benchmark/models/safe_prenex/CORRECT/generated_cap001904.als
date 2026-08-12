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

pred cap001904 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001904c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some capBenchR and no CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001904 { cap001904 iff cap001904c }
check CapBenchEquivalent_cap001904 for 4
