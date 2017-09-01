# TODO

## QuireLeaf

- Upon destroy, QuireLeaf instance should destroy associated leaf if that leaf
  belongs to no other QuireLeaf

## Leaf

- Add Leaf#attachment_method list or ?? QuireLeaf#attachment_method
- Add Leaf#quire_uncertain; when quire_uncertain, folio number cannot be edited

- When Leaf#quire_uncertain and ...
  - Adding following quire: add leaf to following quire, copying details from
    prior QuireLeaf
  - Removing associated QuireLeaf: set Leaf#quire_uncertain = false
  - Marking final leaves in Quire as uncertain and subsequent quire exists:
    edit following quire, inserting new leaves at beginning

## Questions for Dot

- Attachment method; belongs to `<leaf>`: Can have ZeroOrMore ocurrences? Is
  any NCName? Support this?

## Authentication and authorization

- Install devise and add admin role
- Install cancancan
