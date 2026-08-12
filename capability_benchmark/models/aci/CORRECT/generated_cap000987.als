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

pred cap000987 { ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB)) or ((some capBenchR and no CapBenchA) or no CapBenchA) or ((no CapBenchA and some CapBenchA) and some capBenchS)) }
pred cap000987c { (((some capBenchR and no CapBenchA) or no CapBenchA) or ((no CapBenchA and some CapBenchA) and some capBenchS) or (inv1 and ((CapBenchA in CapBenchA + CapBenchB or some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap000987 { cap000987 iff cap000987c }
check CapBenchEquivalent_cap000987 for 4
