# frozen_string_literal: true
class JoinRel
  include Neo4j::ActiveRel

  after_create :remove_invite

  from_class :User
  to_class :Group
  type 'join'

  private

  def remove_invite
    to_node.invitees.where(user_id: from_node.user_id).each_rel(&:destroy)
  end
end
