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

pred cap004579 { not ((inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB)) and ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) }
pred cap004579c { ((not ((some capBenchR and CapBenchA in CapBenchA + CapBenchB) or no CapBenchB)) or (not (inv3 and ((CapBenchA in CapBenchA + CapBenchB or some CapBenchB) and some CapBenchB)))) }
assert CapBenchEquivalent_cap004579 { cap004579 iff cap004579c }
check CapBenchEquivalent_cap004579 for 4
