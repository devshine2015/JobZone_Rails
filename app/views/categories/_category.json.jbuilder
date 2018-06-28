json.extract! category, :id, :title, :industry_id
json.picture_url category.picture_url
if category.industry
  json.industry category.industry, :id, :title, :picture_url
end
