class Payment < ApplicationRecord
  belongs_to :subscription

  enum status: [:added, :ok]

  # MERCHANT_URL    = ENV['MERCHANT_URL']
  # # test interface: http://test.robokassa.ru/Index.aspx
  # SERVICES_URL    = ENV['SERVICES_URL']
  # #test interface: http://test.robokassa.ru/Webservice/Service.asmx
  # MERCHANT_LOGIN  =
  # MERCHANT_PASS_1 = 'your_pass_1'
  # MERCHANT_PASS_2 = 'your_pass_2'

  # def self.get_currencies(lang = "ru")
  #   svc_url = "#{ENV['SERVICES_URL']}/GetCurrencies?MerchantLogin=#{ENV['MERCHANT_LOGIN']}&Language=#{lang}"
  #   doc = Nokogiri::XML(open(svc_url))
  #   doc.xpath("//xmlns:Group").map {|g|{
  #     'code' => g['Code'],
  #     'desc' => g['Description'],
  #     'items' => g.xpath('.//xmlns:Currency').map {|c| {
  #       'label' => c['Label'],
  #       'name' => c['Name']
  #     }}
  #   }} if doc.xpath("//xmlns:Result/xmlns:Code").text.to_i == 0
  # end
  #
  # def self.get_payment_methods(lang = "ru")
  #   svc_url = "#{ENV['SERVICES_URL']}/GetPaymentMethods?MerchantLogin=#{ENV['MERCHANT_LOGIN']}&Language=#{lang}"
  #   doc = Nokogiri::XML(open(svc_url))
  #   doc.xpath("//xmlns:Method").map {|g| {
  #     'code' => g['Code'],
  #     'desc' => g['Description']
  #   }} if doc.xpath("//xmlns:Result/xmlns:Code").text.to_i == 0
  # end
  #
  # def self.get_rates(sum = 1, curr = '', lang="ru")
  #   svc_url = "#{ENV['SERVICES_URL']}/GetRates?MerchantLogin=#{ENV['MERCHANT_LOGIN']}&IncCurrLabel=#{curr}&OutSum=#{sum}&Language=#{lang}"
  #   doc = Nokogiri::XML(open(svc_url))
  #   doc.xpath("//xmlns:Group").map {|g| {
  #     'code' => g['Code'],
  #     'desc' => g['Description'],
  #     'items' => g.xpath('.//xmlns:Currency').map {|c| {
  #       'label' => c['Label'],
  #       'name' => c['Name'],
  #       'rate' => c.xpath('./xmlns:Rate')[0]['IncSum']
  #     }}
  #   }} if doc.xpath("//xmlns:Result/xmlns:Code").text.to_i == 0
  # end
  #
  # def self.operation_state(id)
  #   crc = get_hash(ENV['MERCHANT_LOGIN'], id.to_s, ENV['MERCHANT_PASS_2'])
  #   svc_url = "#{ENV['SERVICES_URL']}/OpState?MerchantLogin=#{ENV['MERCHANT_LOGIN']}&InvoiceID=#{id}&Signature=#{crc}&StateCode=80"
  #
  #   doc = Nokogiri::XML(open(svc_url))
  #
  #   return nil unless doc.xpath("//xmlns:Result/xmlns:Code").text.to_i == 0
  #
  #   state_desc = {
  #     1   => 'Информация об операции с таким InvoiceID не найдена',
  #     5   => 'Только инициирована, деньги не получены',
  #     10  => 'Деньги не были получены, операция отменена',
  #     50  => 'Деньги получены, ожидание решение пользователя о платеже',
  #     60  => 'Деньги после получения были возвращены пользователю',
  #     80  => 'Исполнение операции приостановлено',
  #     100 => 'Операция завершена успешно',
  #   }
  #
  #   s = doc.xpath("//xmlns:State")[0]
  #   code = s.xpath('./xmlns:Code').text.to_i
  #   state = {
  #     'code' => code,
  #     'desc' => state_desc[code],
  #     'request_date' => s.xpath('./xmlns:RequestDate').text,
  #     'state_date' => s.xpath('./xmlns:StateDate').text
  #   }
  # end

  def self.get_hash(*s)
    Digest::SHA256.hexdigest(s.join(':'))
  end
end
