# frozen_string_literal: true
json.page @page
json.per @per
json.total_count @total_count
json.groups @groups, partial: 'group', as: :group
