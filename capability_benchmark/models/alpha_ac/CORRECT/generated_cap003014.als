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

pred cap003014 { all x: CapBenchA | (x->x in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA)) and ((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA)) }
pred cap003014c { all renamed: CapBenchA | (((no CapBenchB or CapBenchA in CapBenchA + CapBenchB) and no CapBenchA) and renamed->renamed in capBenchR and (inv6 and ((capBenchR in (CapBenchA -> CapBenchA) and some CapBenchB) and some CapBenchA))) }
assert CapBenchEquivalent_cap003014 { cap003014 iff cap003014c }
check CapBenchEquivalent_cap003014 for 4
