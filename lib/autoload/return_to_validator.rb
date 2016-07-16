module ReturnToValidator
  def self.valid?(return_to)
    if return_to.nil?
      return false
    end

    uri = Addressable::URI.parse(return_to)
    !uri.nil? && uri.host.nil? && uri.scheme.nil?
  rescue Addressable::URI::InvalidURIError
    false
  end
end
