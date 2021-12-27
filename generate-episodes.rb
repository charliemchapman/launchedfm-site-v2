require 'date'
require 'uri'
require 'net/http'
require 'nokogiri'

# uri = URI('http://feed.launchedfm.com')
uri = URI('https://feeds.fireside.fm/launched/rss')
res = Net::HTTP.get_response(uri)
xml = res.body

doc = Nokogiri::XML(xml)
episodes = doc.search('item')

episodes.each { |episode| 
    title = episode.search('title').text
    subtitle = episode.search('itunes|subtitle').text
    duration = episode.search('itunes|duration').text
    audioUrl = episode.search('enclosure').attr('url')
    image = episode.search('itunes|image').attr('href')
    content = episode.search('content|encoded').text.strip

    pubDateText = episode.search('pubDate').text
    pubDate = Date.parse(pubDateText)
    pubDateString = "#{pubDate.year}-#{pubDate.month}-#{pubDate.day}"

    cleanDescription = subtitle.gsub('"', '\"')

    t = ''
    t += "---\n"
    t += "title: \"#{title}\"\n"
    t += "description: \"#{cleanDescription}\"\n"
    t += "duration: \"#{duration}\"\n"
    t += "audioUrl: \"#{audioUrl}\"\n"
    t += "image: \"#{image}\"\n"
    t += "---\n"
    t += "\n"
    t += content

    if !Dir.exists?("_posts")
        Dir.mkdir("_posts")
    end

    slug = title
            .gsub(":", "-")
            .gsub('ñ', "n")
            .gsub("í", "i")
            .gsub("ı", "i")
            .gsub("ç", "c")

    charactersToRemove = ['’', '', '.', '(', ')', '?', '&', ' ']
    charactersToRemove.each { |c|
        slug.gsub!(c, '')
    }

    filename = "#{pubDateString}-#{slug}"

    open("_posts/#{filename}.md", 'w') do |f|
        f.puts(t)
    end
}