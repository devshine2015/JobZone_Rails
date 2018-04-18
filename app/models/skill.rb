class Skill < ApplicationRecord
  belongs_to :skillable, polymorphic: true, optional: true
end
