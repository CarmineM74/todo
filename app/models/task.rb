class Task < ActiveRecord::Base
  include RocketPants::Cacheable
  validates :name, presence: true, uniqueness: true

  belongs_to :project
end
