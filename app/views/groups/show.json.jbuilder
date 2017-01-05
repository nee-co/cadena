# frozen_string_literal: true
json.partial! partial: 'group', locals: { group: @group }
json.folder_id @group.folder_id
