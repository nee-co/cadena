class InitializeConstraint < Neo4j::Migrations::Base
  def up
    add_constraint :User, :uuid, force: true
    add_index :User, :user_id, force: true
    add_constraint :Group, :uuid, force: true
  end

  def down
    drop_constraint :User, :uuid
    drop_index :User, :user_id
    drop_constraint :Group, :uuid
  end
end
