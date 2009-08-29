#!/usr/bin/ruby -rubygems

require 'ruby-debug'

class GHContest
  attr_accessor :uhash, :uarray, :users, :repos

  def initialize
    #read_data; read_users; dump_data
    load_data; crunch
  end

  def read_data
    f = File.open('download/data.txt')

    @uhash = {}
    @uarray = {}
    @repos = {}

    while !f.eof? do
      line = f.readline
      user, repo = line.chomp.split(':').map { |x| x.to_i } 

      @uhash[user] = {} unless @uhash.has_key?(user)
      @uhash[user].merge!({ repo => true })

      @repos[repo] = {} unless @repos.has_key?(repo)
      @repos[repo].merge!({ user => true })
    end

    f.close
  end

  def read_users
    f = File.open('download/test.txt')
    @users = {}

    while !f.eof? do
      line = f.readline
      user = line.chomp.map { |x| x.to_i }[0]
      @users[user] = []
    end

    f.close
  end

  def dump_data
    print "Writing data\n"

    f = File.open('data.marshal', 'w+')
    Marshal.dump(@uhash, f)
    f.close

    f = File.open('repos.marshal', 'w+')
    Marshal.dump(@repos, f)
    f.close

    f = File.open('users.marshal', 'w+')
    Marshal.dump(@users, f)
    f.close
  end

  def load_data
    print "Loading data\n"
    @uhash = Marshal.load(File.open('data.marshal'))
    @repos = Marshal.load(File.open('repos.marshal'))
    @users = Marshal.load(File.open('users.marshal'))

    @likes = Marshal.load(File.open('this_likes_that.marshal'))
  end

  def this_likes_that
    @likes = {}
    size = @uhash.keys.size
    i = 0

    @uhash.each_pair do |user, user_repos|
      user_repos = user_repos.keys
      i += 1
      #break if i > 200
      print "this_likes_that user #{user} (#{i*100/size})\n"
      all_user_repos = user_repos
      #debugger
      user_repos.each do |user_repo|
        @likes[user_repo] = {} unless @likes.has_key?(user_repo)
        (all_user_repos - [user_repo]).each do |repo|
          @likes[repo] = {} unless @likes.has_key?(repo)
          current = @likes[repo][user_repo] || 0
          @likes[repo][user_repo] = current + 1
        end
      end
    end

    f = File.open('this_likes_that.marshal', 'w+')
    Marshal.dump(@likes, f)
    f.close

    debugger
  end
        
  def crunch
    print "Crunching\n"
    popular = @repos.sort_by { |x| -x[1].size }[0, 50]
    res = popular.map { |x| x[0]}
    f = File.open('results.txt', 'w+')
    size = @users.size
    i = 0
    @users.each_pair do |user, empty|
      i += 1
      print "Crunching user #{user} (#{i * 100 / size})\n"
      if user_hash = @uhash[user]
        user_hash = user_hash.keys
        sugg = {}
        user_hash.each do |repo|
          liked = @likes[repo] || {}
          liked.each_pair do |lrepo, count|
            prev = sugg[lrepo] || 0
            sugg[lrepo] = prev + count
          end
        end
        ures = sugg.sort_by { |x| -x[1] }[0, 10].collect { |x| x[0] }
        if ures.size < 10
          ures = (ures + res[0, 10]).uniq[0, 10]
        end
      else
        ures = res[0, 10]
      end
      f.write "#{user}:#{ures.join(',')}\n"
    end
    f.close
  end 
end

contest = GHContest.new


