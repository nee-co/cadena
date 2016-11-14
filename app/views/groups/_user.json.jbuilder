json.extract! user, *%i(user_id name number user_image note)

json.college do
  json.name user.college.name
  json.code user.college.code
end
