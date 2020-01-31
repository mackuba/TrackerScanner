require 'json'

if ARGV[0].to_s.empty? || ARGV[1].to_s.empty?
    $stderr.puts "Usage: #{$PROGRAM_NAME} <results.json> <url_fragment>"
    exit 1
end

list = JSON.parse(File.read(ARGV[0]))

data = list.detect { |j| j['page'].include?(ARGV[1]) }

if data.nil?
    $stderr.puts "No matching URL found."
    exit 1
end

domains = data['resources'].map { |r| URI(r).host }.sort.uniq

puts domains
