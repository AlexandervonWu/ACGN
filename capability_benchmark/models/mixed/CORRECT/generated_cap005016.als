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

pred cap005016 { not ((some x, y: CapBenchA | x->y in capBenchR) and ((inv1 and ((some CapBenchA and no CapBenchA) or some CapBenchA)) and ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA))) }
pred cap005016c { all a, b: CapBenchA | (not (b->a in capBenchR) or (not ((some capBenchS or CapBenchA in CapBenchA + CapBenchB) or no CapBenchA)) or (not (inv1 and ((some CapBenchA and no CapBenchA) or some CapBenchA)))) }
assert CapBenchEquivalent_cap005016 { cap005016 iff cap005016c }
check CapBenchEquivalent_cap005016 for 4
