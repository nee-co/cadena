# frozen_string_literal: true
class Group
  include Neo4j::ActiveNode
  include Neo4j::Timestamps

  PERMITTED_ATTRIBUTES = %i(name is_private note image).freeze

  property :name
  property :note
  property :is_private, type: Boolean
  property :image

  validates :name, presence: true
  validates :image, presence: true

  before_validation :upload_image, if: -> { new_record? || image_changed? }

  has_many :in, :members, model_class: :User, rel_class: :JoinRel
  has_many :out, :invitations, model_class: :User, rel_class: :InviteRel

  scope :public, -> {
    where(is_private: false)
  }

  def public?
    !is_private
  end

  def upload_image
    upload_image = image || self.class.default_image
    self.image = Imagen::Image.upload(upload_image, image_was)
  end

  def self.default_image
    File.open("#{Rails.root}/app/assets/images/default.png")
  end
end
