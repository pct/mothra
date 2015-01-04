#!/usr/bin/env ruby

require 'date'
require 'colorize'
require 'thor'
require 'rodzilla'

require 'base64'
require 'pathname'

def get_file_name
  Pathname.new(file_path).basename
end

def base64(file_path)
  Base64.encode64(IO.read(file_path))
end

def check_config
  config_file = '~/.config/mothra/config.yml'

  if File.exist?(config_file)
    @config = YAML.load_file 'config.yml'
  else
    puts 'You should set ~/.config/mothra/config.yml first!'.yellow 
    exit
  end
end

check_config


@bz = Rodzilla::Resource::Bug.new(@config['BZ_URL'], @config['BZ_USER'], @config['BZ_PASSWD'], :json)

class CLI < Thor
  desc 'search <keyword>', 'search keyword from bugzilla summary for last 180 days'
  option :keyword, :required => true
  def search(keyword)
    half_years_ago = DateTime.now - 180
    results = @bz.search(product: @config['PRODUCT'], 
                         component: @config['COMPONENT'], 
                         creation_time: half_years_ago, 
                         status: @config['STATUS'], 
                         summary: keyword
                        )

    if not results['bugs'].empty?
      results['bugs'].each_with_index do |r, i|
        print "[#{r['id']}] ".yellow
        print "[#{r['status']}] ".cyan
        print "#{r['summary']} ".white
        puts "[#{r['last_change_time']}] ".gray
      end
    else
      puts 'Not found.'
    end
  end

  def create(summary)
    begin
      ret = @bz.create!(product: @config['PRODUCT'],
                        component: @config['COMPONENT'],
                        version: '1.0',
                        op_sys: 'FreeBSD',
                        platform: 'All',
                        #version: 'Latest',
                        #severity: 'Affects Only Me',
                        #op_sys: 'Any',
                        #platform: 'Any',
                        summary: summary
                       )

      print 'PR'
      print " [#{ret['id']}] ".yellow
      puts "created!"
      puts "#{@config['BZ_URL']}/show_bug.cgi?id=#{ret['id']}".cyan
    rescue
      puts 'Send-pr fail, please try again!'.yellow
    end
  end

  def add_file(bug_id, file_path)
    file_name = get_file_name(file_path)
    file_base64 = base64(file_path)

    begin
      ret = @bz.add_attachment!(ids: [bug_id],
                                data: file_base64,
                                file_name: file_name,
                                summary: 'Just add an attachment.',
                                content_type: 'text/plain',
                               )
      print 'PR'
      print " [#{bug_id}] ".cyan
      print 'had add an attachment, '
      puts " [#{ret['ids'][0]}] ".yellow
      puts "#{@config['BZ_URL']}/show_bug.cgi?id=#{bug_id}".cyan
    rescue
      puts 'Fail to add attachments, please try again!'.yellow
    end

  end

end
