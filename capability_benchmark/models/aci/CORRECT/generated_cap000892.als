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

pred cap000892 { (inv6 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) }
pred cap000892c { ((inv6 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA))) and (inv6 and ((some CapBenchA and some CapBenchB) or capBenchR in (CapBenchA -> CapBenchA)))) }
assert CapBenchEquivalent_cap000892 { cap000892 iff cap000892c }
check CapBenchEquivalent_cap000892 for 4
