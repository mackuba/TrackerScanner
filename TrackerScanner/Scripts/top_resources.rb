require 'json'
require 'set'

MIN_SITES = 5

if ARGV[0].to_s.empty?
    $stderr.puts "Usage: #{$PROGRAM_NAME} <results.json>"
    exit 1
end

list = JSON.parse(File.read(ARGV[0]))
resources = {}

list.each do |record|
    page_host = URI(record["page"]).host

    record["resources"].each do |url|
        url = url.gsub(/#.*/, '').gsub(/\?.*/, '')
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

puts JSON.pretty_generate(json)
