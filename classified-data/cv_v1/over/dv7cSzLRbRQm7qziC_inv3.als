abstract sig Source {}
sig User extends Source {
    profile : set Work,
    visible : set Work
}
sig Institution extends Source {}

sig Id {}
sig Work {
    ids : some Id,
    source : one Source
}

pred inv3 {
  	all w1, w2:Work, u:User, i:Id | ((w1 in u.profile and w2 in u.profile) and (w1.source = w2.source)) implies (w1.ids != w2.ids)
}

pred inv3c {
	all u : User, disj x,y : u.profile | x.source = y.source implies no (x.ids & y.ids)
}

check correct { inv3 <=> inv3c}
pred under { inv3 and !inv3c}
pred over { !inv3 and inv3c}
run over 
run under 


