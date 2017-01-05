json.elements(@elements) do |element|
  json.extract! element, *%i(id type image)
  json.title element.name
end
