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

pred cap004683 { not ((inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)) and ((some capBenchR and some capBenchR) or some capBenchS)) }
pred cap004683c { ((not ((some capBenchR and some capBenchR) or some capBenchS)) or (not (inv1 and ((CapBenchA in CapBenchA + CapBenchB or capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004683 { cap004683 iff cap004683c }
check CapBenchEquivalent_cap004683 for 4
