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

pred cap004673 { not ((inv1 and ((some capBenchS or some capBenchS) or no CapBenchA)) and ((no CapBenchA and no CapBenchB) and some capBenchS)) }
pred cap004673c { ((not ((no CapBenchA and no CapBenchB) and some capBenchS)) or (not (inv1 and ((some capBenchS or some capBenchS) or no CapBenchA)))) }
assert CapBenchEquivalent_cap004673 { cap004673 iff cap004673c }
check CapBenchEquivalent_cap004673 for 4
