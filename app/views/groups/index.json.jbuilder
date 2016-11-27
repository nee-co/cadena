# frozen_string_literal: true
json.groups @groups, partial: 'group', as: :group
json.invitations @invitations, partial: 'group', as: :group
