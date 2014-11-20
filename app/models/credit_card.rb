class CreditCard < PayPal::SDK::REST::CreditCard
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  validates_presence_of :type, :number, :expire_month, :expire_year

  def create
    return true  if created?
    return false if invalid?
    unless super
      if error and error["details"]
        error["details"].each do |detail|
          errors.add detail["field"], detail["issue"]
        end
      else
        errors.add :type, error.inspect
      end
    end
    success?
  end

  def present?
    to_hash.present?
  end

  def created?
    self.id.present?
  end

  def description
    "xxxxxxxxxxxx#{number[-4..-1]} Expire on #{expire_month}/#{expire_year}"
  end

end
