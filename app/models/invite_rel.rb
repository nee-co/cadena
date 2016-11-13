class InviteRel
  include Neo4j::ActiveRel

  from_class :Group
  to_class :User
  type 'invite'
end
