class Agent < ApplicationRecord
  has_many :sessions
  has_many :memories

  validates :name, presence: true

  def default_config
    {
      temperature: 0.7,
      max_tokens: 4096,
      system_prompt: "You are Spot, a helpful AI assistant."
    }
  end
end
