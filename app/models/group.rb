class Group
  include Neo4j::ActiveNode
  include Neo4j::Timestamps

  PERMITTED_ATTRIBUTES = %i(name is_private note group_image).freeze

  property :name
  property :note
  property :is_private, type: Boolean
  property :group_image

  validates :name, presence: true

  has_many :in, :users, model_class: :User, rel_class: :JoinRel
  has_many :out, :invitations, model_class: :User, rel_class: :InviteRel

  scope :public, -> {
    where(is_private: false)
  }
end
