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

pred cap001884 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA)))) }
pred cap001884c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap001884 { cap001884 iff cap001884c }
check CapBenchEquivalent_cap001884 for 4
