sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e : Event | some (trans.State).e
}

pred inv6c {
	State.trans.State = Event
}

check correct { inv6 <=> inv6c}
pred under { inv6 and !inv6c}
pred over { !inv6 and inv6c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap004889 { not ((inv6 and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))) and ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) }
pred cap004889c { ((not ((no CapBenchA and capBenchR in (CapBenchA -> CapBenchA)) and some CapBenchA)) or (not (inv6 and ((some capBenchS or some CapBenchA) or capBenchR in (CapBenchA -> CapBenchA))))) }
assert CapBenchEquivalent_cap004889 { cap004889 iff cap004889c }
check CapBenchEquivalent_cap004889 for 4
