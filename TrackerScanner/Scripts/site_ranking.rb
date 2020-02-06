require 'csv'
require 'json'
require 'optparse'

if ARGV[0].to_s.empty?
    $stderr.puts "Usage: #{$PROGRAM_NAME} <results.json> [-d] > output.csv"
    exit 1
end

grouping = :url

OptionParser.new do |opts|
    opts.on("-d") { |v| grouping = :domain }
end.parse!

list = JSON.parse(File.read(ARGV[0]))
ranking = {}

list.each do |record|
    key = (grouping == :url) ? record["page"] : URI(record["page"]).host

    ranking[key] ||= []
    ranking[key] << [
        record["resources"].length,
        record["resources"].group_by { |r| URI(r).host }.length
    ]
end

table = ranking
    .map { |key, list| [key, *list.sort_by(&:last).last] }
    .sort_by { |key, r, h| -h }

CSV($stdout) do |csv|
    table.each do |row|
        csv << row
    end
end
