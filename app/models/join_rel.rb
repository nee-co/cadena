class JoinRel
  include Neo4j::ActiveRel

  from_class :User
  to_class :Group
  type 'join'
end
