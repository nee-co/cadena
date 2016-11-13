class User
  include Neo4j::ActiveNode
  include Neo4j::Timestamps

  property :user_id, type: Integer, index: :exact

  has_many :out, :groups, model_class: :Group, rel_class: :JoinRel
  has_many :in, :invitations, model_class: :Group, rel_class: :InviteRel
end
