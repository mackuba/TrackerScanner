require 'csv'
require 'json'
require 'optparse'
require 'set'

MIN_SITES = 5

if ARGV[0].to_s.empty?
    $stderr.puts "Usage: #{$PROGRAM_NAME} <results.json> [-h] [-x ...] > output.json"
    $stderr.puts "   or: #{$PROGRAM_NAME} <results.json> [-h] [-x ...] -c > output.csv"
    exit 1
end

format = :json
normalize_http = false
exclusions = []

OptionParser.new do |opts|
    opts.on("-c") { |v| format = :csv }
    opts.on("-h") { |v| normalize_http = true }
    opts.on("-xLIST") { |v| exclusions = v.split(',') }
end.parse!

list = JSON.parse(File.read(ARGV[0]))
resources = {}

list.each do |record|
    page_host = URI(record["page"]).host

    record["resources"].each do |url|
        next if exclusions.any? { |x| url.include?(x) }

        url = url.gsub(/#.*/, '').gsub(/\?.*/, '')
        url = url.gsub(/^http:/, 'https:') if normalize_http
        resources[url] ||= Set.new
        resources[url] << page_host
    end
end

json = resources
    .select { |url, hosts| hosts.count >= MIN_SITES }
    .sort_by { |url, hosts| -hosts.count }
    .map { |url, hosts| {
        url: url,
        sites: hosts.count,
        domains: hosts.sort_by { |h| h.split('.').reverse }
    }}

if format == :json
    puts JSON.pretty_generate(json)
else
    CSV($stdout) do |csv|
        json.each do |record|
            csv << [record[:url], record[:sites]]
        end
    end
end
