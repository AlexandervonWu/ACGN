sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv6 {
all e:Event | some s1,s2:State | s1->e->s2 in trans
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

pred cap002986 { not always ((inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
pred cap002986c { eventually (not (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some capBenchR) and CapBenchA in CapBenchA + CapBenchB))) }
assert CapBenchEquivalent_cap002986 { cap002986 iff cap002986c }
check CapBenchEquivalent_cap002986 for 4
