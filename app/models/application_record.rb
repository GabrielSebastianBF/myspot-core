class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  
  # Métodos útiles para todos los modelos
  def self.uuid
    SecureRandom.uuid
  end
end
