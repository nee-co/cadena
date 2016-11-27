# frozen_string_literal: true
json.extract! user, :id, :name, :number, :image, :note

json.college do
  json.name user.college.name
  json.code user.college.code
end
