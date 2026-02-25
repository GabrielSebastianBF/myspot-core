class ToolExecution < ApplicationRecord
  belongs_to :session, optional: true

  enum :status, {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
    executed: 'executed',
    failed: 'failed'
  }, prefix: true

  def requires_approval?
    status == 'pending'
  end
end
