class InviteRel
  include Neo4j::ActiveRel

  from_class :Group
  to_class :User
  type 'invite'
  creates_unique :none

  validate :no_member
  validate :no_invited

  private

  def no_member
    errors.add(:to_node) if to_node.in?(from_node.users)
  end

  def no_invited
    errors.add(:to_node) if to_node.in?(from_node.invitations)
  end
end
