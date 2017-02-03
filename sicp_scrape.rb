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


def visit
  full_pdf = CombinePDF.new
  u = 0
  while true do
    u+=1
    url = "https://mitpress.mit.edu/sicp/full-text/book/book-Z-H-#{u}.html"
    Capybara.visit url

    # Error check
    break if Capybara.page.has_title? "404 Not Found"
    if Capybara.page.has_title? "503 Service Temporarily Unavailable"
      Capybara.page.evalute_script("window.location.reload()")
      puts 'reloading'
    end

    html = Capybara.page.body
    @html = Nokogiri::HTML.parse(html)
    @html.css("div").each do |div|
      div.remove if div["class"] == "navigation"
    end

    kit = PDFKit.new(@html.inner_html)
    pdf = kit.to_pdf
    full_pdf << CombinePDF.parse(pdf)
  end
  full_pdf.save "sicp.pdf"
end

visit