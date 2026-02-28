class Tool < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  def allowed_roles
    read_attribute(:allowed_roles) || []
  end
  
  def allowed_roles=(value)
    write_attribute(:allowed_roles, value.is_a?(Array) ? value : value.to_s.split(',').map(&:strip))
  end

  def can_execute?(role)
    allowed_roles.include?(role.to_s)
  end
end
