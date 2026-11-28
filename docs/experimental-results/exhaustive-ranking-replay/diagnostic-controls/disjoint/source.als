sig P { r:set P }
sig S, T, U in P {}
pred retained { some p:S | p in p.r implies (some t:T | p in t.r) }
pred nested { some p:S | p in p.r implies (some t:T | p in t.r implies (some u:U | u in t.r and t in u.r)) }
pred disjoint { some p:P | p in p.r implies (some disj t,u:T | p in t.r and u in t.r) }
pred ordinary { some p:P | p in p.r implies (some t,u:T | p in t.r and u in t.r) }
pred setLocal { some p:P | p in p.r implies (some t:set T | p in t.r) }
pred parameter[p:P] { some q:P | q in p.r implies (some t:T | q in t.r) }
pred temporal { some p:P | always (p in p.r implies (some t:T | p in t.r)) }
run { one T and ordinary and not disjoint } for 3 but exactly 1 P
