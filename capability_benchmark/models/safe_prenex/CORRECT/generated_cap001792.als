sig State {
        trans : Event -> State
}
sig Init in State {}
sig Event {}

pred inv3 {
all s,s1,s2:State,e:Event | s->e->s1 in trans and s->e->s2 in trans implies s1=s2
}

pred inv3c {
	all s : State, e : Event | lone e.(s.trans)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 



sig CapBenchA { capBenchR: set CapBenchA }
sig CapBenchB { capBenchS: set CapBenchB }

pred cap001792 { ((some x: CapBenchA | x->x in capBenchR) and (inv3 and ((some capBenchR and some capBenchR) or some capBenchR))) }
pred cap001792c { (some x: CapBenchA | (x->x in capBenchR and (inv3 and ((some capBenchR and some capBenchR) or some capBenchR)))) }
assert CapBenchEquivalent_cap001792 { cap001792 iff cap001792c }
check CapBenchEquivalent_cap001792 for 4
