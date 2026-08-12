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

pred cap004975 { not ((inv1 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)) and ((some CapBenchA and some CapBenchB) or no CapBenchA)) }
pred cap004975c { ((not ((some CapBenchA and some CapBenchB) or no CapBenchA)) or (not (inv1 and ((no CapBenchB or no CapBenchB) and CapBenchA in CapBenchA + CapBenchB)))) }
assert CapBenchEquivalent_cap004975 { cap004975 iff cap004975c }
check CapBenchEquivalent_cap004975 for 4
