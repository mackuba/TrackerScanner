require 'csv'
require 'json'

if ARGV[0].to_s.empty?
    $stderr.puts "Usage: #{$PROGRAM_NAME} <results.json>"
    exit 1
end

list = JSON.parse(File.read(ARGV[0]))
table = []

list.each do |record|
    table << [
        record["page"],
        record["resources"].length,
        record["resources"].group_by { |r| URI(r).host }.length
    ]
end

table.sort_by! { |p, r, h| -h }

CSV($stdout) do |csv|
    table.each do |row|
        csv << row
    end
end
