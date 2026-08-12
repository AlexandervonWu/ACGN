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

pred cap004914 { not ((inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchB or some CapBenchB) and some CapBenchB)) }
pred cap004914c { ((not ((no CapBenchB or some CapBenchB) and some CapBenchB)) or (not (inv1 and ((capBenchR in (CapBenchA -> CapBenchA) and no CapBenchB) and capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004914 { cap004914 iff cap004914c }
check CapBenchEquivalent_cap004914 for 4
