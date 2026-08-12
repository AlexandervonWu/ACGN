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

pred cap004746 { not ((inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)) and ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) }
pred cap004746c { ((not ((no CapBenchB or some capBenchR) and capBenchR in (CapBenchA -> CapBenchA))) or (not (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and capBenchR in (CapBenchA -> CapBenchA)) and no CapBenchB)))) }
assert CapBenchEquivalent_cap004746 { cap004746 iff cap004746c }
check CapBenchEquivalent_cap004746 for 4
