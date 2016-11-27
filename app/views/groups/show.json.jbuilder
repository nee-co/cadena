# frozen_string_literal: true
json.partial! partial: 'group', locals: { group: @group }

json.members @users.members, partial: 'user', as: :user
json.invitations @users.invitations, partial: 'user', as: :user
