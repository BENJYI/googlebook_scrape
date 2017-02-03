require 'rubygems'
require 'bundler/setup'

require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'nokogiri'
require 'json'
require 'pry'
require 'uri'
require 'pdfkit'
require 'combine_pdf'

Capybara.run_server = false
Capybara.current_driver = :selenium

$domain = "https://landing.google.com"
$url = "https://landing.google.com/sre/book/"
chapter_urls = [] 

def visit
  full_pdf = CombinePDF.new
  url = $domain + '/sre/book'
  Capybara.visit url
  html_doc = Nokogiri::HTML(Capybara.page.body)

  # Get links of each list element and add to chapter_urls
  lis = html_doc.css('.content li a')

  lis.each do |li|
    # Error check
    break if Capybara.page.has_title? "404 Not Found"
    if Capybara.page.has_title? "503 Service Temporarily Unavailable"
      Capybara.page.evalute_script("window.location.reload()")
      puts 'reloading'
    end

    Capybara.visit $domain + li.attributes['href']
    html = Nokogiri::HTML(Capybara.page.body)
    content = html.css('.content')

    kit = PDFKit.new(content.inner_html)
    pdf = kit.to_pdf
    full_pdf << CombinePDF.parse(pdf)
  end
  full_pdf.save "googlebook.pdf"
end

visit