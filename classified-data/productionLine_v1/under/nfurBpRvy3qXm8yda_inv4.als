open util/ordering[Position]

sig Position {}

sig Product {}

sig Component extends Product {
    parts : set Product,
    position : one Position
}
sig Resource extends Product {}

sig Robot {
        position : one Position
}
pred inv4 {
    
    all c:Component | c.position not in c.position.^next
}

pred inv4c { 
  all c : Component, p : c.parts & Component | lte[p.position,c.position]
}

check correct { inv4 <=> inv4c}
pred under { inv4 and !inv4c}
pred over { !inv4 and inv4c}
run over 
run under 


