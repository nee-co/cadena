class Group
  include Neo4j::ActiveNode
  include Neo4j::Timestamps

  property :name
  property :note
  property :is_private, type: Boolean
  property :group_image

  validates :name, presence: true

  has_many :in, :users, model_class: :User, rel_class: :JoinRel
  has_many :out, :invitations, model_class: :User, rel_class: :InviteRel
end
