module assignment
sig A { r, s: set A }
pred left { some r and some s }
pred right { no s and some r }
pred direct { no r and some s }
