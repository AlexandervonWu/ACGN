module alloy4fun_augmented_productionLine_v1_inv4
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

pred inv4_oracle[] {
all c : Component, p : c.parts & Component | lte[p.position,c.position]
}

pred inv4_correct_0[] {
all c: Component| always c.parts.position in prevs[c.position] + c.position
}

pred inv4_correct_1[] {
all c: Component, p: c.parts & Component | gte[c.position, p.position]
}

pred inv4_correct_2[] {
all c: Component | c.^parts.position in c.position.prevs + c.position
}

pred inv4_correct_3[] {
all c : Component | no(nexts[c.position] & c.parts.position)
}

pred inv4_correct_4[] {
all c : Component | no c.^parts.position & c.position.^next
}

pred inv4_correct_5[] {
all c: Component, p: c.^parts | p.position in c.position.prevs + c.position
}

pred inv4_correct_6[] {
all c : Component, pos : c.position, p : c.parts | p.position.lte[pos]
}

pred inv4_correct_7[] {
all c : Component, pos : c.position | all p : c.parts | p.position.lte[pos]
}

pred inv4_correct_8[] {
all c:Component | c.parts.position in c.position.*prev
}

pred inv4_correct_9[] {
all c: Component | all p: c.^parts | (p.position).lte[c.position]
}

pred inv4_correct_10[] {
all c : Component, p : (c.parts & Component) | p.position not in nexts[c.position]
}

pred inv4_correct_11[] {
all c : Component | all p : c.parts | p in Component implies p.position not in nexts[c.position]
}

pred inv4_correct_12[] {
all c:Component, p:c.parts & Component | c.position in p.position.*next
}

pred inv4_correct_13[] {
all c: Component | no ({p: Product | some p.position && p.position in ^next[c.position]} & c.parts)
}

pred inv4_correct_14[] {
all c:Component, p:c.parts | p in Component implies c.position in p.position.*next
}

pred inv4_correct_15[] {
all c: Component, p: c.^parts | (p.position).lte[c.position]
}

pred inv4_correct_16[] {
all c : Component | all p : (c.parts & Component) | p.position not in nexts[c.position]
}

pred inv4_correct_17[] {
all c: Component | c.^parts.position in c.position + c.position.prevs
}

pred inv4_correct_18[] {
all c:Component | (c.parts.position) in  (prevs[c.position]+c.position)
}

pred inv4_correct_19[] {
all c : Component | all x: c.parts & Component | x.position not in c.position.nexts
}

pred inv4_correct_20[] {
all c : Component | all p : c.parts | not (some pos: c.position.^next | p.position = pos)
}

pred inv4_correct_21[] {
all c : Component, p : c.parts.position | p not in c.position.^next
}

