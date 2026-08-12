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

pred cap001700 { ((some x: CapBenchA | x->x in capBenchR) and (inv1 and ((some CapBenchA and some CapBenchB) or no CapBenchB))) }
pred cap001700c { (some x: CapBenchA | (x->x in capBenchR and (inv1 and ((some CapBenchA and some CapBenchB) or no CapBenchB)))) }
assert CapBenchEquivalent_cap001700 { cap001700 iff cap001700c }
check CapBenchEquivalent_cap001700 for 4
