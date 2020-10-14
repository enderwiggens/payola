module Payola
  class InvoicePaidFix
    include Payola::InvoiceBehavior

    def self.call(event)
      sale, charge = create_sale_from_invoice(event)

      return unless sale

      sale.save!
      sale.finish!

      sale
    end
  end
end
