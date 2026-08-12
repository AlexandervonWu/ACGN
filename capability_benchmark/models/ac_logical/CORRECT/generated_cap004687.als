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

pred cap004687 { not ((inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) and ((some CapBenchA and some capBenchS) or some capBenchS)) }
pred cap004687c { ((not ((some CapBenchA and some capBenchS) or some capBenchS)) or (not (inv1 and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)))) }
assert CapBenchEquivalent_cap004687 { cap004687 iff cap004687c }
check CapBenchEquivalent_cap004687 for 4
