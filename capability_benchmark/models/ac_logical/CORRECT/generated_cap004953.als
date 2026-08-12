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

pred cap004953 { not ((inv1 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) }
pred cap004953c { ((not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchB)) or (not (inv1 and ((some capBenchS or some CapBenchA) or CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004953 { cap004953 iff cap004953c }
check CapBenchEquivalent_cap004953 for 4
