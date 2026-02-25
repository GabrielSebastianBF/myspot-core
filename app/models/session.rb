class Session < ApplicationRecord
  belongs_to :agent
  has_many :tool_executions

  validates :channel, presence: true

  def duration
    return nil unless started_at && ended_at
    ended_at - started_at
  end
end
