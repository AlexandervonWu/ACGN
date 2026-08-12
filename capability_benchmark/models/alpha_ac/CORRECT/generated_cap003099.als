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

pred cap003099 { all x: CapBenchA | (x->x in capBenchR and (inv3 and ((no CapBenchB or some capBenchR) and some CapBenchB)) and ((some CapBenchA and no CapBenchA) or some capBenchR)) }
pred cap003099c { all renamed: CapBenchA | (((some CapBenchA and no CapBenchA) or some capBenchR) and renamed->renamed in capBenchR and (inv3 and ((no CapBenchB or some capBenchR) and some CapBenchB))) }
assert CapBenchEquivalent_cap003099 { cap003099 iff cap003099c }
check CapBenchEquivalent_cap003099 for 4
