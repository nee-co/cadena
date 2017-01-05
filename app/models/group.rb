# frozen_string_literal: true
class Group
  include Neo4j::ActiveNode
  include Neo4j::Timestamps

  PERMITTED_ATTRIBUTES = %i(name is_private note).freeze

  attr_accessor :upload_image

  property :name
  property :note
  property :is_private, type: Boolean
  property :image

  validates :name, presence: true

  validate :validate_upload_image, if: -> { errors.empty? && upload_image.present? }

  before_save :set_default_image, if: -> { image.nil? }
  after_destroy :cleanup

  has_many :in, :members, model_class: :User, rel_class: :JoinRel
  has_many :out, :invitees, model_class: :User, rel_class: :InviteRel

  scope :public, -> {
    where(is_private: false)
  }

  def public?
    !is_private
  end

  def folder_id
    Caja::Folder.top_id(group_id: id).id
  end

  def self.default_image
    File.open(Rails.root.join('files/default.png'))
  end

  private

  def validate_upload_image
    errors.add(:image) unless self.image = Imagen::Image.upload(upload_image, image_was).presence
  end

  def set_default_image
    self.image = Imagen::Image.upload(self.class.default_image)
  end

  def cleanup
    invitees.each_rel(&:destroy)
    Caja::Folder.cleanup(group_id: id)
    Imagen::Image.delete(image_name: image)
  end
end
