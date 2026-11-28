open util/ordering[Position]
sig Position {}
sig Product {}
sig Component extends Product { parts: set Product, position: one Position }
pred retained {
  all c,d: Component | all p: c.parts |
    (d.position = c.position implies
      some pos: c.position.prevs | p.position = pos)
}
pred reference {
  all c,d: Component, p: c.parts & Component |
    d.position = c.position implies lte[p.position,c.position]
}
